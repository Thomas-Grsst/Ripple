import 'launcher_settings.dart';

class LoadLauncherSettings {
  const LoadLauncherSettings(this._gateway);

  final LauncherSettingsGateway _gateway;

  Future<LauncherSettings> call() => _gateway.load();
}

class SaveLauncherSettings {
  const SaveLauncherSettings(this._gateway);

  final LauncherSettingsGateway _gateway;

  Future<void> call(LauncherSettings settings) => _gateway.save(settings);
}

class ReadSystemIntegration {
  const ReadSystemIntegration(this._gateway);

  final SystemIntegrationGateway _gateway;

  Future<SystemIntegrationStatus> call() => _gateway.status();
}

class RequestDefaultLauncher {
  const RequestDefaultLauncher(this._gateway);

  final SystemIntegrationGateway _gateway;

  Future<void> call() => _gateway.requestDefaultLauncher();
}

class OpenNotificationAccess {
  const OpenNotificationAccess(this._gateway);

  final SystemIntegrationGateway _gateway;

  Future<void> call() => _gateway.openNotificationAccess();
}

class OpenRippleAppInfo {
  const OpenRippleAppInfo(this._gateway);

  final SystemIntegrationGateway _gateway;

  Future<void> call() => _gateway.openRippleAppInfo();
}

class PickWallpaperPhoto {
  const PickWallpaperPhoto(this._gateway);

  final WallpaperPhotoGateway _gateway;

  Future<String?> call() => _gateway.pickAndStore();
}

class OpenWallpaperPicker {
  const OpenWallpaperPicker(this._gateway);

  final SystemIntegrationGateway _gateway;

  Future<void> call() => _gateway.openWallpaperPicker();
}
