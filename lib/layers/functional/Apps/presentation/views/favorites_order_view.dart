import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';

class FavoritesOrderView extends StatelessWidget {
  const FavoritesOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RippleColors.background,
      appBar: AppBar(title: const Text(RippleStrings.favoritesOrder)),
      body: BlocBuilder<LauncherCubit, LauncherState>(
        builder: (BuildContext context, LauncherState state) {
          final List<LauncherEntry> favorites = state.catalog.favorites;
          if (favorites.isEmpty) {
            return Center(child: Text(RippleStrings.noFavorites, style: Theme.of(context).textTheme.bodyMedium));
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: RippleSpacing.sm),
            itemCount: favorites.length,
            onReorderItem: (int oldIndex, int target) {
              context.read<LauncherCubit>().moveFavorite(
                    state.customization.favorites.indexOf(favorites[oldIndex].packageName),
                    state.customization.favorites.indexOf(favorites[target].packageName),
                  );
            },
            itemBuilder: (BuildContext context, int index) {
              final LauncherEntry entry = favorites[index];
              return ListTile(
                key: ValueKey<String>(entry.packageName),
                leading: Image.memory(entry.app.icon, width: 32, height: 32),
                title: Text(entry.displayName),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle_rounded),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
