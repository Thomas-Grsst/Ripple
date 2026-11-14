import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/app_customization.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/installed_app.dart';
import 'package:ripple/layers/functional/Apps/domain/entities/launcher_device_event.dart';
import 'package:ripple/layers/functional/Apps/domain/gateways/app_customization_gateway.dart';
import 'package:ripple/layers/functional/Apps/domain/gateways/launcher_device_gateway.dart';
import 'package:ripple/layers/functional/Apps/domain/use_cases/launcher_use_cases.dart';
import 'package:ripple/layers/functional/Apps/presentation/cubit/launcher_cubit.dart';
import 'package:ripple/layers/functional/Apps/presentation/cubit/launcher_state.dart';

class FakeDeviceGateway implements LauncherDeviceGateway {
  final StreamController<LauncherDeviceEvent> events = StreamController<LauncherDeviceEvent>.broadcast();
  final List<String> launched = <String>[];
  List<InstalledApp> apps = <InstalledApp>[
    InstalledApp(packageName: 'com.agenda', label: 'Agenda', icon: Uint8List(0)),
    InstalledApp(packageName: 'com.maps', label: 'Plans', icon: Uint8List(0)),
  ];
  bool launchSucceeds = true;

  @override
  Future<List<InstalledApp>> fetchInstalledApps() async => apps;

  @override
  Future<bool> launch(String packageName) async {
    launched.add(packageName);
    return launchSucceeds;
  }

  @override
  Future<void> openAppInfo(String packageName) async {}

  @override
  Future<void> uninstall(String packageName) async {}

  @override
  Future<void> expandNotifications() async {}

  @override
  Stream<LauncherDeviceEvent> watch() => events.stream;
}

class MemoryCustomizationGateway implements AppCustomizationGateway {
  AppCustomization stored = const AppCustomization();

  @override
  Future<AppCustomization> load() async => stored;

  @override
  Future<void> save(AppCustomization customization) async => stored = customization;
}

LauncherCubit buildCubit(FakeDeviceGateway device, MemoryCustomizationGateway customization) {
  return LauncherCubit(
    fetchInstalledApps: FetchInstalledApps(device),
    launchApp: LaunchApp(device),
    openAppInfo: OpenAppInfo(device),
    uninstallApp: UninstallApp(device),
    expandNotificationShade: ExpandNotificationShade(device),
    watchLauncherDevice: WatchLauncherDevice(device),
    loadAppCustomization: LoadAppCustomization(customization),
    saveAppCustomization: SaveAppCustomization(customization),
  );
}

void main() {
  late FakeDeviceGateway device;
  late MemoryCustomizationGateway customization;
  late LauncherCubit cubit;

  setUp(() async {
    device = FakeDeviceGateway();
    customization = MemoryCustomizationGateway();
    cubit = buildCubit(device, customization);
    await cubit.start();
  });

  tearDown(() => cubit.close());

  test('start loads the installed apps', () {
    expect(cubit.state.status, LauncherStatus.ready);
    expect(cubit.state.catalog.visible, hasLength(2));
  });

  test('toggling a favorite updates the catalog and persists it', () async {
    await cubit.toggleFavorite('com.maps');
    expect(cubit.state.catalog.favorites.single.packageName, 'com.maps');
    expect(customization.stored.favorites, <String>['com.maps']);
  });

  test('creating a group with an app shows it on the home and persists it', () async {
    await cubit.createGroup('XEFI', packages: <String>['com.agenda']);
    expect(cubit.state.catalog.groups.single.group.name, 'XEFI');
    expect(cubit.state.catalog.groups.single.entries.single.packageName, 'com.agenda');
    expect(customization.stored.groups.single.packages, <String>['com.agenda']);
  });

  test('favorites can be reordered from the home and the order persists', () async {
    await cubit.toggleFavorite('com.agenda');
    await cubit.toggleFavorite('com.maps');
    await cubit.reorderHomeEntries(1, 0);
    expect(cubit.state.catalog.favorites.map((e) => e.packageName), <String>['com.maps', 'com.agenda']);
    expect(customization.stored.favorites, <String>['com.maps', 'com.agenda']);
  });

  test('apps inside a group can be reordered while the group is shown', () async {
    await cubit.createGroup('XEFI', packages: <String>['com.agenda', 'com.maps']);
    cubit.selectGroup(cubit.state.catalog.groups.single.group.id);
    await cubit.reorderHomeEntries(0, 1);
    expect(cubit.state.catalog.groups.single.entries.map((e) => e.packageName), <String>['com.maps', 'com.agenda']);
    expect(customization.stored.groups.single.packages, <String>['com.maps', 'com.agenda']);
    expect(customization.stored.favorites, isEmpty);
  });

  test('the home shows favorites by default, then a letter or a group when selected', () async {
    expect(cubit.state.homeFilter, const FavoritesFilter());

    cubit.selectLetter('P');
    expect(cubit.state.homeFilter, const LetterFilter('P'));
    expect(cubit.state.catalog.entriesForLetter('P').single.packageName, 'com.maps');

    await cubit.createGroup('XEFI', packages: <String>['com.agenda']);
    final String groupId = cubit.state.customization.groups.single.id;
    cubit.selectGroup(groupId);
    expect(cubit.state.homeFilter, GroupFilter(groupId));

    cubit.showFavorites();
    expect(cubit.state.homeFilter, const FavoritesFilter());
  });

  test('launching an app or pressing home brings the favorites back', () async {
    cubit.selectLetter('A');
    await cubit.launch(cubit.state.catalog.entriesForLetter('A').single);
    expect(cubit.state.homeFilter, const FavoritesFilter());

    cubit.selectLetter('P');
    device.events.add(const HomeRequested());
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.homeFilter, const FavoritesFilter());
  });

  test('a blank group name is ignored', () async {
    await cubit.createGroup('   ');
    expect(cubit.state.customization.groups, isEmpty);
  });

  test('submitting a search launches the best match and clears the query', () async {
    cubit.search('pla');
    await cubit.launchFirstResult();
    expect(device.launched, <String>['com.maps']);
    expect(cubit.state.query, isEmpty);
  });

  test('a failed launch is reported', () async {
    device.launchSucceeds = false;
    await cubit.launch(cubit.state.catalog.visible.first);
    expect(cubit.state.launchFailures, 1);
  });

  test('device events update notification counts and reload apps', () async {
    device.events.add(const NotificationCountsUpdated(<String, int>{'com.agenda': 2}));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.catalog.visible.first.notificationCount, 2);

    device.apps = <InstalledApp>[...device.apps, InstalledApp(packageName: 'com.cam', label: 'Caméra', icon: Uint8List(0))];
    device.events.add(const InstalledAppsChanged());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.catalog.visible, hasLength(3));
  });

  test('pressing home clears the search and signals the view', () async {
    cubit.search('age');
    device.events.add(const HomeRequested());
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.query, isEmpty);
    expect(cubit.state.homeRequests, 1);
  });
}
