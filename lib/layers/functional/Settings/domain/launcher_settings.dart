import 'package:equatable/equatable.dart';

class LauncherSettings extends Equatable {
  const LauncherSettings({this.wallpaperId = 'black', this.showIcons = true, this.weatherCity = ''});

  final String wallpaperId;
  final bool showIcons;
  final String weatherCity;

  LauncherSettings copyWith({String? wallpaperId, bool? showIcons, String? weatherCity}) {
    return LauncherSettings(
      wallpaperId: wallpaperId ?? this.wallpaperId,
      showIcons: showIcons ?? this.showIcons,
      weatherCity: weatherCity ?? this.weatherCity,
    );
  }

  @override
  List<Object?> get props => <Object?>[wallpaperId, showIcons, weatherCity];
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
