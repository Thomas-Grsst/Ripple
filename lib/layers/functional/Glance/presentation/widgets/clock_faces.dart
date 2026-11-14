import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../technical/Theme/ripple_colors.dart';
import 'glance_snapshot.dart';

class StackedClockFace extends StatelessWidget {
  const StackedClockFace({required this.snapshot, super.key});

  final GlanceSnapshot snapshot;

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
          style: GoogleFonts.outfit(fontSize: 15, color: RippleColors.textSecondary, fontWeight: FontWeight.w400),
          iconColor: RippleColors.textSecondary,
          leading: snapshot.shortDate,
        ),
      ],
    );
  }
}

class OutlineClockFace extends StatelessWidget {
  const OutlineClockFace({required this.snapshot, super.key});

  final GlanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final TextStyle info = GoogleFonts.spaceMono(fontSize: 14, letterSpacing: 2, color: RippleColors.accent);
    final List<String> parts = <String>[
      snapshot.time,
      snapshot.compactDate,
      ?snapshot.batteryText,
      if (snapshot.temperatureText != null) '${snapshot.temperatureText}C',
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
  const ColumnClockFace({required this.snapshot, super.key});

  final GlanceSnapshot snapshot;

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
              Text(snapshot.weekday.toUpperCase(), style: detail.copyWith(color: RippleColors.textPrimary, letterSpacing: 2)),
              Text('${snapshot.now.day} ${snapshot.month}', style: detail),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  if (snapshot.batteryText != null) ...<Widget>[
                    Icon(snapshot.batteryIcon, size: 15, color: RippleColors.accent),
                    const SizedBox(width: 3),
                    Text(snapshot.batteryText!, style: detail),
                    const SizedBox(width: 10),
                  ],
                  if (snapshot.temperatureText != null) ...<Widget>[
                    Icon(snapshot.weatherIcon, size: 15, color: RippleColors.accent),
                    const SizedBox(width: 3),
                    Text(snapshot.temperatureText!, style: detail),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClassicClockFace extends StatelessWidget {
  const ClassicClockFace({required this.snapshot, super.key});

  final GlanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(snapshot.time, style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(snapshot.longDate, style: const TextStyle(fontSize: 16, color: RippleColors.textSecondary)),
        const SizedBox(height: 8),
        _InfoRow(
          snapshot: snapshot,
          style: const TextStyle(fontSize: 15, color: RippleColors.accent),
          iconColor: RippleColors.accent,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.snapshot, required this.style, required this.iconColor, this.leading});

  final GlanceSnapshot snapshot;
  final TextStyle style;
  final Color iconColor;
  final String? leading;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[
      if (leading != null) Text(leading!, style: style),
      if (snapshot.batteryText != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(snapshot.batteryIcon, size: 16, color: iconColor),
            const SizedBox(width: 3),
            Text(snapshot.batteryText!, style: style),
          ],
        ),
      if (snapshot.temperatureText != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(snapshot.weatherIcon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(snapshot.temperatureText!, style: style),
          ],
        ),
    ];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      runSpacing: 4,
      children: items,
    );
  }
}
