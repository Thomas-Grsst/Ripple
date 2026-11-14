import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_entry.dart';

enum AppAction { reorder, toggleFavorite, addToGroup, rename, hide, appInfo, uninstall }

Future<AppAction?> showAppActionsSheet(BuildContext context, LauncherEntry entry, {bool canReorder = false}) {
  return showModalBottomSheet<AppAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => _AppActionsSheet(entry: entry, canReorder: canReorder),
  );
}

class _AppActionsSheet extends StatelessWidget {
  const _AppActionsSheet({required this.entry, required this.canReorder});

  final LauncherEntry entry;
  final bool canReorder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(RippleSpacing.lg, 0, RippleSpacing.lg, RippleSpacing.md),
            child: Row(
              children: <Widget>[
                Image.memory(entry.app.icon, width: 40, height: 40),
                const SizedBox(width: RippleSpacing.md),
                Expanded(
                  child: Text(entry.displayName, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          if (canReorder) const _ActionTile(icon: Icons.swap_vert_rounded, label: RippleStrings.reorderApps, action: AppAction.reorder),
          _ActionTile(
            icon: entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            label: entry.isFavorite ? RippleStrings.removeFromFavorites : RippleStrings.addToFavorites,
            action: AppAction.toggleFavorite,
            highlighted: entry.isFavorite,
          ),
          const _ActionTile(icon: Icons.folder_outlined, label: RippleStrings.addToGroup, action: AppAction.addToGroup),
          const _ActionTile(icon: Icons.edit_outlined, label: RippleStrings.rename, action: AppAction.rename),
          const _ActionTile(icon: Icons.visibility_off_outlined, label: RippleStrings.hide, action: AppAction.hide),
          const _ActionTile(icon: Icons.info_outline_rounded, label: RippleStrings.appInfo, action: AppAction.appInfo),
          const _ActionTile(icon: Icons.delete_outline_rounded, label: RippleStrings.uninstall, action: AppAction.uninstall, danger: true),
          const SizedBox(height: RippleSpacing.sm),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.action,
    this.highlighted = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final AppAction action;
  final bool highlighted;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color color = danger ? RippleColors.danger : (highlighted ? RippleColors.accent : RippleColors.textPrimary);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: RippleSpacing.lg),
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      onTap: () => Navigator.of(context).pop(action),
    );
  }
}
