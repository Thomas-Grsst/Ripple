import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'layers/functional/Apps/presentation/cubit/launcher_cubit.dart';
import 'layers/functional/Apps/presentation/views/favorites_order_view.dart';
import 'layers/functional/Apps/presentation/views/hidden_apps_view.dart';
import 'layers/functional/Apps/presentation/views/home_view.dart';
import 'layers/functional/Glance/presentation/cubit/weather_cubit.dart';
import 'layers/functional/Glance/presentation/widgets/glance_header.dart';
import 'layers/functional/Settings/presentation/cubit/settings_cubit.dart';
import 'layers/functional/Settings/presentation/views/settings_view.dart';
import 'layers/technical/Localization/ripple_strings.dart';
import 'layers/technical/Theme/ripple_theme.dart';

class RippleApp extends StatelessWidget {
  const RippleApp({
    required this.launcherCubit,
    required this.settingsCubit,
    required this.weatherCubit,
    super.key,
  });

  final LauncherCubit launcherCubit;
  final SettingsCubit settingsCubit;
  final WeatherCubit weatherCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<Object?>>[
        BlocProvider<LauncherCubit>.value(value: launcherCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<WeatherCubit>.value(value: weatherCubit),
      ],
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (SettingsState previous, SettingsState current) =>
            previous.settings.weatherCity != current.settings.weatherCity,
        listener: (BuildContext context, SettingsState state) =>
            context.read<WeatherCubit>().watchCity(state.settings.weatherCity),
        child: MaterialApp(
          title: RippleStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: buildRippleTheme(),
          home: const _RippleHome(),
        ),
      ),
    );
  }
}

class _RippleHome extends StatelessWidget {
  const _RippleHome();

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext routeContext) => SettingsView(
          onOpenFavoritesOrder: () => Navigator.of(routeContext).push(
            MaterialPageRoute<void>(builder: (_) => const FavoritesOrderView()),
          ),
          onOpenHiddenApps: () => Navigator.of(routeContext).push(
            MaterialPageRoute<void>(builder: (_) => const HiddenAppsView()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (SettingsState previous, SettingsState current) =>
          previous.settings.showWallpaper != current.settings.showWallpaper ||
          previous.settings.showIcons != current.settings.showIcons,
      builder: (BuildContext context, SettingsState state) {
        return HomeView(
          header: const GlanceHeader(),
          showWallpaper: state.settings.showWallpaper,
          showIcons: state.settings.showIcons,
          onOpenSettings: () => _openSettings(context),
        );
      },
    );
  }
}
