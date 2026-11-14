import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class RipplePainter extends CustomPainter {
  const RipplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF050807));
    final Offset center = Offset(size.width * 0.82, size.height * 0.92);
    final double maxRadius = size.longestSide * 1.1;
    final double step = size.shortestSide / 14;
    for (double radius = step; radius < maxRadius; radius += step) {
      final double fade = 1 - radius / maxRadius;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.6, size.shortestSide / 400)
          ..color = const Color(0xFF5DCAA5).withValues(alpha: 0.05 + 0.4 * fade * fade),
      );
    }
    canvas.drawCircle(
      center,
      step * 3,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[const Color(0xFF1D9E75).withValues(alpha: 0.35), const Color(0x001D9E75)],
        ).createShader(Rect.fromCircle(center: center, radius: step * 3)),
    );
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => false;
}



class DuskPainter extends CustomPainter {
  const DuskPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF07060F), Color(0xFF1E1A45), Color(0xFF6B2A3A), Color(0xFFB4532B)],
          stops: <double>[0, 0.45, 0.72, 0.84],
        ).createShader(bounds),
    );
    final Offset sun = Offset(size.width * 0.5, size.height * 0.8);
    canvas.drawCircle(sun, size.width * 0.16, Paint()..color = const Color(0xFFF0997B).withValues(alpha: 0.85));
    canvas.drawRect(
      Rect.fromLTRB(0, size.height * 0.84, size.width, size.height),
      Paint()..color = const Color(0xFF0B0709),
    );
  }

  @override
  bool shouldRepaint(DuskPainter oldDelegate) => false;
}

