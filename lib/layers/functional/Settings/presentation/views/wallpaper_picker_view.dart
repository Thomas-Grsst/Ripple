import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../../../technical/Wallpapers/ripple_wallpaper.dart';
import '../../../../technical/Wallpapers/wallpaper_background.dart';
import '../cubit/settings_cubit.dart';

class WallpaperPickerView extends StatelessWidget {
  const WallpaperPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RippleColors.background,
      appBar: AppBar(title: const Text(RippleStrings.wallpaper)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
          final RippleWallpaper selected = RippleWallpaper.fromId(state.settings.wallpaperId);
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(RippleSpacing.md),
                sliver: SliverGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: RippleSpacing.md,
                  crossAxisSpacing: RippleSpacing.md,
                  childAspectRatio: 0.48,
                  children: <Widget>[
                    for (final RippleWallpaper wallpaper in RippleWallpaper.values)
                      _WallpaperTile(
                        wallpaper: wallpaper,
                        isSelected: wallpaper == selected,
                        onTap: () => context.read<SettingsCubit>().setWallpaper(wallpaper.id),
                      ),
                  ],
                ),
              ),
              if (selected.usesSystemWallpaper)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: RippleSpacing.md),
                    child: OutlinedButton.icon(
                      onPressed: context.read<SettingsCubit>().openWallpaperPicker,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text(RippleStrings.changeSystemWallpaper),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: RippleSpacing.xl + MediaQuery.paddingOf(context).bottom)),
            ],
          );
        },
      ),
    );
  }
}

class _WallpaperTile extends StatelessWidget {
  const _WallpaperTile({required this.wallpaper, required this.isSelected, required this.onTap});

  final RippleWallpaper wallpaper;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? RippleColors.accent : RippleColors.surfaceRaised, width: isSelected ? 2 : 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: wallpaper.usesSystemWallpaper ? const _SystemWallpaperPreview() : WallpaperBackground(wallpaper: wallpaper),
              ),
            ),
          ),
          const SizedBox(height: RippleSpacing.sm),
          Text(
            wallpaper.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: isSelected ? RippleColors.accent : RippleColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SystemWallpaperPreview extends StatelessWidget {
  const _SystemWallpaperPreview();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: RippleColors.surfaceRaised,
      child: Center(child: Icon(Icons.wallpaper_rounded, color: RippleColors.textSecondary, size: 32)),
    );
  }
}
