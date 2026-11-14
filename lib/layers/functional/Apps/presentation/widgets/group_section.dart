import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_entry.dart';
import 'app_row.dart';

class GroupSection extends StatelessWidget {
  const GroupSection({
    required this.group,
    required this.showIcons,
    required this.onToggle,
    required this.onManage,
    required this.onTapEntry,
    required this.onLongPressEntry,
    super.key,
  });

  final LauncherGroup group;
  final bool showIcons;
  final VoidCallback onToggle;
  final VoidCallback onManage;
  final ValueChanged<LauncherEntry> onTapEntry;
  final ValueChanged<LauncherEntry> onLongPressEntry;

  @override
  Widget build(BuildContext context) {
    final bool expanded = group.group.isExpanded;
    final int notifications = group.entries.fold(0, (int total, LauncherEntry entry) => total + entry.notificationCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: onToggle,
          onLongPress: onManage,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, RippleSpacing.md, RippleSpacing.sm, RippleSpacing.sm),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    group.group.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: RippleColors.textSecondary),
                  ),
                ),
                if (!expanded && notifications > 0)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: RippleSpacing.sm),
                    decoration: const BoxDecoration(color: RippleColors.accent, shape: BoxShape.circle),
                  ),
                Text('${group.entries.length}', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(width: RippleSpacing.xs),
                AnimatedRotation(
                  turns: expanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded, size: 18, color: RippleColors.textMuted),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded ? _buildEntries(context) : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildEntries(BuildContext context) {
    if (group.entries.isEmpty) {
      return GestureDetector(
        onTap: onManage,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RippleSpacing.sm, vertical: RippleSpacing.sm),
          child: Text(RippleStrings.emptyGroup, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    return Column(
      children: <Widget>[
        for (final LauncherEntry entry in group.entries)
          AppRow(
            entry: entry,
            size: AppRowSize.favorite,
            showIcon: showIcons,
            onTap: () => onTapEntry(entry),
            onLongPress: () => onLongPressEntry(entry),
          ),
      ],
    );
  }
}
