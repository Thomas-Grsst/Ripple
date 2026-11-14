import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/app_group.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';
import 'rename_dialog.dart';

Future<void> showGroupPickerSheet(BuildContext context, LauncherEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => BlocProvider<LauncherCubit>.value(
      value: context.read<LauncherCubit>(),
      child: _GroupPickerSheet(entry: entry),
    ),
  );
}

class _GroupPickerSheet extends StatelessWidget {
  const _GroupPickerSheet({required this.entry});

  final LauncherEntry entry;

  Future<void> _createGroup(BuildContext context) async {
    final LauncherCubit cubit = context.read<LauncherCubit>();
    final String? name = await showTextPromptDialog(context, title: RippleStrings.newGroup, hint: RippleStrings.groupNameHint);
    if (name != null) {
      await cubit.createGroup(name, packages: <String>[entry.packageName]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<LauncherCubit, LauncherState>(
        builder: (BuildContext context, LauncherState state) {
          final List<AppGroup> groups = state.customization.groups;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(RippleSpacing.lg, 0, RippleSpacing.lg, RippleSpacing.sm),
                child: Text('${RippleStrings.addToGroup} · ${entry.displayName}', style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final AppGroup group in groups)
                CheckboxListTile(
                  value: group.contains(entry.packageName),
                  activeColor: RippleColors.accent,
                  checkColor: RippleColors.onAccent,
                  title: Text(group.name),
                  secondary: const Icon(Icons.folder_outlined),
                  onChanged: (_) => context.read<LauncherCubit>().toggleGroupMember(group.id, entry.packageName),
                ),
              ListTile(
                leading: const Icon(Icons.create_new_folder_outlined, color: RippleColors.accent),
                title: const Text(RippleStrings.newGroup, style: TextStyle(color: RippleColors.accent)),
                onTap: () => _createGroup(context),
              ),
              const SizedBox(height: RippleSpacing.sm),
            ],
          );
        },
      ),
    );
  }
}
