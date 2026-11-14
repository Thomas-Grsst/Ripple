import 'dart:typed_data';

import '../../../../technical/Device/device_bridge.dart';
import '../../domain/entities/installed_app.dart';
import '../../domain/entities/launcher_device_event.dart';
import '../../domain/gateways/launcher_device_gateway.dart';

class DeviceLauncherGateway implements LauncherDeviceGateway {
  const DeviceLauncherGateway(this._bridge, {this.iconSize = 144});

  final DeviceBridge _bridge;
  final int iconSize;

  @override
  Future<List<InstalledApp>> fetchInstalledApps() async {
    final List<Map<Object?, Object?>> raw = await _bridge.getApps(iconSize: iconSize);
    return raw.map(_toInstalledApp).whereType<InstalledApp>().toList(growable: false);
  }

  @override
  Future<bool> launch(String packageName) => _bridge.launch(packageName);

  @override
  Future<void> openAppInfo(String packageName) => _bridge.openAppInfo(packageName);

  @override
  Future<void> uninstall(String packageName) => _bridge.uninstall(packageName);

  @override
  Future<void> expandNotifications() => _bridge.expandNotifications();

  @override
  Stream<LauncherDeviceEvent> watch() {
    return _bridge.events.map(_toLauncherEvent).where((LauncherDeviceEvent? event) => event != null).cast<LauncherDeviceEvent>();
  }

  InstalledApp? _toInstalledApp(Map<Object?, Object?> raw) {
    final Object? packageName = raw['package'];
    final Object? label = raw['label'];
    final Object? icon = raw['icon'];
    if (packageName is! String || label is! String || icon is! Uint8List) {
      return null;
    }
    return InstalledApp(packageName: packageName, label: label, icon: icon);
  }

  LauncherDeviceEvent? _toLauncherEvent(DeviceEvent event) {
    return switch (event) {
      HomePressedEvent() => const HomeRequested(),
      PackagesChangedEvent() => const InstalledAppsChanged(),
      NotificationCountsEvent(:final Map<String, int> counts) => NotificationCountsUpdated(counts),
      UnknownDeviceEvent() => null,
    };
  }
}
