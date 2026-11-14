import 'package:equatable/equatable.dart';

class BatteryStatus extends Equatable {
  const BatteryStatus({required this.level, required this.isCharging});

  final int level;
  final bool isCharging;

  @override
  List<Object?> get props => <Object?>[level, isCharging];
}

abstract interface class BatteryGateway {
  Future<BatteryStatus?> read();
}

class ReadBatteryStatus {
  const ReadBatteryStatus(this._gateway);

  final BatteryGateway _gateway;

  Future<BatteryStatus?> call() => _gateway.read();
}
