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

class AuroraPainter extends CustomPainter {
  const AuroraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF05080D));
    _glow(canvas, size, const Offset(0.15, 0.2), 1.0, const Color(0xFF1D9E75), 0.45);
    _glow(canvas, size, const Offset(0.95, 0.45), 0.95, const Color(0xFF534AB7), 0.45);
    _glow(canvas, size, const Offset(0.3, 0.95), 0.8, const Color(0xFF993556), 0.3);
  }

  void _glow(Canvas canvas, Size size, Offset relative, double radiusFactor, Color color, double alpha) {
    final Offset center = Offset(size.width * relative.dx, size.height * relative.dy);
    final double radius = size.width * radiusFactor;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(colors: <Color>[color.withValues(alpha: alpha), color.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) => false;
}

class WavesPainter extends CustomPainter {
  const WavesPainter({required this.background, required this.layers, this.startHeight = 0.45});

  final Color background;
  final List<Color> layers;
  final double startHeight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    for (int index = 0; index < layers.length; index++) {
      final double progress = index / layers.length;
      final double baseline = size.height * (startHeight + (1 - startHeight) * progress * 0.9);
      final double amplitude = size.height * (0.035 - progress * 0.015);
      final double wavelength = size.width * (1.6 - progress * 0.5);
      final double phase = index * 1.7;
      final Path path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += size.width / 60) {
        path.lineTo(x, baseline + math.sin(x / wavelength * 2 * math.pi + phase) * amplitude);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = layers[index]);
    }
  }

  @override
  bool shouldRepaint(WavesPainter oldDelegate) => false;
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

class ConstellationPainter extends CustomPainter {
  const ConstellationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF04060B));
    final math.Random random = math.Random(7);
    final double scale = size.shortestSide / 400;
    final List<Offset> stars = <Offset>[
      for (int index = 0; index < 160; index++) Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
    ];
    final Paint linePaint = Paint()
      ..color = const Color(0xFF85B7EB).withValues(alpha: 0.12)
      ..strokeWidth = math.max(0.4, scale * 0.6);
    for (int index = 0; index < 24; index++) {
      final Offset from = stars[index];
      final Offset to = stars[(index * 7 + 3) % 24];
      if ((from - to).distance < size.shortestSide * 0.45) {
        canvas.drawLine(from, to, linePaint);
      }
    }
    for (final Offset star in stars) {
      final double brightness = random.nextDouble();
      canvas.drawCircle(
        star,
        (0.4 + brightness * 1.4) * scale,
        Paint()..color = const Color(0xFFE6F1FB).withValues(alpha: 0.25 + brightness * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) => false;
}
