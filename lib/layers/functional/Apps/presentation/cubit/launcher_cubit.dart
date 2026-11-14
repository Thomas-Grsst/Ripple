import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_customization.dart';
import '../../domain/entities/installed_app.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_device_event.dart';
import '../../domain/entities/launcher_entry.dart';
import '../../domain/use_cases/build_launcher_catalog.dart';
import '../../domain/use_cases/launcher_use_cases.dart';
import '../../domain/use_cases/search_launcher_entries.dart';
import 'launcher_state.dart';

class LauncherCubit extends Cubit<LauncherState> {
  LauncherCubit({
    required this._fetchInstalledApps,
    required this._launchApp,
    required this._openAppInfo,
    required this._uninstallApp,
    required this._expandNotificationShade,
    required this._watchLauncherDevice,
    required this._loadAppCustomization,
    required this._saveAppCustomization,
    this._buildLauncherCatalog = const BuildLauncherCatalog(),
    this._searchLauncherEntries = const SearchLauncherEntries(),
  })  : super(const LauncherState());

  final FetchInstalledApps _fetchInstalledApps;
  final LaunchApp _launchApp;
  final OpenAppInfo _openAppInfo;
  final UninstallApp _uninstallApp;
  final ExpandNotificationShade _expandNotificationShade;
  final WatchLauncherDevice _watchLauncherDevice;
  final LoadAppCustomization _loadAppCustomization;
  final SaveAppCustomization _saveAppCustomization;
  final BuildLauncherCatalog _buildLauncherCatalog;
  final SearchLauncherEntries _searchLauncherEntries;

  StreamSubscription<LauncherDeviceEvent>? _deviceSubscription;

  Future<void> start() async {
    _deviceSubscription ??= _watchLauncherDevice().listen(_onDeviceEvent);
    final AppCustomization customization = await _loadAppCustomization();
    _publish(customization: customization);
    await reloadApps();
  }

  Future<void> reloadApps() async {
    try {
      final List<InstalledApp> apps = await _fetchInstalledApps();
      _publish(apps: apps, status: LauncherStatus.ready);
    } on PlatformException {
      emit(state.copyWith(status: LauncherStatus.failure));
    }
  }

  void search(String query) {
    emit(state.copyWith(
      query: query,
      searchResults: _searchLauncherEntries(state.catalog.visible, query),
    ));
  }

  void clearSearch() => search('');

  Future<void> launch(LauncherEntry entry) async {
    final bool launched = await _launchApp(entry.packageName);
    if (!launched) {
      emit(state.copyWith(launchFailures: state.launchFailures + 1));
      return;
    }
    if (state.isSearching) {
      clearSearch();
    }
  }

  Future<void> launchFirstResult() async {
    if (state.searchResults.isEmpty) {
      return;
    }
    await launch(state.searchResults.first);
  }

  Future<void> openAppInfo(LauncherEntry entry) => _openAppInfo(entry.packageName);

  Future<void> uninstall(LauncherEntry entry) => _uninstallApp(entry.packageName);

  Future<void> expandNotificationShade() => _expandNotificationShade();

  Future<void> toggleHome(String packageName) => _updateCustomization(state.customization.toggleHome(packageName));

  Future<void> toggleFavorite(String packageName) => _updateCustomization(state.customization.toggleFavorite(packageName));

  Future<void> moveFavorite(int oldIndex, int newIndex) {
    return _updateCustomization(state.customization.moveFavorite(oldIndex, newIndex));
  }

  Future<void> hide(String packageName) => _updateCustomization(state.customization.hide(packageName));

  Future<void> unhide(String packageName) => _updateCustomization(state.customization.unhide(packageName));

  Future<void> rename(String packageName, String name) => _updateCustomization(state.customization.rename(packageName, name));

  Future<void> createGroup(String name, {List<String> packages = const <String>[]}) {
    if (name.trim().isEmpty) {
      return Future<void>.value();
    }
    final String id = 'group-${DateTime.now().microsecondsSinceEpoch}';
    return _updateCustomization(state.customization.createGroup(id: id, name: name, packages: packages));
  }

  Future<void> renameGroup(String groupId, String name) {
    if (name.trim().isEmpty) {
      return Future<void>.value();
    }
    return _updateCustomization(state.customization.renameGroup(groupId, name));
  }

  Future<void> deleteGroup(String groupId) => _updateCustomization(state.customization.deleteGroup(groupId));

  Future<void> toggleGroupMember(String groupId, String packageName) {
    return _updateCustomization(state.customization.toggleGroupMember(groupId, packageName));
  }

  Future<void> toggleGroupExpanded(String groupId) => _updateCustomization(state.customization.toggleGroupExpanded(groupId));

  Future<void> moveGroup(int oldIndex, int newIndex) => _updateCustomization(state.customization.moveGroup(oldIndex, newIndex));

  Future<void> _updateCustomization(AppCustomization customization) async {
    _publish(customization: customization);
    await _saveAppCustomization(customization);
  }

  void _onDeviceEvent(LauncherDeviceEvent event) {
    switch (event) {
      case HomeRequested():
        emit(state.copyWith(homeRequests: state.homeRequests + 1, query: '', searchResults: const <LauncherEntry>[]));
      case InstalledAppsChanged():
        unawaited(reloadApps());
      case NotificationCountsUpdated(:final Map<String, int> counts):
        _publish(notificationCounts: counts);
    }
  }

  void _publish({
    List<InstalledApp>? apps,
    AppCustomization? customization,
    Map<String, int>? notificationCounts,
    LauncherStatus? status,
  }) {
    final List<InstalledApp> nextApps = apps ?? state.apps;
    final AppCustomization nextCustomization = customization ?? state.customization;
    final Map<String, int> nextCounts = notificationCounts ?? state.notificationCounts;
    final LauncherCatalog catalog = _buildLauncherCatalog(
      apps: nextApps,
      customization: nextCustomization,
      notificationCounts: nextCounts,
    );
    emit(state.copyWith(
      status: status,
      apps: nextApps,
      customization: nextCustomization,
      notificationCounts: nextCounts,
      catalog: catalog,
      searchResults: _searchLauncherEntries(catalog.visible, state.query),
    ));
  }

  @override
  Future<void> close() async {
    await _deviceSubscription?.cancel();
    return super.close();
  }
}
