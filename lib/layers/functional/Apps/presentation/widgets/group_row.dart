import 'package:flutter/material.dart';

import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_entry.dart';
import 'app_row.dart';

class GroupRow extends StatelessWidget {
  const GroupRow({required this.group, required this.onTap, required this.onLongPress, super.key});

  final LauncherGroup group;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool hasNotification = group.entries.any((LauncherEntry entry) => entry.notificationCount > 0);
    return _FolderLikeRow(
      icon: Icons.folder_outlined,
      label: group.group.name,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasNotification)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: RippleSpacing.sm),
              decoration: const BoxDecoration(color: RippleColors.accent, shape: BoxShape.circle),
            ),
          Text('${group.entries.length}', style: Theme.of(context).textTheme.labelMedium),
          const Icon(Icons.chevron_right_rounded, color: RippleColors.textMuted),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class NewGroupRow extends StatelessWidget {
  const NewGroupRow({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FolderLikeRow(icon: Icons.add_rounded, label: label, onTap: onTap, muted: true);
  }
}

class _FolderLikeRow extends StatelessWidget {
  const _FolderLikeRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.trailing,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final double tileSize = AppRowSize.favorite.iconSize;
    final Color color = muted ? RippleColors.textSecondary : RippleColors.accent;
    return SizedBox(
      height: AppRowSize.favorite.height,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RippleSpacing.sm),
          child: Row(
            children: <Widget>[
              Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1F1A),
                  borderRadius: BorderRadius.circular(tileSize * 0.3),
                  border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Icon(icon, color: color, size: tileSize * 0.55),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppRowSize.favorite.fontSize,
                    color: muted ? RippleColors.textSecondary : RippleColors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
