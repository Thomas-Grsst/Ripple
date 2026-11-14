import 'package:shared_preferences/shared_preferences.dart';

import '../../../technical/Device/device_bridge.dart';
import '../domain/launcher_settings.dart';

class PreferencesLauncherSettingsGateway implements LauncherSettingsGateway {
  const PreferencesLauncherSettingsGateway(this._preferences);

  static const String _legacyShowWallpaperKey = 'settings.showWallpaper';
  static const String _wallpaperKey = 'settings.wallpaper';
  static const String _legacyShowIconsKey = 'settings.showIcons';
  static const String _iconStyleKey = 'settings.iconStyle';
  static const String _noIconStyleId = 'none';
  static const String _weatherCityKey = 'settings.weatherCity';
  static const String _photoPathKey = 'settings.photoPath';
  static const String _clockStyleKey = 'settings.clockStyle';
  static const String _systemWallpaperId = 'system';

  final SharedPreferencesAsync _preferences;

  @override
  Future<LauncherSettings> load() async {
    const LauncherSettings defaults = LauncherSettings();
    return LauncherSettings(
      wallpaperId: await _loadWallpaperId() ?? defaults.wallpaperId,
      iconStyleId: await _loadIconStyleId() ?? defaults.iconStyleId,
      weatherCity: await _preferences.getString(_weatherCityKey) ?? defaults.weatherCity,
      photoPath: await _preferences.getString(_photoPathKey) ?? defaults.photoPath,
      clockStyleId: await _preferences.getString(_clockStyleKey) ?? defaults.clockStyleId,
    );
  }

  Future<String?> _loadIconStyleId() async {
    final String? stored = await _preferences.getString(_iconStyleKey);
    if (stored != null) {
      return stored;
    }
    final bool? legacyShowIcons = await _preferences.getBool(_legacyShowIconsKey);
    return legacyShowIcons == false ? _noIconStyleId : null;
  }

  Future<String?> _loadWallpaperId() async {
    final String? stored = await _preferences.getString(_wallpaperKey);
    if (stored != null) {
      return stored;
    }
    final bool? legacyShowWallpaper = await _preferences.getBool(_legacyShowWallpaperKey);
    return legacyShowWallpaper == true ? _systemWallpaperId : null;
  }

  @override
  Future<void> save(LauncherSettings settings) async {
    await _preferences.setString(_wallpaperKey, settings.wallpaperId);
    await _preferences.setString(_iconStyleKey, settings.iconStyleId);
    await _preferences.setString(_weatherCityKey, settings.weatherCity);
    await _preferences.setString(_photoPathKey, settings.photoPath);
    await _preferences.setString(_clockStyleKey, settings.clockStyleId);
  }
}

class DeviceSystemIntegrationGateway implements SystemIntegrationGateway {
  const DeviceSystemIntegrationGateway(this._bridge);

  final DeviceBridge _bridge;

  @override
  Future<SystemIntegrationStatus> status() async {
    return SystemIntegrationStatus(
      isDefaultLauncher: await _bridge.isDefaultLauncher(),
      hasNotificationAccess: await _bridge.hasNotificationAccess(),
    );
  }

  @override
  Future<void> requestDefaultLauncher() => _bridge.requestDefaultLauncher();

  @override
  Future<void> openNotificationAccess() => _bridge.openNotificationAccess();

  @override
  Future<void> openRippleAppInfo() => _bridge.openRippleAppInfo();

  @override
  Future<void> openWallpaperPicker() => _bridge.openWallpaperPicker();
}
