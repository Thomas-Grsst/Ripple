import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';
import '../widgets/alphabet_wave.dart';
import '../widgets/app_actions_sheet.dart';
import '../widgets/app_row.dart';
import '../widgets/rename_dialog.dart';
import '../widgets/search_bar_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required this.header,
    required this.showWallpaper,
    required this.showIcons,
    required this.onOpenSettings,
    super.key,
  });

  final Widget header;
  final bool showWallpaper;
  final bool showIcons;
  final VoidCallback onOpenSettings;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double _pullToExpandThreshold = 70;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final GlobalKey _topSectionKey = GlobalKey();
  double _pullDistance = 0;
  bool _shadeTriggered = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _returnHome() {
    _searchController.clear();
    _searchFocus.unfocus();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  void _jumpToLetter(LauncherState state, String letter) {
    final int? index = state.catalog.letterIndex[letter];
    final double? topHeight = _topSectionKey.currentContext?.size?.height;
    if (index == null || topHeight == null || !_scrollController.hasClients) {
      return;
    }
    final double target = topHeight + index * AppRowSize.regular.height;
    _scrollController.jumpTo(target.clamp(0, _scrollController.position.maxScrollExtent));
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification && notification.dragDetails != null && notification.overscroll < 0) {
      _pullDistance -= notification.overscroll;
      if (!_shadeTriggered && _pullDistance > _pullToExpandThreshold) {
        _shadeTriggered = true;
        context.read<LauncherCubit>().expandNotificationShade();
      }
    } else if (notification is ScrollEndNotification) {
      _pullDistance = 0;
      _shadeTriggered = false;
    }
    return false;
  }

  Future<void> _showActions(LauncherEntry entry) async {
    final LauncherCubit cubit = context.read<LauncherCubit>();
    _searchFocus.unfocus();
    final AppAction? action = await showAppActionsSheet(context, entry);
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case AppAction.toggleFavorite:
        await cubit.toggleFavorite(entry.packageName);
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

  Future<void> _launch(LauncherEntry entry) async {
    _searchController.clear();
    _searchFocus.unfocus();
    await context.read<LauncherCubit>().launch(entry);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<LauncherCubit, LauncherState>>[
        BlocListener<LauncherCubit, LauncherState>(
          listenWhen: (LauncherState previous, LauncherState current) => previous.homeRequests != current.homeRequests,
          listener: (BuildContext context, LauncherState state) => _returnHome(),
        ),
        BlocListener<LauncherCubit, LauncherState>(
          listenWhen: (LauncherState previous, LauncherState current) => previous.launchFailures != current.launchFailures,
          listener: (BuildContext context, LauncherState state) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(RippleStrings.launchFailed)));
          },
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) => _returnHome(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: widget.showWallpaper ? RippleColors.wallpaperScrim : RippleColors.background,
          body: SafeArea(
            child: BlocBuilder<LauncherCubit, LauncherState>(
              builder: (BuildContext context, LauncherState state) {
                return Column(
                  children: <Widget>[
                    Expanded(child: _buildContent(context, state)),
                    SearchBarRow(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: context.read<LauncherCubit>().search,
                      onSubmitted: () {
                        _searchController.clear();
                        context.read<LauncherCubit>().launchFirstResult();
                      },
                      onOpenSettings: widget.onOpenSettings,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LauncherState state) {
    if (state.isSearching) {
      return _SearchResults(results: state.searchResults, showIcons: widget.showIcons, onTap: _launch, onLongPress: _showActions);
    }
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _topSectionKey,
                  child: _TopSection(
                    header: widget.header,
                    state: state,
                    showIcons: widget.showIcons,
                    onTap: _launch,
                    onLongPress: _showActions,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: RippleSpacing.sm, right: RippleSpacing.xl + RippleSpacing.sm),
                sliver: SliverFixedExtentList(
                  itemExtent: AppRowSize.regular.height,
                  delegate: SliverChildBuilderDelegate(
                    childCount: state.catalog.visible.length,
                    (BuildContext context, int index) {
                      final LauncherEntry entry = state.catalog.visible[index];
                      final bool startsGroup = index == 0 || state.catalog.visible[index - 1].letter != entry.letter;
                      return AppRow(
                        entry: entry,
                        size: AppRowSize.regular,
                        showIcon: widget.showIcons,
                        reserveLetterColumn: true,
                        leadingLetter: startsGroup ? entry.letter : null,
                        onTap: () => _launch(entry),
                        onLongPress: () => _showActions(entry),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.4)),
            ],
          ),
        ),
        Positioned(
          top: RippleSpacing.lg,
          bottom: RippleSpacing.lg,
          right: RippleSpacing.xs,
          child: AlphabetWave(
            letters: state.catalog.letters,
            onLetterSelected: (String letter) => _jumpToLetter(state, letter),
          ),
        ),
      ],
    );
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection({
    required this.header,
    required this.state,
    required this.showIcons,
    required this.onTap,
    required this.onLongPress,
  });

  final Widget header;
  final LauncherState state;
  final bool showIcons;
  final ValueChanged<LauncherEntry> onTap;
  final ValueChanged<LauncherEntry> onLongPress;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: RippleSpacing.sm, right: RippleSpacing.xl + RippleSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, RippleSpacing.xl, RippleSpacing.sm, RippleSpacing.xl),
            child: header,
          ),
          if (state.status == LauncherStatus.loading)
            Padding(
              padding: const EdgeInsets.all(RippleSpacing.sm),
              child: Text(RippleStrings.loadingApps, style: textTheme.bodyMedium),
            ),
          if (state.status == LauncherStatus.failure) _LoadFailure(onRetry: context.read<LauncherCubit>().reloadApps),
          if (state.status == LauncherStatus.ready && state.catalog.favorites.isEmpty)
            Padding(
              padding: const EdgeInsets.all(RippleSpacing.sm),
              child: Text(RippleStrings.addFavoritesHint, style: textTheme.bodyMedium),
            ),
          for (final LauncherEntry entry in state.catalog.favorites)
            AppRow(
              entry: entry,
              size: AppRowSize.favorite,
              showIcon: showIcons,
              onTap: () => onTap(entry),
              onLongPress: () => onLongPress(entry),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, RippleSpacing.xl, RippleSpacing.sm, RippleSpacing.sm),
            child: Text(RippleStrings.allApps.toUpperCase(), style: textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RippleSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(RippleStrings.appsUnavailable, style: Theme.of(context).textTheme.bodyMedium)),
          TextButton(onPressed: onRetry, child: const Text(RippleStrings.retry)),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.showIcons, required this.onTap, required this.onLongPress});

  final List<LauncherEntry> results;
  final bool showIcons;
  final ValueChanged<LauncherEntry> onTap;
  final ValueChanged<LauncherEntry> onLongPress;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(RippleSpacing.lg),
          child: Text(RippleStrings.noResults, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: RippleSpacing.sm),
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final LauncherEntry entry = results[index];
        return AppRow(
          entry: entry,
          size: index == 0 ? AppRowSize.favorite : AppRowSize.regular,
          showIcon: showIcons,
          onTap: () => onTap(entry),
          onLongPress: () => onLongPress(entry),
        );
      },
    );
  }
}
