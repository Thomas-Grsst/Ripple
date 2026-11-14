import '../../../technical/Device/device_bridge.dart';
import '../domain/battery_status.dart';

class DeviceBatteryGateway implements BatteryGateway {
  const DeviceBatteryGateway(this._bridge);

  final DeviceBridge _bridge;

  @override
  Future<BatteryStatus?> read() async {
    final Map<Object?, Object?> raw = await _bridge.getBattery();
    final Object? level = raw['level'];
    final Object? charging = raw['charging'];
    if (level is! int || level < 0) {
      return null;
    }
    return BatteryStatus(level: level, isCharging: charging is bool && charging);
  }
}
