import '../entities/installed_app.dart';
import '../entities/launcher_device_event.dart';

abstract interface class LauncherDeviceGateway {
  Future<List<InstalledApp>> fetchInstalledApps();

  Future<bool> launch(String packageName);

  Future<void> openAppInfo(String packageName);

  Future<void> uninstall(String packageName);

  Future<void> expandNotifications();

  Stream<LauncherDeviceEvent> watch();
}
