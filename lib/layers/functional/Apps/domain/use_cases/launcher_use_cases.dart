import '../entities/app_customization.dart';
import '../entities/installed_app.dart';
import '../entities/launcher_device_event.dart';
import '../gateways/app_customization_gateway.dart';
import '../gateways/launcher_device_gateway.dart';

class FetchInstalledApps {
  const FetchInstalledApps(this._gateway);

  final LauncherDeviceGateway _gateway;

  Future<List<InstalledApp>> call() => _gateway.fetchInstalledApps();
}

class LaunchApp {
  const LaunchApp(this._gateway);

  final LauncherDeviceGateway _gateway;

  Future<bool> call(String packageName) => _gateway.launch(packageName);
}

class OpenAppInfo {
  const OpenAppInfo(this._gateway);

  final LauncherDeviceGateway _gateway;

  Future<void> call(String packageName) => _gateway.openAppInfo(packageName);
}

class UninstallApp {
  const UninstallApp(this._gateway);

  final LauncherDeviceGateway _gateway;

  Future<void> call(String packageName) => _gateway.uninstall(packageName);
}

class ExpandNotificationShade {
  const ExpandNotificationShade(this._gateway);

  final LauncherDeviceGateway _gateway;

  Future<void> call() => _gateway.expandNotifications();
}

class WatchLauncherDevice {
  const WatchLauncherDevice(this._gateway);

  final LauncherDeviceGateway _gateway;

  Stream<LauncherDeviceEvent> call() => _gateway.watch();
}

class LoadAppCustomization {
  const LoadAppCustomization(this._gateway);

  final AppCustomizationGateway _gateway;

  Future<AppCustomization> call() => _gateway.load();
}

class SaveAppCustomization {
  const SaveAppCustomization(this._gateway);

  final AppCustomizationGateway _gateway;

  Future<void> call(AppCustomization customization) => _gateway.save(customization);
}
