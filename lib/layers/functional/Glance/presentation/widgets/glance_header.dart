import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/battery_status.dart';
import '../cubit/battery_cubit.dart';
import '../cubit/weather_cubit.dart';
import 'clock_faces.dart';
import 'clock_style.dart';
import 'glance_snapshot.dart';

class GlanceHeader extends StatefulWidget {
  const GlanceHeader({required this.style, super.key});

  final ClockStyle style;

  @override
  State<GlanceHeader> createState() => _GlanceHeaderState();
}

class _GlanceHeaderState extends State<GlanceHeader> {
  DateTime _now = DateTime.now();
  Timer? _timer;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _scheduleNextTick();
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    setState(() => _now = DateTime.now());
    context.read<BatteryCubit>().refresh();
  }

  void _scheduleNextTick() {
    final DateTime now = DateTime.now();
    final Duration untilNextMinute = Duration(seconds: 60 - now.second, milliseconds: -now.millisecond);
    _timer = Timer(untilNextMinute, () {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
      _scheduleNextTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BatteryStatus? battery = context.watch<BatteryCubit>().state;
    final WeatherState weather = context.watch<WeatherCubit>().state;
    final GlanceSnapshot snapshot = GlanceSnapshot(now: _now, battery: battery, weather: weather.report);
    return GestureDetector(
      onTap: context.read<WeatherCubit>().refresh,
      child: ClockFace(style: widget.style, snapshot: snapshot),
    );
  }
}

class ClockFace extends StatelessWidget {
  const ClockFace({required this.style, required this.snapshot, super.key});

  final ClockStyle style;
  final GlanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      ClockStyle.stacked => StackedClockFace(snapshot: snapshot),
      ClockStyle.outline => OutlineClockFace(snapshot: snapshot),
      ClockStyle.column => ColumnClockFace(snapshot: snapshot),
      ClockStyle.classic => ClassicClockFace(snapshot: snapshot),
    };
  }
}
