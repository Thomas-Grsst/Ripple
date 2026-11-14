import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/app_group.dart';
import '../../domain/entities/launcher_entry.dart';
import '../../domain/use_cases/search_launcher_entries.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';

class GroupEditorView extends StatefulWidget {
  const GroupEditorView({required this.groupId, super.key});

  final String groupId;

  @override
  State<GroupEditorView> createState() => _GroupEditorViewState();
}

class _GroupEditorViewState extends State<GroupEditorView> {
  final TextEditingController _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LauncherCubit, LauncherState>(
      builder: (BuildContext context, LauncherState state) {
        final AppGroup? group = state.customization.groups.where((AppGroup item) => item.id == widget.groupId).firstOrNull;
        if (group == null) {
          return const Scaffold(backgroundColor: RippleColors.background);
        }
        return Scaffold(
          backgroundColor: RippleColors.background,
          appBar: AppBar(title: Text('${group.name} · ${group.packages.length}')),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(RippleSpacing.md, RippleSpacing.sm, RippleSpacing.md, RippleSpacing.sm),
                child: TextField(
                  controller: _filterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: RippleStrings.filterApps,
                    prefixIcon: Icon(Icons.search_rounded, color: RippleColors.textSecondary),
                  ),
                ),
              ),
              Expanded(child: _buildList(context, state, group)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, LauncherState state, AppGroup group) {
    final String filter = _filterController.text;
    final List<LauncherEntry> entries =
        filter.trim().isEmpty ? state.catalog.visible : const SearchLauncherEntries()(state.catalog.visible, filter);
    final List<LauncherEntry> ordered = <LauncherEntry>[
      ...entries.where((LauncherEntry entry) => group.contains(entry.packageName)),
      ...entries.where((LauncherEntry entry) => !group.contains(entry.packageName)),
    ];
    return ListView.builder(
      itemCount: ordered.length,
      itemBuilder: (BuildContext context, int index) {
        final LauncherEntry entry = ordered[index];
        return CheckboxListTile(
          value: group.contains(entry.packageName),
          activeColor: RippleColors.accent,
          checkColor: RippleColors.onAccent,
          secondary: Image.memory(entry.app.icon, width: 32, height: 32),
          title: Text(entry.displayName),
          onChanged: (_) => context.read<LauncherCubit>().toggleGroupMember(group.id, entry.packageName),
        );
      },
    );
  }
}
