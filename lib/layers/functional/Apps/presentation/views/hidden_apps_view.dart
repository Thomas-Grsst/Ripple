import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';

class HiddenAppsView extends StatelessWidget {
  const HiddenAppsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RippleColors.background,
      appBar: AppBar(title: const Text(RippleStrings.hiddenApps)),
      body: BlocBuilder<LauncherCubit, LauncherState>(
        builder: (BuildContext context, LauncherState state) {
          final List<LauncherEntry> hidden = state.catalog.hidden;
          if (hidden.isEmpty) {
            return Center(child: Text(RippleStrings.noHiddenApps, style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView.builder(
            itemCount: hidden.length,
            itemBuilder: (BuildContext context, int index) {
              final LauncherEntry entry = hidden[index];
              return ListTile(
                leading: Image.memory(entry.app.icon, width: 32, height: 32),
                title: Text(entry.displayName),
                onTap: () => context.read<LauncherCubit>().launch(entry),
                trailing: TextButton(
                  onPressed: () => context.read<LauncherCubit>().unhide(entry.packageName),
                  child: const Text(RippleStrings.unhide),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
