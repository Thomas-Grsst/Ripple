import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../cubit/battery_cubit.dart';
import '../cubit/weather_cubit.dart';
import '../widgets/clock_style.dart';
import '../widgets/glance_header.dart';
import '../widgets/glance_snapshot.dart';

class ClockStylePickerView extends StatelessWidget {
  const ClockStylePickerView({required this.selected, required this.onSelected, super.key});

  final ClockStyle selected;
  final ValueChanged<ClockStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    final GlanceSnapshot snapshot = GlanceSnapshot(
      now: DateTime.now(),
      battery: context.watch<BatteryCubit>().state,
      weather: context.watch<WeatherCubit>().state.report,
    );
    return Scaffold(
      backgroundColor: RippleColors.background,
      appBar: AppBar(title: const Text(RippleStrings.clockStyle)),
      body: ListView(
        padding: const EdgeInsets.all(RippleSpacing.md),
        children: <Widget>[
          for (final ClockStyle style in ClockStyle.values)
            _ClockStyleCard(
              style: style,
              snapshot: snapshot,
              isSelected: style == selected,
              onTap: () {
                onSelected(style);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _ClockStyleCard extends StatelessWidget {
  const _ClockStyleCard({required this.style, required this.snapshot, required this.isSelected, required this.onTap});

  final ClockStyle style;
  final GlanceSnapshot snapshot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RippleSpacing.md),
      child: Material(
        color: RippleColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(RippleSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? RippleColors.accent : RippleColors.surfaceRaised, width: isSelected ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(style.label, style: TextStyle(fontSize: 14, color: isSelected ? RippleColors.accent : RippleColors.textSecondary)),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: RippleColors.accent, size: 20),
                  ],
                ),
                const SizedBox(height: RippleSpacing.md),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width - RippleSpacing.xl * 2.5,
                    child: ClockFace(style: style, snapshot: snapshot),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
