import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ripple/layers/functional/Glance/domain/battery_status.dart';
import 'package:ripple/layers/functional/Glance/domain/weather_report.dart';
import 'package:ripple/layers/functional/Glance/presentation/widgets/clock_style.dart';
import 'package:ripple/layers/functional/Glance/presentation/widgets/glance_snapshot.dart';

void main() {
  final DateTime saturday = DateTime(2026, 11, 14, 9, 5);

  test('formats time and French dates for every clock face', () {
    final GlanceSnapshot snapshot = GlanceSnapshot(now: saturday);
    expect(snapshot.time, '09:05');
    expect(snapshot.longDate, 'Samedi 14 novembre');
    expect(snapshot.shortDate, 'Sam. 14 nov.');
    expect(snapshot.compactDate, '14 NOV');
    expect(snapshot.weekdayTag, 'SAM');
  });

  test('shows battery and temperature only when they are known', () {
    expect(GlanceSnapshot(now: saturday).batteryText, isNull);
    expect(GlanceSnapshot(now: saturday).temperatureText, isNull);

    final GlanceSnapshot snapshot = GlanceSnapshot(
      now: saturday,
      battery: const BatteryStatus(level: 69, isCharging: false),
      weather: const WeatherReport(city: 'Lyon', temperature: 6.6, condition: WeatherCondition.cloudy),
    );
    expect(snapshot.batteryText, '69%');
    expect(snapshot.temperatureText, '7°');
    expect(snapshot.weatherIcon, Icons.cloud_outlined);
  });

  test('uses a charging icon while plugged in', () {
    final GlanceSnapshot snapshot = GlanceSnapshot(now: saturday, battery: const BatteryStatus(level: 40, isCharging: true));
    expect(snapshot.batteryIcon, Icons.battery_charging_full_rounded);
  });

  test('unknown clock style ids fall back to the stacked face', () {
    expect(ClockStyle.fromId('unknown'), ClockStyle.stacked);
    expect(ClockStyle.fromId('outline'), ClockStyle.outline);
  });
}
