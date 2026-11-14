import 'dart:math' as math;

import 'package:flutter/rendering.dart';

Path _ridge(Size size, {required double baseline, required double roughness, required int seed, double detail = 56}) {
  final math.Random random = math.Random(seed);
  final double phaseA = random.nextDouble() * math.pi * 2;
  final double phaseB = random.nextDouble() * math.pi * 2;
  final Path path = Path()..moveTo(0, size.height);
  double jitter = 0;
  for (int index = 0; index <= detail; index++) {
    final double x = size.width * index / detail;
    jitter = jitter * 0.6 + (random.nextDouble() - 0.5) * roughness * 0.5;
    final double wave = math.sin(x / size.width * math.pi * 2.2 + phaseA) * roughness +
        math.sin(x / size.width * math.pi * 5.3 + phaseB) * roughness * 0.45;
    path.lineTo(x, baseline - wave.abs() - jitter.abs() * 1.6);
  }
  return path
    ..lineTo(size.width, size.height)
    ..close();
}

void _fillVertical(Canvas canvas, Rect rect, List<Color> colors, List<double> stops) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ).createShader(rect),
  );
}

void _stars(Canvas canvas, Size size, {required int count, required int seed, double maxY = 1, double brightness = 1}) {
  final math.Random random = math.Random(seed);
  final double scale = size.shortestSide / 400;
  for (int index = 0; index < count; index++) {
    final Offset star = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height * maxY);
    final double glow = random.nextDouble();
    canvas.drawCircle(
      star,
      (0.35 + glow * glow * 1.4) * scale,
      Paint()..color = const Color(0xFFF4F1FF).withValues(alpha: (0.2 + glow * 0.75) * brightness),
    );
  }
}

class PeaksPainter extends CustomPainter {
  const PeaksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    _fillVertical(
      canvas,
      bounds,
      const <Color>[Color(0xFF1B1446), Color(0xFF4B2C82), Color(0xFFB0507A), Color(0xFFF2A65A), Color(0xFFFFD58A)],
      const <double>[0, 0.28, 0.48, 0.6, 0.66],
    );
    _stars(canvas, size, count: 70, seed: 3, maxY: 0.3, brightness: 0.7);

    final Offset sun = Offset(size.width * 0.62, size.height * 0.58);
    canvas.drawCircle(
      sun,
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[const Color(0xFFFFE3A3).withValues(alpha: 0.75), const Color(0x00FFB36B)],
        ).createShader(Rect.fromCircle(center: sun, radius: size.width * 0.55)),
    );
    canvas.drawCircle(sun, size.width * 0.075, Paint()..color = const Color(0xFFFFF1CF));

    final Paint cloud = Paint()
      ..color = const Color(0xFFFFC98B).withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.3, size.height * 0.4), width: size.width * 0.7, height: size.height * 0.03), cloud);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.75, size.height * 0.46), width: size.width * 0.6, height: size.height * 0.022), cloud);

    const List<Color> ranges = <Color>[Color(0xFF8C5A9E), Color(0xFF5E3C7E), Color(0xFF392459), Color(0xFF1C1233), Color(0xFF0A0614)];
    for (int index = 0; index < ranges.length; index++) {
      final double baseline = size.height * (0.62 + index * 0.075);
      final Path ridge = _ridge(size, baseline: baseline, roughness: size.height * (0.07 - index * 0.008), seed: 11 + index * 7);
      canvas.drawPath(ridge, Paint()..color = ranges[index]);
      if (index == 0) {
        canvas.drawPath(
          ridge,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.shortestSide / 260
            ..color = const Color(0xFFFFE0C2).withValues(alpha: 0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(PeaksPainter oldDelegate) => false;
}

class MilkyWayPainter extends CustomPainter {
  const MilkyWayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    _fillVertical(canvas, bounds, const <Color>[Color(0xFF02030A), Color(0xFF0B1230), Color(0xFF1A1F45)], const <double>[0, 0.6, 1]);

    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.42);
    canvas.rotate(-0.55);
    final Rect band = Rect.fromCenter(center: Offset.zero, width: size.longestSide * 1.6, height: size.width * 0.5);
    canvas.drawOval(
      band,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[const Color(0xFFB9A7FF).withValues(alpha: 0.32), const Color(0xFF5D6BD8).withValues(alpha: 0.12), const Color(0x00000000)],
          stops: const <double>[0, 0.45, 1],
        ).createShader(band)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.04),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.05, 0), width: size.longestSide * 1.1, height: size.width * 0.07),
      Paint()
        ..color = const Color(0xFF02030A).withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03),
    );
    final math.Random random = math.Random(21);
    final double scale = size.shortestSide / 400;
    for (int index = 0; index < 900; index++) {
      final double along = (random.nextDouble() - 0.5) * size.longestSide * 1.5;
      final double spread = (random.nextDouble() + random.nextDouble() + random.nextDouble() - 1.5) * size.width * 0.16;
      canvas.drawCircle(
        Offset(along, spread),
        (0.25 + random.nextDouble() * 0.7) * scale,
        Paint()..color = const Color(0xFFEDE8FF).withValues(alpha: 0.25 + random.nextDouble() * 0.6),
      );
    }
    canvas.restore();

    _stars(canvas, size, count: 260, seed: 5, maxY: 0.85);
    canvas.drawPath(
      _ridge(size, baseline: size.height * 0.9, roughness: size.height * 0.03, seed: 4, detail: 90),
      Paint()..color = const Color(0xFF020308),
    );
  }

  @override
  bool shouldRepaint(MilkyWayPainter oldDelegate) => false;
}

class OceanPainter extends CustomPainter {
  const OceanPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    _fillVertical(
      canvas,
      bounds,
      const <Color>[Color(0xFF021418), Color(0xFF053238), Color(0xFF0B5A5C), Color(0xFF0E7A73)],
      const <double>[0, 0.35, 0.7, 1],
    );
    final math.Random random = math.Random(9);
    for (int line = 0; line < 26; line++) {
      final double progress = line / 26;
      final double baseY = size.height * (-0.1 + progress * 1.2);
      final double amplitude = size.height * (0.012 + random.nextDouble() * 0.02);
      final double wavelength = size.width * (0.35 + random.nextDouble() * 0.4);
      final double phase = random.nextDouble() * math.pi * 2;
      final double tilt = size.height * 0.18;
      final Path crest = Path();
      for (double x = -10; x <= size.width + 10; x += size.width / 80) {
        final double y = baseY +
            math.sin(x / wavelength * math.pi * 2 + phase) * amplitude +
            math.sin(x / (wavelength * 0.37) + phase * 1.7) * amplitude * 0.35 -
            x / size.width * tilt;
        if (x <= -10) {
          crest.moveTo(x, y);
        } else {
          crest.lineTo(x, y);
        }
      }
      final double foam = 0.08 + random.nextDouble() * 0.3 * progress + 0.05;
      canvas.drawPath(
        crest,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * (0.006 + random.nextDouble() * 0.02)
          ..color = const Color(0xFFE8FFFB).withValues(alpha: foam.clamp(0, 0.55))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.shortestSide * 0.006),
      );
      canvas.drawPath(
        crest,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.002
          ..color = const Color(0xFFFFFFFF).withValues(alpha: (foam * 1.4).clamp(0, 0.7)),
      );
    }
    final Rect shade = bounds;
    canvas.drawRect(
      shade,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.7),
          radius: 1.2,
          colors: <Color>[Color(0x00000000), Color(0x99010A0C)],
        ).createShader(shade),
    );
  }

  @override
  bool shouldRepaint(OceanPainter oldDelegate) => false;
}

class NorthernLightsPainter extends CustomPainter {
  const NorthernLightsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    _fillVertical(canvas, bounds, const <Color>[Color(0xFF020611), Color(0xFF061428), Color(0xFF0B2236)], const <double>[0, 0.55, 1]);
    _stars(canvas, size, count: 180, seed: 13, maxY: 0.7);

    final math.Random random = math.Random(31);
    for (int curtain = 0; curtain < 5; curtain++) {
      final double startX = size.width * (-0.2 + curtain * 0.3 + random.nextDouble() * 0.1);
      final double top = size.height * (0.12 + random.nextDouble() * 0.12);
      final double bottom = size.height * (0.5 + random.nextDouble() * 0.12);
      final Color color = curtain.isEven ? const Color(0xFF3DF5B0) : const Color(0xFF8A7CFF);
      final Path ribbon = Path()..moveTo(startX, bottom);
      for (double t = 0; t <= 1.0001; t += 0.05) {
        final double x = startX + t * size.width * 0.7;
        final double y = bottom - math.sin(t * math.pi) * size.height * 0.08 + math.sin(t * 9 + curtain) * size.height * 0.012;
        ribbon.lineTo(x, y);
      }
      for (double t = 1; t >= -0.0001; t -= 0.05) {
        final double x = startX + t * size.width * 0.7 + size.width * 0.05;
        final double y = top + math.sin(t * 7 + curtain * 2) * size.height * 0.03;
        ribbon.lineTo(x, y);
      }
      ribbon.close();
      final Rect area = ribbon.getBounds();
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[color.withValues(alpha: 0.55), color.withValues(alpha: 0.18), color.withValues(alpha: 0)],
          ).createShader(area)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03),
      );
    }

    const List<Color> ranges = <Color>[Color(0xFF0D2233), Color(0xFF07131F), Color(0xFF02070D)];
    for (int index = 0; index < ranges.length; index++) {
      canvas.drawPath(
        _ridge(size, baseline: size.height * (0.72 + index * 0.08), roughness: size.height * (0.06 - index * 0.012), seed: 40 + index),
        Paint()..color = ranges[index],
      );
    }
  }

  @override
  bool shouldRepaint(NorthernLightsPainter oldDelegate) => false;
}
