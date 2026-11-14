import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../domain/battery_status.dart';
import '../../domain/weather_report.dart';

class GlanceSnapshot {
  const GlanceSnapshot({required this.now, this.battery, this.weather});

  static const List<String> _shortWeekdays = <String>['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
  static const List<String> _shortMonths = <String>[
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  final DateTime now;
  final BatteryStatus? battery;
  final WeatherReport? weather;

  String get hours => now.hour.toString().padLeft(2, '0');

  String get minutes => now.minute.toString().padLeft(2, '0');

  String get time => '$hours:$minutes';

  String get weekday => RippleStrings.weekdays[now.weekday - 1];

  String get weekdayShort => _shortWeekdays[now.weekday - 1];

  String get weekdayTag => weekdayShort.replaceAll('.', '').toUpperCase();

  String get month => RippleStrings.months[now.month - 1];

  String get monthShort => _shortMonths[now.month - 1];

  String get longDate => '${_capitalize(weekday)} ${now.day} $month';

  String get shortDate => '${_capitalize(weekdayShort)} ${now.day} $monthShort';

  String get compactDate => '${now.day} ${monthShort.replaceAll('.', '').toUpperCase()}';

  String? get batteryText => battery == null ? null : '${battery!.level}%';

  String? get temperatureText => weather == null ? null : '${weather!.temperature.round()}°';

  IconData get batteryIcon {
    final BatteryStatus? status = battery;
    if (status == null) {
      return Icons.battery_unknown_rounded;
    }
    if (status.isCharging) {
      return Icons.battery_charging_full_rounded;
    }
    return switch (status.level) {
      >= 90 => Icons.battery_full_rounded,
      >= 60 => Icons.battery_5_bar_rounded,
      >= 35 => Icons.battery_3_bar_rounded,
      >= 15 => Icons.battery_2_bar_rounded,
      _ => Icons.battery_alert_rounded,
    };
  }

  IconData get weatherIcon {
    return switch (weather?.condition) {
      WeatherCondition.clear => Icons.wb_sunny_outlined,
      WeatherCondition.partlyCloudy => Icons.filter_drama_outlined,
      WeatherCondition.cloudy => Icons.cloud_outlined,
      WeatherCondition.fog => Icons.foggy,
      WeatherCondition.drizzle || WeatherCondition.rain || WeatherCondition.showers => Icons.water_drop_outlined,
      WeatherCondition.snow => Icons.ac_unit_rounded,
      WeatherCondition.storm => Icons.thunderstorm_outlined,
      null => Icons.cloud_off_outlined,
    };
  }

  static String _capitalize(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
