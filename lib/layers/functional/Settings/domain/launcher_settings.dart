import 'package:equatable/equatable.dart';

class LauncherSettings extends Equatable {
  const LauncherSettings({this.wallpaperId = 'black', this.iconStyleId = 'monochrome', this.weatherCity = '', this.photoPath = ''});

  final String wallpaperId;
  final String iconStyleId;
  final String weatherCity;
  final String photoPath;

  LauncherSettings copyWith({String? wallpaperId, String? iconStyleId, String? weatherCity, String? photoPath}) {
    return LauncherSettings(
      wallpaperId: wallpaperId ?? this.wallpaperId,
      iconStyleId: iconStyleId ?? this.iconStyleId,
      weatherCity: weatherCity ?? this.weatherCity,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => <Object?>[wallpaperId, iconStyleId, weatherCity, photoPath];
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

abstract interface class WallpaperPhotoGateway {
  Future<String?> pickAndStore();
}

abstract interface class SystemIntegrationGateway {
  Future<SystemIntegrationStatus> status();

  Future<void> requestDefaultLauncher();

  Future<void> openNotificationAccess();

  Future<void> openRippleAppInfo();

  Future<void> openWallpaperPicker();
}
