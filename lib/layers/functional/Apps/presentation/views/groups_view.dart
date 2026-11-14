import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/app_group.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';
import '../widgets/group_actions_sheet.dart';
import '../widgets/rename_dialog.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({required this.onEditGroupApps, super.key});

  final ValueChanged<AppGroup> onEditGroupApps;

  Future<void> _create(BuildContext context) async {
    final LauncherCubit cubit = context.read<LauncherCubit>();
    final String? name = await showTextPromptDialog(context, title: RippleStrings.newGroup, hint: RippleStrings.groupNameHint);
    if (name != null) {
      await cubit.createGroup(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RippleColors.background,
      appBar: AppBar(title: const Text(RippleStrings.groups)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: RippleColors.accent,
        foregroundColor: RippleColors.onAccent,
        onPressed: () => _create(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text(RippleStrings.newGroup),
      ),
      body: BlocBuilder<LauncherCubit, LauncherState>(
        builder: (BuildContext context, LauncherState state) {
          final List<AppGroup> groups = state.customization.groups;
          if (groups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(RippleSpacing.xl),
                child: Text(RippleStrings.noGroups, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: groups.length,
            onReorderItem: (int oldIndex, int newIndex) => context.read<LauncherCubit>().moveGroup(oldIndex, newIndex),
            itemBuilder: (BuildContext context, int index) {
              final AppGroup group = groups[index];
              return ListTile(
                key: ValueKey<String>(group.id),
                leading: const Icon(Icons.folder_outlined),
                title: Text(group.name),
                subtitle: Text('${group.packages.length} apps'),
                onTap: () => onEditGroupApps(group),
                onLongPress: () => showGroupActions(context, group, onEditApps: onEditGroupApps),
                trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle_rounded)),
              );
            },
          );
        },
      ),
    );
  }
}
