import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../../../technical/Wallpapers/ripple_wallpaper.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/notification_access_sheet.dart';
import 'wallpaper_picker_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    required this.onOpenFavoritesOrder,
    required this.onOpenGroups,
    required this.onOpenHiddenApps,
    super.key,
  });

  final VoidCallback onOpenFavoritesOrder;
  final VoidCallback onOpenGroups;
  final VoidCallback onOpenHiddenApps;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: () => context.read<SettingsCubit>().refreshIntegration());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _editCity(BuildContext context, String currentCity) async {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final String? city = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _CityDialog(initialCity: currentCity),
    );
    if (city != null) {
      await cubit.setWeatherCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RippleColors.background,
      appBar: AppBar(title: const Text(RippleStrings.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
          final SettingsCubit cubit = context.read<SettingsCubit>();
          return ListView(
            children: <Widget>[
              const _SectionTitle(RippleStrings.sectionSystem),
              ListTile(
                leading: Icon(state.integration.isDefaultLauncher ? Icons.check_circle_outline_rounded : Icons.home_outlined,
                    color: state.integration.isDefaultLauncher ? RippleColors.accent : null),
                title: const Text(RippleStrings.defaultLauncher),
                subtitle: Text(state.integration.isDefaultLauncher ? RippleStrings.defaultLauncherOn : RippleStrings.defaultLauncherOff),
                onTap: cubit.requestDefaultLauncher,
              ),
              ListTile(
                leading: Icon(
                  state.integration.hasNotificationAccess ? Icons.check_circle_outline_rounded : Icons.notifications_none_rounded,
                  color: state.integration.hasNotificationAccess ? RippleColors.accent : null,
                ),
                title: const Text(RippleStrings.notificationBadges),
                subtitle: Text(state.integration.hasNotificationAccess ? RippleStrings.notificationBadgesOn : RippleStrings.notificationBadgesOff),
                onTap: state.integration.hasNotificationAccess
                    ? cubit.openNotificationAccess
                    : () => showNotificationAccessSheet(
                          context,
                          onOpenAppInfo: cubit.openRippleAppInfo,
                          onOpenNotificationAccess: cubit.openNotificationAccess,
                        ),
              ),
              const _SectionTitle(RippleStrings.sectionHome),
              ListTile(
                leading: const Icon(Icons.wallpaper_rounded),
                title: const Text(RippleStrings.wallpaper),
                subtitle: Text(RippleWallpaper.fromId(state.settings.wallpaperId).label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WallpaperPickerView()),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.apps_rounded),
                title: const Text(RippleStrings.showIcons),
                value: state.settings.showIcons,
                onChanged: cubit.setShowIcons,
              ),
              ListTile(
                leading: const Icon(Icons.wb_cloudy_outlined),
                title: const Text(RippleStrings.weatherCity),
                subtitle: Text(state.settings.weatherCity.isEmpty ? RippleStrings.weatherCityEmpty : state.settings.weatherCity),
                onTap: () => _editCity(context, state.settings.weatherCity),
              ),
              const _SectionTitle(RippleStrings.sectionApps),
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: const Text(RippleStrings.favoritesOrder),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: widget.onOpenFavoritesOrder,
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text(RippleStrings.groups),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: widget.onOpenGroups,
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text(RippleStrings.hiddenApps),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: widget.onOpenHiddenApps,
              ),
              const SizedBox(height: RippleSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(RippleSpacing.md, RippleSpacing.lg, RippleSpacing.md, RippleSpacing.sm),
      child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: RippleColors.accent)),
    );
  }
}

class _CityDialog extends StatefulWidget {
  const _CityDialog({required this.initialCity});

  final String initialCity;

  @override
  State<_CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends State<_CityDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialCity);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(RippleStrings.weatherCity),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: RippleStrings.weatherCityHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(RippleStrings.cancel)),
        FilledButton(onPressed: _submit, child: const Text(RippleStrings.save)),
      ],
    );
  }
}
