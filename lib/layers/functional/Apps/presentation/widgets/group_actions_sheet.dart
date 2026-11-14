import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../domain/entities/app_group.dart';
import '../cubit/launcher_cubit.dart';
import 'rename_dialog.dart';

enum GroupAction { editApps, rename, delete }

Future<void> showGroupActions(
  BuildContext context,
  AppGroup group, {
  required void Function(AppGroup group) onEditApps,
}) async {
  final LauncherCubit cubit = context.read<LauncherCubit>();
  final GroupAction? action = await showModalBottomSheet<GroupAction>(
    context: context,
    builder: (BuildContext context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(group.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.checklist_rounded),
            title: const Text(RippleStrings.editGroupApps),
            onTap: () => Navigator.of(context).pop(GroupAction.editApps),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text(RippleStrings.renameGroup),
            onTap: () => Navigator.of(context).pop(GroupAction.rename),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: RippleColors.danger),
            title: const Text(RippleStrings.deleteGroup, style: TextStyle(color: RippleColors.danger)),
            onTap: () => Navigator.of(context).pop(GroupAction.delete),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) {
    return;
  }
  switch (action) {
    case GroupAction.editApps:
      onEditApps(group);
    case GroupAction.rename:
      final String? name = await showTextPromptDialog(context, title: RippleStrings.renameGroup, initialValue: group.name);
      if (name != null) {
        await cubit.renameGroup(group.id, name);
      }
    case GroupAction.delete:
      final bool confirmed = await _confirmDelete(context, group);
      if (confirmed) {
        await cubit.deleteGroup(group.id);
      }
  }
}

Future<bool> _confirmDelete(BuildContext context, AppGroup group) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('${RippleStrings.deleteGroup} « ${group.name} » ?'),
      content: const Text(RippleStrings.deleteGroupConfirm),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text(RippleStrings.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: RippleColors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(RippleStrings.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
