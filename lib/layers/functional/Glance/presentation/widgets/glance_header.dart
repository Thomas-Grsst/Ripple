import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../domain/weather_report.dart';
import '../cubit/weather_cubit.dart';

class GlanceHeader extends StatelessWidget {
  const GlanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _LiveClock(),
        SizedBox(height: 10),
        _WeatherLine(),
      ],
    );
  }
}

class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextTick();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hours = _now.hour.toString().padLeft(2, '0');
    final String minutes = _now.minute.toString().padLeft(2, '0');
    final String weekday = RippleStrings.weekdays[_now.weekday - 1];
    final String month = RippleStrings.months[_now.month - 1];
    final String date = '${weekday[0].toUpperCase()}${weekday.substring(1)} ${_now.day} $month';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$hours:$minutes', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(date, style: const TextStyle(fontSize: 16, color: RippleColors.textSecondary)),
      ],
    );
  }
}

class _WeatherLine extends StatelessWidget {
  const _WeatherLine();

  String _describe(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.clear => RippleStrings.weatherClear,
      WeatherCondition.partlyCloudy => RippleStrings.weatherPartlyCloudy,
      WeatherCondition.cloudy => RippleStrings.weatherCloudy,
      WeatherCondition.fog => RippleStrings.weatherFog,
      WeatherCondition.drizzle => RippleStrings.weatherDrizzle,
      WeatherCondition.rain => RippleStrings.weatherRain,
      WeatherCondition.snow => RippleStrings.weatherSnow,
      WeatherCondition.showers => RippleStrings.weatherShowers,
      WeatherCondition.storm => RippleStrings.weatherStorm,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (BuildContext context, WeatherState state) {
        final WeatherReport? report = state.report;
        if (report == null) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: context.read<WeatherCubit>().refresh,
          child: Text(
            '${report.temperature.round()}° · ${_describe(report.condition)} · ${report.city}',
            style: const TextStyle(fontSize: 15, color: RippleColors.accent),
          ),
        );
      },
    );
  }
}
