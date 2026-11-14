import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../Theme/ripple_colors.dart';
import 'app_icon_style.dart';

class StyledAppIcon extends StatelessWidget {
  const StyledAppIcon({
    required this.icon,
    required this.style,
    required this.size,
    super.key,
    this.monochromeIcon,
  });

  static const List<double> _grayscale = <double>[
    0.2126, 0.7152, 0.0722, 0, 40,
    0.2126, 0.7152, 0.0722, 0, 40,
    0.2126, 0.7152, 0.0722, 0, 40,
    0, 0, 0, 1, 0,
  ];

  final Uint8List icon;
  final Uint8List? monochromeIcon;
  final AppIconStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final int cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return switch (style) {
      AppIconStyle.none => const SizedBox.shrink(),
      AppIconStyle.original => Image.memory(
          icon,
          width: size,
          height: size,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          cacheWidth: cacheSize,
        ),
      AppIconStyle.monochrome || AppIconStyle.accent => _ThemedTile(
          size: size,
          tint: style == AppIconStyle.accent ? RippleColors.accent : RippleColors.textPrimary,
          tileColor: style == AppIconStyle.accent ? const Color(0xFF0E1F1A) : const Color(0xFF161616),
          child: monochromeIcon != null
              ? Image.memory(
                  monochromeIcon!,
                  width: size,
                  height: size,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: cacheSize,
                  color: style == AppIconStyle.accent ? RippleColors.accent : RippleColors.textPrimary,
                  colorBlendMode: BlendMode.srcIn,
                )
              : Padding(
                  padding: EdgeInsets.all(size * 0.16),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(_grayscale),
                    child: Image.memory(icon, gaplessPlayback: true, cacheWidth: cacheSize),
                  ),
                ),
        ),
    };
  }
}

class _ThemedTile extends StatelessWidget {
  const _ThemedTile({required this.size, required this.tint, required this.tileColor, required this.child});

  final double size;
  final Color tint;
  final Color tileColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: tint.withValues(alpha: 0.18), width: 0.8),
      ),
      child: child,
    );
  }
}
