import 'package:shared_preferences/shared_preferences.dart';

import '../../../technical/Device/device_bridge.dart';
import '../domain/launcher_settings.dart';

class PreferencesLauncherSettingsGateway implements LauncherSettingsGateway {
  const PreferencesLauncherSettingsGateway(this._preferences);

  static const String _showWallpaperKey = 'settings.showWallpaper';
  static const String _showIconsKey = 'settings.showIcons';
  static const String _weatherCityKey = 'settings.weatherCity';

  final SharedPreferencesAsync _preferences;

  @override
  Future<LauncherSettings> load() async {
    const LauncherSettings defaults = LauncherSettings();
    return LauncherSettings(
      showWallpaper: await _preferences.getBool(_showWallpaperKey) ?? defaults.showWallpaper,
      showIcons: await _preferences.getBool(_showIconsKey) ?? defaults.showIcons,
      weatherCity: await _preferences.getString(_weatherCityKey) ?? defaults.weatherCity,
    );
  }

  @override
  Future<void> save(LauncherSettings settings) async {
    await _preferences.setBool(_showWallpaperKey, settings.showWallpaper);
    await _preferences.setBool(_showIconsKey, settings.showIcons);
    await _preferences.setString(_weatherCityKey, settings.weatherCity);
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
  Future<void> openWallpaperPicker() => _bridge.openWallpaperPicker();
}
