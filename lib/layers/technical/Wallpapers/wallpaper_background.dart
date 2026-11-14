import 'package:flutter/material.dart';

import '../Theme/ripple_colors.dart';
import 'ripple_wallpaper.dart';
import 'wallpaper_painters.dart';

class WallpaperBackground extends StatelessWidget {
  const WallpaperBackground({required this.wallpaper, super.key, this.withReadabilityScrim = true});

  final RippleWallpaper wallpaper;
  final bool withReadabilityScrim;

  @override
  Widget build(BuildContext context) {
    return switch (wallpaper) {
      RippleWallpaper.black => const ColoredBox(color: RippleColors.background, child: SizedBox.expand()),
      RippleWallpaper.system => const ColoredBox(color: RippleColors.wallpaperScrim, child: SizedBox.expand()),
      _ => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            RepaintBoundary(child: CustomPaint(painter: _painterFor(wallpaper))),
            if (withReadabilityScrim)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x66000000), Color(0x22000000), Color(0x22000000), Color(0x88000000)],
                    stops: <double>[0, 0.3, 0.7, 1],
                  ),
                ),
              ),
          ],
        ),
    };
  }

  CustomPainter _painterFor(RippleWallpaper wallpaper) {
    return switch (wallpaper) {
      RippleWallpaper.aurora => const AuroraPainter(),
      RippleWallpaper.dunes => const WavesPainter(
          background: Color(0xFF0E0A07),
          startHeight: 0.5,
          layers: <Color>[Color(0xFF3A2414), Color(0xFF5C3A1E), Color(0xFF8A5A2B), Color(0xFF6B4321), Color(0xFF2E1C10)],
        ),
      RippleWallpaper.tide => const WavesPainter(
          background: Color(0xFF030D16),
          startHeight: 0.4,
          layers: <Color>[Color(0xFF0A2540), Color(0xFF0C447C), Color(0xFF185FA5), Color(0xFF0F3A63), Color(0xFF051A2C)],
        ),
      RippleWallpaper.dusk => const DuskPainter(),
      RippleWallpaper.constellation => const ConstellationPainter(),
      _ => const RipplePainter(),
    };
  }
}
