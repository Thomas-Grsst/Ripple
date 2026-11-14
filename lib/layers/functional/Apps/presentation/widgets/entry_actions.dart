import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import 'app_actions_sheet.dart';
import 'group_picker_sheet.dart';
import 'rename_dialog.dart';

Future<void> showEntryActions(BuildContext context, LauncherEntry entry) async {
  final LauncherCubit cubit = context.read<LauncherCubit>();
  final AppAction? action = await showAppActionsSheet(context, entry);
  if (!context.mounted || action == null) {
    return;
  }
  switch (action) {
    case AppAction.toggleFavorite:
      await cubit.toggleFavorite(entry.packageName);
    case AppAction.addToGroup:
      await showGroupPickerSheet(context, entry);
    case AppAction.rename:
      final String? name = await showRenameDialog(context, currentName: entry.displayName);
      if (name != null) {
        await cubit.rename(entry.packageName, name == entry.app.label ? '' : name);
      }
    case AppAction.hide:
      await cubit.hide(entry.packageName);
    case AppAction.appInfo:
      await cubit.openAppInfo(entry);
    case AppAction.uninstall:
      await cubit.uninstall(entry);
  }
}
