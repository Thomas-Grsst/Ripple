import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/glance_layout.dart';
import '../cubit/battery_cubit.dart';
import '../cubit/weather_cubit.dart';
import '../widgets/clock_style.dart';
import '../widgets/glance_header.dart';
import '../widgets/glance_snapshot.dart';

class ClockStylePickerView extends StatelessWidget {
  const ClockStylePickerView({
    required this.selected,
    required this.onSelected,
    required this.layout,
    required this.onLayoutChanged,
    super.key,
  });

  final ClockStyle selected;
  final ValueChanged<ClockStyle> onSelected;
  final GlanceLayout layout;
  final ValueChanged<GlanceLayout> onLayoutChanged;

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
          const _SectionLabel(RippleStrings.glanceOrder),
          const Padding(
            padding: EdgeInsets.only(bottom: RippleSpacing.sm),
            child: Text(RippleStrings.glanceOrderHint, style: TextStyle(fontSize: 13, color: RippleColors.textMuted)),
          ),
          _GlanceOrderList(layout: layout, onChanged: onLayoutChanged),
          const SizedBox(height: RippleSpacing.lg),
          const _SectionLabel(RippleStrings.glanceStyles),
          for (final ClockStyle style in ClockStyle.values)
            _ClockStyleCard(
              style: style,
              items: layout.visible,
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
  const _ClockStyleCard({required this.style, required this.items, required this.snapshot, required this.isSelected, required this.onTap});

  final ClockStyle style;
  final List<GlanceItem> items;
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
                    child: ClockFace(style: style, snapshot: snapshot, items: items),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RippleSpacing.sm),
      child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: RippleColors.accent)),
    );
  }
}

class _GlanceOrderList extends StatelessWidget {
  const _GlanceOrderList({required this.layout, required this.onChanged});

  final GlanceLayout layout;
  final ValueChanged<GlanceLayout> onChanged;

  static String _label(GlanceItem item) {
    return switch (item) {
      GlanceItem.date => RippleStrings.glanceDate,
      GlanceItem.battery => RippleStrings.glanceBattery,
      GlanceItem.weather => RippleStrings.glanceWeather,
    };
  }

  static IconData _icon(GlanceItem item) {
    return switch (item) {
      GlanceItem.date => Icons.calendar_today_outlined,
      GlanceItem.battery => Icons.battery_5_bar_rounded,
      GlanceItem.weather => Icons.wb_cloudy_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RippleColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorderItem: (int oldIndex, int newIndex) => onChanged(layout.move(oldIndex, newIndex)),
        children: <Widget>[
          for (final (int index, GlanceItem item) in layout.order.indexed)
            ListTile(
              key: ValueKey<GlanceItem>(item),
              tileColor: RippleColors.surface,
              leading: Checkbox(
                value: layout.isVisible(item),
                activeColor: RippleColors.accent,
                checkColor: RippleColors.onAccent,
                onChanged: (_) => onChanged(layout.toggle(item)),
              ),
              title: Text(
                _label(item),
                style: TextStyle(color: layout.isVisible(item) ? RippleColors.textPrimary : RippleColors.textMuted),
              ),
              trailing: ReorderableDragStartListener(
                index: index,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(_icon(item), size: 18, color: RippleColors.textMuted),
                    const SizedBox(width: RippleSpacing.md),
                    const Icon(Icons.drag_handle_rounded, color: RippleColors.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
