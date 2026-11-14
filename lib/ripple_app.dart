import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'layers/functional/Apps/domain/entities/app_group.dart';
import 'layers/functional/Apps/presentation/cubit/launcher_cubit.dart';
import 'layers/functional/Apps/presentation/cubit/launcher_state.dart';
import 'layers/functional/Apps/presentation/views/all_apps_view.dart';
import 'layers/functional/Apps/presentation/views/favorites_order_view.dart';
import 'layers/functional/Apps/presentation/views/group_editor_view.dart';
import 'layers/functional/Apps/presentation/views/groups_view.dart';
import 'layers/functional/Apps/presentation/views/hidden_apps_view.dart';
import 'layers/functional/Apps/presentation/views/home_view.dart';
import 'layers/functional/Glance/presentation/cubit/battery_cubit.dart';
import 'layers/functional/Glance/presentation/cubit/weather_cubit.dart';
import 'layers/functional/Glance/presentation/views/clock_style_picker_view.dart';
import 'layers/functional/Glance/presentation/widgets/clock_style.dart';
import 'layers/functional/Glance/presentation/widgets/glance_header.dart';
import 'layers/functional/Settings/presentation/cubit/settings_cubit.dart';
import 'layers/functional/Settings/presentation/views/settings_view.dart';
import 'layers/technical/AppIcons/app_icon_style.dart';
import 'layers/technical/Localization/ripple_strings.dart';
import 'layers/technical/Theme/ripple_theme.dart';
import 'layers/technical/Wallpapers/ripple_wallpaper.dart';
import 'layers/technical/Wallpapers/wallpaper_background.dart';

class RippleApp extends StatelessWidget {
  RippleApp({
    required this.launcherCubit,
    required this.settingsCubit,
    required this.weatherCubit,
    required this.batteryCubit,
    super.key,
  });

  final LauncherCubit launcherCubit;
  final SettingsCubit settingsCubit;
  final WeatherCubit weatherCubit;
  final BatteryCubit batteryCubit;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<Object?>>[
        BlocProvider<LauncherCubit>.value(value: launcherCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<WeatherCubit>.value(value: weatherCubit),
        BlocProvider<BatteryCubit>.value(value: batteryCubit),
      ],
      child: MultiBlocListener(
        listeners: <BlocListener<Object?, Object?>>[
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (SettingsState previous, SettingsState current) =>
                previous.settings.weatherCity != current.settings.weatherCity,
            listener: (BuildContext context, SettingsState state) =>
                context.read<WeatherCubit>().watchCity(state.settings.weatherCity),
          ),
          BlocListener<LauncherCubit, LauncherState>(
            listenWhen: (LauncherState previous, LauncherState current) => previous.homeRequests != current.homeRequests,
            listener: (BuildContext context, LauncherState state) =>
                _navigatorKey.currentState?.popUntil((Route<Object?> route) => route.isFirst),
          ),
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
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

  void _openAllApps(BuildContext context, AppIconStyle iconStyle) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
            AllAppsView(iconStyle: iconStyle),
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          final Animation<double> curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openGroupEditor(BuildContext context, AppGroup group) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GroupEditorView(groupId: group.id)));
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext routeContext) => SettingsView(
          onOpenClockStyle: () => Navigator.of(routeContext).push(
            MaterialPageRoute<void>(
              builder: (BuildContext pickerContext) => ClockStylePickerView(
                selected: ClockStyle.fromId(pickerContext.read<SettingsCubit>().state.settings.clockStyleId),
                onSelected: (ClockStyle style) => pickerContext.read<SettingsCubit>().setClockStyle(style.id),
              ),
            ),
          ),
          onOpenFavoritesOrder: () => Navigator.of(routeContext).push(
            MaterialPageRoute<void>(builder: (_) => const FavoritesOrderView()),
          ),
          onOpenGroups: () => Navigator.of(routeContext).push(
            MaterialPageRoute<void>(
              builder: (BuildContext groupsContext) => GroupsView(
                onEditGroupApps: (AppGroup group) => _openGroupEditor(groupsContext, group),
              ),
            ),
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
          previous.settings.wallpaperId != current.settings.wallpaperId ||
          previous.settings.photoPath != current.settings.photoPath ||
          previous.settings.clockStyleId != current.settings.clockStyleId ||
          previous.settings.iconStyleId != current.settings.iconStyleId,
      builder: (BuildContext context, SettingsState state) {
        final AppIconStyle iconStyle = AppIconStyle.fromId(state.settings.iconStyleId);
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            WallpaperBackground(
              wallpaper: RippleWallpaper.fromId(state.settings.wallpaperId),
              photoPath: state.settings.photoPath,
            ),
            HomeView(
              header: GlanceHeader(style: ClockStyle.fromId(state.settings.clockStyleId)),
              iconStyle: iconStyle,
              onOpenSettings: () => _openSettings(context),
              onOpenAllApps: () => _openAllApps(context, iconStyle),
              onEditGroupApps: (AppGroup group) => _openGroupEditor(context, group),
            ),
          ],
        );
      },
    );
  }
}
