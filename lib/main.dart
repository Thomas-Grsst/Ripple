import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'layers/functional/Apps/data/gateways/device_launcher_gateway.dart';
import 'layers/functional/Apps/data/gateways/preferences_app_customization_gateway.dart';
import 'layers/functional/Apps/domain/use_cases/launcher_use_cases.dart';
import 'layers/functional/Apps/presentation/cubit/launcher_cubit.dart';
import 'layers/functional/Glance/data/device_battery_gateway.dart';
import 'layers/functional/Glance/data/open_meteo_weather_gateway.dart';
import 'layers/functional/Glance/domain/battery_status.dart';
import 'layers/functional/Glance/domain/weather_report.dart';
import 'layers/functional/Glance/presentation/cubit/battery_cubit.dart';
import 'layers/functional/Glance/presentation/cubit/weather_cubit.dart';
import 'layers/functional/Settings/data/local_wallpaper_photo_gateway.dart';
import 'layers/functional/Settings/data/settings_gateways.dart';
import 'layers/functional/Settings/domain/settings_use_cases.dart';
import 'layers/functional/Settings/presentation/cubit/settings_cubit.dart';
import 'layers/technical/Device/device_bridge.dart';
import 'ripple_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final DeviceBridge bridge = DeviceBridge();
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();

  final DeviceLauncherGateway launcherGateway = DeviceLauncherGateway(bridge);
  final PreferencesAppCustomizationGateway customizationGateway = PreferencesAppCustomizationGateway(preferences);
  final LauncherCubit launcherCubit = LauncherCubit(
    fetchInstalledApps: FetchInstalledApps(launcherGateway),
    launchApp: LaunchApp(launcherGateway),
    openAppInfo: OpenAppInfo(launcherGateway),
    uninstallApp: UninstallApp(launcherGateway),
    expandNotificationShade: ExpandNotificationShade(launcherGateway),
    watchLauncherDevice: WatchLauncherDevice(launcherGateway),
    loadAppCustomization: LoadAppCustomization(customizationGateway),
    saveAppCustomization: SaveAppCustomization(customizationGateway),
  );

  final PreferencesLauncherSettingsGateway settingsGateway = PreferencesLauncherSettingsGateway(preferences);
  final DeviceSystemIntegrationGateway integrationGateway = DeviceSystemIntegrationGateway(bridge);
  final SettingsCubit settingsCubit = SettingsCubit(
    loadLauncherSettings: LoadLauncherSettings(settingsGateway),
    saveLauncherSettings: SaveLauncherSettings(settingsGateway),
    readSystemIntegration: ReadSystemIntegration(integrationGateway),
    requestDefaultLauncher: RequestDefaultLauncher(integrationGateway),
    openNotificationAccess: OpenNotificationAccess(integrationGateway),
    openRippleAppInfo: OpenRippleAppInfo(integrationGateway),
    pickWallpaperPhoto: const PickWallpaperPhoto(LocalWallpaperPhotoGateway()),
    openWallpaperPicker: OpenWallpaperPicker(integrationGateway),
  );

  final WeatherCubit weatherCubit = WeatherCubit(FetchCurrentWeather(OpenMeteoWeatherGateway(http.Client())));

  final BatteryCubit batteryCubit = BatteryCubit(ReadBatteryStatus(DeviceBatteryGateway(bridge)));

  await settingsCubit.start();
  unawaited(batteryCubit.start());
  unawaited(weatherCubit.watchCity(settingsCubit.state.settings.weatherCity));
  unawaited(launcherCubit.start());

  runApp(RippleApp(launcherCubit: launcherCubit, settingsCubit: settingsCubit, weatherCubit: weatherCubit, batteryCubit: batteryCubit));
}
