import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/launcher_settings.dart';
import '../../domain/settings_use_cases.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.settings = const LauncherSettings(),
    this.integration = const SystemIntegrationStatus(),
    this.isLoaded = false,
  });

  final LauncherSettings settings;
  final SystemIntegrationStatus integration;
  final bool isLoaded;

  SettingsState copyWith({LauncherSettings? settings, SystemIntegrationStatus? integration, bool? isLoaded}) {
    return SettingsState(
      settings: settings ?? this.settings,
      integration: integration ?? this.integration,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => <Object?>[settings, integration, isLoaded];
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _photoWallpaperId = 'photo';

  SettingsCubit({
    required this._loadLauncherSettings,
    required this._saveLauncherSettings,
    required this._readSystemIntegration,
    required this._requestDefaultLauncher,
    required this._openNotificationAccess,
    required this._openRippleAppInfo,
    required this._openWallpaperPicker,
    required this._pickWallpaperPhoto,
  })  : super(const SettingsState());

  final LoadLauncherSettings _loadLauncherSettings;
  final SaveLauncherSettings _saveLauncherSettings;
  final ReadSystemIntegration _readSystemIntegration;
  final RequestDefaultLauncher _requestDefaultLauncher;
  final OpenNotificationAccess _openNotificationAccess;
  final OpenRippleAppInfo _openRippleAppInfo;
  final OpenWallpaperPicker _openWallpaperPicker;
  final PickWallpaperPhoto _pickWallpaperPhoto;

  Future<void> start() async {
    final LauncherSettings settings = await _loadLauncherSettings();
    emit(state.copyWith(settings: settings, isLoaded: true));
    await refreshIntegration();
  }

  Future<void> refreshIntegration() async {
    emit(state.copyWith(integration: await _readSystemIntegration()));
  }

  Future<void> setWallpaper(String wallpaperId) => _update(state.settings.copyWith(wallpaperId: wallpaperId));

  Future<void> setClockStyle(String clockStyleId) => _update(state.settings.copyWith(clockStyleId: clockStyleId));

  Future<void> setGlanceLayout(String glanceLayoutId) => _update(state.settings.copyWith(glanceLayoutId: glanceLayoutId));

  Future<void> setIconStyle(String iconStyleId) => _update(state.settings.copyWith(iconStyleId: iconStyleId));

  Future<void> setWeatherCity(String city) => _update(state.settings.copyWith(weatherCity: city.trim()));

  Future<void> requestDefaultLauncher() => _requestDefaultLauncher();

  Future<void> openNotificationAccess() => _openNotificationAccess();

  Future<void> openRippleAppInfo() => _openRippleAppInfo();

  Future<void> openWallpaperPicker() => _openWallpaperPicker();

  Future<void> pickWallpaperPhoto() async {
    try {
      final String? path = await _pickWallpaperPhoto();
      if (path != null) {
        await _update(state.settings.copyWith(wallpaperId: _photoWallpaperId, photoPath: path));
      }
    } on PlatformException {
      return;
    }
  }

  Future<void> _update(LauncherSettings settings) async {
    emit(state.copyWith(settings: settings));
    await _saveLauncherSettings(settings);
  }
}
