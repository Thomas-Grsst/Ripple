import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_state.dart';

class HomeFilterBar extends StatelessWidget {
  const HomeFilterBar({
    required this.filter,
    required this.groups,
    required this.onFavorites,
    required this.onGroup,
    required this.onManageGroup,
    required this.onCreateGroup,
    super.key,
  });

  final HomeFilter filter;
  final List<LauncherGroup> groups;
  final VoidCallback onFavorites;
  final ValueChanged<LauncherGroup> onGroup;
  final ValueChanged<LauncherGroup> onManageGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: RippleSpacing.md),
        children: <Widget>[
          _FilterPill(
            label: RippleStrings.favorites,
            icon: Icons.star_rounded,
            selected: filter is FavoritesFilter,
            onTap: onFavorites,
          ),
          for (final LauncherGroup group in groups)
            _FilterPill(
              label: group.group.name,
              selected: filter is GroupFilter && (filter as GroupFilter).groupId == group.group.id,
              hasNotification: group.entries.any((LauncherEntry entry) => entry.notificationCount > 0),
              onTap: () => onGroup(group),
              onLongPress: () => onManageGroup(group),
            ),
          _FilterPill(label: RippleStrings.newGroup, icon: Icons.add_rounded, selected: false, onTap: onCreateGroup, subtle: true),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.onLongPress,
    this.hasNotification = false,
    this.subtle = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final VoidCallback? onLongPress;
  final bool hasNotification;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? RippleColors.onAccent : (subtle ? RippleColors.textMuted : RippleColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(right: RippleSpacing.sm),
      child: Material(
        color: selected ? RippleColors.accent : RippleColors.surfaceRaised.withValues(alpha: subtle ? 0.35 : 0.7),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 16, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(label, style: TextStyle(fontSize: 14, color: foreground, fontWeight: FontWeight.w500)),
                if (hasNotification && !selected) ...<Widget>[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: RippleColors.accent, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
