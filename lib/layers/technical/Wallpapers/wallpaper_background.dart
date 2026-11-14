import 'dart:io';

import 'package:flutter/material.dart';

import '../Theme/ripple_colors.dart';
import 'landscape_painters.dart';
import 'ripple_wallpaper.dart';
import 'wallpaper_painters.dart';

class WallpaperBackground extends StatelessWidget {
  const WallpaperBackground({
    required this.wallpaper,
    super.key,
    this.photoPath = '',
    this.withReadabilityScrim = true,
  });

  final RippleWallpaper wallpaper;
  final String photoPath;
  final bool withReadabilityScrim;

  @override
  Widget build(BuildContext context) {
    return switch (wallpaper) {
      RippleWallpaper.black => const ColoredBox(color: RippleColors.background, child: SizedBox.expand()),
      RippleWallpaper.system => const ColoredBox(color: RippleColors.wallpaperScrim, child: SizedBox.expand()),
      RippleWallpaper.photo => _withScrim(_buildPhoto(context)),
      _ => _withScrim(RepaintBoundary(child: CustomPaint(painter: _painterFor(wallpaper)))),
    };
  }

  Widget _buildPhoto(BuildContext context) {
    if (photoPath.isEmpty) {
      return const ColoredBox(color: RippleColors.background);
    }
    final Size screen = MediaQuery.sizeOf(context);
    final double ratio = MediaQuery.devicePixelRatioOf(context);
    return Image(
      image: ResizeImage(FileImage(File(photoPath)), height: (screen.height * ratio).round(), policy: ResizeImagePolicy.fit),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const ColoredBox(color: RippleColors.background),
    );
  }

  Widget _withScrim(Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        child,
        if (withReadabilityScrim)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x73000000), Color(0x1A000000), Color(0x40000000), Color(0x99000000)],
                stops: <double>[0, 0.3, 0.65, 1],
              ),
            ),
          ),
      ],
    );
  }

  CustomPainter _painterFor(RippleWallpaper wallpaper) {
    return switch (wallpaper) {
      RippleWallpaper.peaks => const PeaksPainter(),
      RippleWallpaper.milkyWay => const MilkyWayPainter(),
      RippleWallpaper.ocean => const OceanPainter(),
      RippleWallpaper.northernLights => const NorthernLightsPainter(),
      RippleWallpaper.dusk => const DuskPainter(),
      _ => const RipplePainter(),
    };
  }
}
