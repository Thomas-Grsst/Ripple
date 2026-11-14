import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/app_group.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';
import '../widgets/app_row.dart';
import '../widgets/entry_actions.dart';
import '../widgets/entry_list.dart';
import '../widgets/group_actions_sheet.dart';
import '../widgets/group_section.dart';
import '../widgets/search_bar_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required this.header,
    required this.showIcons,
    required this.onOpenSettings,
    required this.onOpenAllApps,
    required this.onEditGroupApps,
    super.key,
  });

  final Widget header;
  final bool showIcons;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAllApps;
  final ValueChanged<AppGroup> onEditGroupApps;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double _pullThreshold = 70;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  double _pullDistance = 0;
  bool _pullTriggered = false;

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

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification && notification.dragDetails != null) {
      _pullDistance += notification.overscroll;
      if (!_pullTriggered && _pullDistance < -_pullThreshold) {
        _pullTriggered = true;
        context.read<LauncherCubit>().expandNotificationShade();
      } else if (!_pullTriggered && _pullDistance > _pullThreshold) {
        _pullTriggered = true;
        widget.onOpenAllApps();
      }
    } else if (notification is ScrollEndNotification) {
      _pullDistance = 0;
      _pullTriggered = false;
    }
    return false;
  }

  Future<void> _launch(LauncherEntry entry) async {
    _searchController.clear();
    _searchFocus.unfocus();
    await context.read<LauncherCubit>().launch(entry);
  }

  Future<void> _showActions(LauncherEntry entry) {
    _searchFocus.unfocus();
    return showEntryActions(context, entry);
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
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: BlocBuilder<LauncherCubit, LauncherState>(
              builder: (BuildContext context, LauncherState state) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: state.isSearching
                          ? SearchResultsList(
                              results: state.searchResults,
                              showIcons: widget.showIcons,
                              onTap: _launch,
                              onLongPress: _showActions,
                            )
                          : _buildHome(context, state),
                    ),
                    SearchBarRow(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: context.read<LauncherCubit>().search,
                      onSubmitted: () {
                        _searchController.clear();
                        context.read<LauncherCubit>().launchFirstResult();
                      },
                      onOpenSettings: widget.onOpenSettings,
                      onOpenAllApps: widget.onOpenAllApps,
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

  Widget _buildHome(BuildContext context, LauncherState state) {
    final LauncherCatalog catalog = state.catalog;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, 0, RippleSpacing.lg, RippleSpacing.xl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, RippleSpacing.xl, RippleSpacing.sm, RippleSpacing.lg),
            child: widget.header,
          ),
          if (state.status == LauncherStatus.loading)
            Padding(
              padding: const EdgeInsets.all(RippleSpacing.sm),
              child: Text(RippleStrings.loadingApps, style: textTheme.bodyMedium),
            ),
          if (state.status == LauncherStatus.failure) _LoadFailure(onRetry: context.read<LauncherCubit>().reloadApps),
          if (state.status == LauncherStatus.ready && catalog.isHomeEmpty) _EmptyHome(onOpenAllApps: widget.onOpenAllApps),
          if (catalog.favorites.isNotEmpty) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, RippleSpacing.sm, RippleSpacing.sm, RippleSpacing.xs),
              child: Text(RippleStrings.favorites.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: RippleColors.textSecondary)),
            ),
            for (final LauncherEntry entry in catalog.favorites)
              AppRow(
                entry: entry,
                size: AppRowSize.favorite,
                showIcon: widget.showIcons,
                onTap: () => _launch(entry),
                onLongPress: () => _showActions(entry),
              ),
          ],
          for (final LauncherGroup group in catalog.groups)
            GroupSection(
              group: group,
              showIcons: widget.showIcons,
              onToggle: () => context.read<LauncherCubit>().toggleGroupExpanded(group.group.id),
              onManage: () => showGroupActions(context, group.group, onEditApps: widget.onEditGroupApps),
              onTapEntry: _launch,
              onLongPressEntry: _showActions,
            ),
        ],
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onOpenAllApps});

  final VoidCallback onOpenAllApps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RippleSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(RippleStrings.emptyHomeTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: RippleSpacing.sm),
          Text(RippleStrings.emptyHomeBody, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: RippleSpacing.md),
          OutlinedButton.icon(
            onPressed: onOpenAllApps,
            icon: const Icon(Icons.apps_rounded),
            label: const Text(RippleStrings.openAllApps),
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
