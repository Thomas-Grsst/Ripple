import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/battery_status.dart';

class BatteryCubit extends Cubit<BatteryStatus?> {
  BatteryCubit(this._readBatteryStatus, {this.refreshInterval = const Duration(minutes: 1)}) : super(null);

  final ReadBatteryStatus _readBatteryStatus;
  final Duration refreshInterval;
  Timer? _timer;

  Future<void> start() async {
    _timer ??= Timer.periodic(refreshInterval, (_) => refresh());
    await refresh();
  }

  Future<void> refresh() async {
    try {
      emit(await _readBatteryStatus());
    } on PlatformException {
      emit(null);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
