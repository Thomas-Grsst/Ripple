import 'package:equatable/equatable.dart';

class LauncherSettings extends Equatable {
  const LauncherSettings({this.showWallpaper = false, this.showIcons = true, this.weatherCity = ''});

  final bool showWallpaper;
  final bool showIcons;
  final String weatherCity;

  LauncherSettings copyWith({bool? showWallpaper, bool? showIcons, String? weatherCity}) {
    return LauncherSettings(
      showWallpaper: showWallpaper ?? this.showWallpaper,
      showIcons: showIcons ?? this.showIcons,
      weatherCity: weatherCity ?? this.weatherCity,
    );
  }

  @override
  List<Object?> get props => <Object?>[showWallpaper, showIcons, weatherCity];
}

class SystemIntegrationStatus extends Equatable {
  const SystemIntegrationStatus({this.isDefaultLauncher = false, this.hasNotificationAccess = false});

  final bool isDefaultLauncher;
  final bool hasNotificationAccess;

  @override
  List<Object?> get props => <Object?>[isDefaultLauncher, hasNotificationAccess];
}

abstract interface class LauncherSettingsGateway {
  Future<LauncherSettings> load();

  Future<void> save(LauncherSettings settings);
}

abstract interface class SystemIntegrationGateway {
  Future<SystemIntegrationStatus> status();

  Future<void> requestDefaultLauncher();

  Future<void> openNotificationAccess();

  Future<void> openWallpaperPicker();
}
