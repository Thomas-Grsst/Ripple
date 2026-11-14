import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../technical/Theme/ripple_colors.dart';
import '../../domain/glance_layout.dart';
import 'glance_snapshot.dart';

class StackedClockFace extends StatelessWidget {
  const StackedClockFace({required this.snapshot, required this.items, super.key});

  final GlanceSnapshot snapshot;
  final List<GlanceItem> items;

  @override
  Widget build(BuildContext context) {
    final TextStyle digits = GoogleFonts.bebasNeue(fontSize: 128, height: 0.9, letterSpacing: -1, color: RippleColors.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(snapshot.hours, style: digits),
            const SizedBox(width: 6),
            Text(
              snapshot.minutes,
              style: digits.copyWith(
                color: null,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = RippleColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _InfoRow(
          snapshot: snapshot,
          items: items,
          style: GoogleFonts.outfit(fontSize: 15, color: RippleColors.textSecondary, fontWeight: FontWeight.w400),
          iconColor: RippleColors.textSecondary,
          date: snapshot.shortDate,
        ),
      ],
    );
  }
}

class OutlineClockFace extends StatelessWidget {
  const OutlineClockFace({required this.snapshot, required this.items, super.key});

  final GlanceSnapshot snapshot;
  final List<GlanceItem> items;

  @override
  Widget build(BuildContext context) {
    final TextStyle info = GoogleFonts.spaceMono(fontSize: 14, letterSpacing: 2, color: RippleColors.accent);
    final List<String> parts = <String>[
      snapshot.time,
      for (final GlanceItem item in items)
        ?switch (item) {
          GlanceItem.date => snapshot.compactDate,
          GlanceItem.battery => snapshot.batteryText,
          GlanceItem.weather => snapshot.temperatureText == null ? null : '${snapshot.temperatureText}C',
        },
    ];
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: -4,
            top: 0,
            child: Text(
              snapshot.weekdayTag,
              style: GoogleFonts.outfit(
                fontSize: 132,
                height: 1,
                fontWeight: FontWeight.w200,
                letterSpacing: 10,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.4
                  ..color = RippleColors.accent.withValues(alpha: 0.85),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 78,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.black.withValues(alpha: 0.35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[for (final String part in parts) Text(part, style: info)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColumnClockFace extends StatelessWidget {
  const ColumnClockFace({required this.snapshot, required this.items, super.key});

  final GlanceSnapshot snapshot;
  final List<GlanceItem> items;

  @override
  Widget build(BuildContext context) {
    final TextStyle detail = GoogleFonts.outfit(fontSize: 15, color: RippleColors.textSecondary);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            snapshot.time,
            style: GoogleFonts.outfit(fontSize: 78, fontWeight: FontWeight.w200, height: 1, color: RippleColors.textPrimary),
          ),
          Container(width: 2, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), color: RippleColors.accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (final GlanceItem item in items)
                if (item == GlanceItem.date) ...<Widget>[
                  Text(snapshot.weekday.toUpperCase(), style: detail.copyWith(color: RippleColors.textPrimary, letterSpacing: 2)),
                  Text('${snapshot.now.day} ${snapshot.month}', style: detail),
                ] else
                  ?_GlanceValue.of(item, snapshot: snapshot, style: detail, iconColor: RippleColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class ClassicClockFace extends StatelessWidget {
  const ClassicClockFace({required this.snapshot, required this.items, super.key});

  final GlanceSnapshot snapshot;
  final List<GlanceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(snapshot.time, style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        _InfoRow(
          snapshot: snapshot,
          items: items,
          style: const TextStyle(fontSize: 16, color: RippleColors.accent),
          iconColor: RippleColors.accent,
          date: snapshot.longDate,
          dateStyle: const TextStyle(fontSize: 16, color: RippleColors.textSecondary),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.snapshot,
    required this.items,
    required this.style,
    required this.iconColor,
    required this.date,
    this.dateStyle,
  });

  final GlanceSnapshot snapshot;
  final List<GlanceItem> items;
  final TextStyle style;
  final Color iconColor;
  final String date;
  final TextStyle? dateStyle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      runSpacing: 4,
      children: <Widget>[
        for (final GlanceItem item in items)
          if (item == GlanceItem.date)
            Text(date, style: dateStyle ?? style)
          else
            ?_GlanceValue.of(item, snapshot: snapshot, style: style, iconColor: iconColor),
      ],
    );
  }
}

class _GlanceValue extends StatelessWidget {
  const _GlanceValue({required this.icon, required this.text, required this.style, required this.iconColor});

  static _GlanceValue? of(GlanceItem item, {required GlanceSnapshot snapshot, required TextStyle style, required Color iconColor}) {
    final String? text = switch (item) {
      GlanceItem.date => null,
      GlanceItem.battery => snapshot.batteryText,
      GlanceItem.weather => snapshot.temperatureText,
    };
    if (text == null) {
      return null;
    }
    final IconData icon = item == GlanceItem.battery ? snapshot.batteryIcon : snapshot.weatherIcon;
    return _GlanceValue(icon: icon, text: text, style: style, iconColor: iconColor);
  }

  final IconData icon;
  final String text;
  final TextStyle style;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: (style.fontSize ?? 15) + 1, color: iconColor),
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}
