import 'package:flutter/material.dart';

import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_entry.dart';

enum AppRowSize {
  favorite(height: 58, iconSize: 34, fontSize: 21),
  regular(height: 50, iconSize: 28, fontSize: 17);

  const AppRowSize({required this.height, required this.iconSize, required this.fontSize});

  final double height;
  final double iconSize;
  final double fontSize;
}

class AppRow extends StatelessWidget {
  const AppRow({
    required this.entry,
    required this.size,
    required this.showIcon,
    required this.onTap,
    required this.onLongPress,
    super.key,
    this.leadingLetter,
    this.reserveLetterColumn = false,
  });

  final LauncherEntry entry;
  final AppRowSize size;
  final bool showIcon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String? leadingLetter;
  final bool reserveLetterColumn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RippleSpacing.sm),
          child: Row(
            children: <Widget>[
              if (reserveLetterColumn)
                SizedBox(
                  width: 22,
                  child: Text(leadingLetter ?? '', style: Theme.of(context).textTheme.labelMedium),
                ),
              if (showIcon) ...<Widget>[
                Image.memory(
                  entry.app.icon,
                  width: size.iconSize,
                  height: size.iconSize,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: (size.iconSize * MediaQuery.devicePixelRatioOf(context)).round(),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: size.fontSize, color: RippleColors.textPrimary, fontWeight: FontWeight.w400),
                ),
              ),
              if (entry.notificationCount > 0) _NotificationBadge(count: entry.notificationCount, compact: size == AppRowSize.regular),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count, required this.compact});

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.only(left: RippleSpacing.sm),
        decoration: const BoxDecoration(color: RippleColors.accent, shape: BoxShape.circle),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: RippleSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: RippleColors.accent, borderRadius: BorderRadius.circular(10)),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RippleColors.onAccent),
      ),
    );
  }
}
