import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/AppIcons/app_icon_style.dart';
import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/app_group.dart';
import '../../domain/entities/label_normalizer.dart';
import '../../domain/entities/launcher_catalog.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';
import '../widgets/alphabet_wave.dart';
import '../widgets/app_row.dart';
import '../widgets/entry_actions.dart';
import '../widgets/entry_list.dart';
import '../widgets/group_actions_sheet.dart';
import '../widgets/group_row.dart';
import '../widgets/rename_dialog.dart';
import '../widgets/search_bar_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required this.header,
    required this.iconStyle,
    required this.onOpenSettings,
    required this.onOpenAllApps,
    required this.onEditGroupApps,
    super.key,
  });

  final Widget header;
  final AppIconStyle iconStyle;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAllApps;
  final ValueChanged<AppGroup> onEditGroupApps;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double _pullThreshold = 70;
  static const double _waveSlotHeight = 13.5;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  double _pullDistance = 0;
  bool _pullTriggered = false;
  bool _reordering = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _stopReordering() {
    if (_reordering) {
      setState(() => _reordering = false);
    }
  }

  void _returnHome() {
    _stopReordering();
    _searchController.clear();
    _searchFocus.unfocus();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _onBack(LauncherState state) {
    if (_reordering) {
      _stopReordering();
      return;
    }
    final LauncherCubit cubit = context.read<LauncherCubit>();
    switch (state.homeFilter) {
      case GroupFilter():
        cubit.selectLetter(LabelNormalizer.otherLetter);
      case LetterFilter():
        cubit.showFavorites();
      case FavoritesFilter():
        break;
    }
    _returnHome();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification && notification.dragDetails != null) {
      _pullDistance += notification.overscroll;
      if (!_pullTriggered && _pullDistance < -_pullThreshold) {
        _pullTriggered = true;
        context.read<LauncherCubit>().expandNotificationShade();
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
    final LauncherState state = context.read<LauncherCubit>().state;
    final bool canReorder = !state.isSearching &&
        switch (state.homeFilter) {
          FavoritesFilter() => entry.isFavorite,
          GroupFilter() => true,
          LetterFilter() => false,
        };
    return showEntryActions(
      context,
      entry,
      onReorder: canReorder ? () => setState(() => _reordering = true) : null,
    );
  }

  Future<void> _createGroup() async {
    final LauncherCubit cubit = context.read<LauncherCubit>();
    final String? name = await showTextPromptDialog(context, title: RippleStrings.newGroup, hint: RippleStrings.groupNameHint);
    if (name != null) {
      await cubit.createGroup(name);
    }
  }

  void _onWaveLetter(String letter) {
    final LauncherCubit cubit = context.read<LauncherCubit>();
    if (letter == RippleStrings.favoritesSymbol) {
      cubit.showFavorites();
    } else {
      cubit.selectLetter(letter);
    }
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
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
          listenWhen: (LauncherState previous, LauncherState current) =>
              previous.homeFilter != current.homeFilter || (!previous.isSearching && current.isSearching),
          listener: (BuildContext context, LauncherState state) => _stopReordering(),
        ),
        BlocListener<LauncherCubit, LauncherState>(
          listenWhen: (LauncherState previous, LauncherState current) => previous.launchFailures != current.launchFailures,
          listener: (BuildContext context, LauncherState state) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(RippleStrings.launchFailed)));
          },
        ),
      ],
      child: BlocBuilder<LauncherCubit, LauncherState>(
        builder: (BuildContext context, LauncherState state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) => _onBack(state),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(RippleSpacing.lg, RippleSpacing.xl, RippleSpacing.lg, RippleSpacing.md),
                      child: widget.header,
                    ),
                    Expanded(
                      child: state.isSearching
                          ? SearchResultsList(
                              results: state.searchResults,
                              iconStyle: widget.iconStyle,
                              onTap: _launch,
                              onLongPress: _showActions,
                            )
                          : _buildFilteredArea(context, state),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredArea(BuildContext context, LauncherState state) {
    final LauncherCatalog catalog = state.catalog;
    final List<String> waveLetters = <String>[
      RippleStrings.favoritesSymbol,
      ...catalog.letters.where((String letter) => letter != LabelNormalizer.otherLetter),
      LabelNormalizer.otherLetter,
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double waveHeight = (waveLetters.length * _waveSlotHeight).clamp(0, constraints.maxHeight - RippleSpacing.md);
        return Stack(
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: _FilteredEntries(
                controller: _scrollController,
                state: state,
                iconStyle: widget.iconStyle,
                reordering: _reordering,
                onReorder: context.read<LauncherCubit>().reorderHomeEntries,
                onFinishReorder: _stopReordering,
                onTap: _launch,
                onLongPress: _showActions,
                onEditGroupApps: widget.onEditGroupApps,
                onOpenGroup: (LauncherGroup group) => context.read<LauncherCubit>().selectGroup(group.group.id),
                onManageGroup: (LauncherGroup group) =>
                    showGroupActions(context, group.group, onEditApps: widget.onEditGroupApps),
                onCreateGroup: _createGroup,
              ),
            ),
            if (!_reordering)
              Positioned(
                right: RippleSpacing.xs,
                bottom: RippleSpacing.sm,
                height: waveHeight,
                child: AlphabetWave(letters: waveLetters, onLetterSelected: _onWaveLetter),
              ),
          ],
        );
      },
    );
  }
}

class _FilteredEntries extends StatelessWidget {
  const _FilteredEntries({
    required this.controller,
    required this.state,
    required this.iconStyle,
    required this.reordering,
    required this.onReorder,
    required this.onFinishReorder,
    required this.onTap,
    required this.onLongPress,
    required this.onEditGroupApps,
    required this.onOpenGroup,
    required this.onManageGroup,
    required this.onCreateGroup,
  });

  final ScrollController controller;
  final LauncherState state;
  final AppIconStyle iconStyle;
  final bool reordering;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onFinishReorder;
  final ValueChanged<LauncherEntry> onTap;
  final ValueChanged<LauncherEntry> onLongPress;
  final ValueChanged<AppGroup> onEditGroupApps;
  final ValueChanged<LauncherGroup> onOpenGroup;
  final ValueChanged<LauncherGroup> onManageGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final LauncherCatalog catalog = state.catalog;
    final HomeFilter filter = state.homeFilter;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final LauncherGroup? group = filter is GroupFilter ? catalog.groupById(filter.groupId) : null;
    final List<LauncherEntry> entries = switch (filter) {
      FavoritesFilter() => catalog.favorites,
      LetterFilter(:final String letter) => catalog.entriesForLetter(letter),
      GroupFilter() => group?.entries ?? catalog.favorites,
    };

    final bool showsGroups = filter is LetterFilter && filter.letter == LabelNormalizer.otherLetter;
    final String? title = switch (filter) {
      FavoritesFilter() => null,
      LetterFilter(:final String letter) => letter,
      GroupFilter() => group?.group.name,
    };

    final Widget? titleWidget = title == null
        ? null
        : GestureDetector(
          onLongPress: group == null ? null : () => onManageGroup(group),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, 0, RippleSpacing.sm, RippleSpacing.sm),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: RippleColors.accent, height: 1.1),
            ),
          ),
        );

    if (reordering) {
      return ReorderableListView(
        scrollController: controller,
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.fromLTRB(RippleSpacing.md, 0, RippleSpacing.md, RippleSpacing.xl),
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ?titleWidget,
            _ReorderBar(onDone: onFinishReorder),
          ],
        ),
        onReorderItem: onReorder,
        children: <Widget>[
          for (final (int index, LauncherEntry entry) in entries.indexed)
            Row(
              key: ValueKey<String>(entry.packageName),
              children: <Widget>[
                Expanded(
                  child: AppRow(
                    entry: entry,
                    size: AppRowSize.favorite,
                    iconStyle: iconStyle,
                    onTap: () {},
                    onLongPress: () {},
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(RippleSpacing.sm),
                    child: Icon(Icons.drag_handle_rounded, color: RippleColors.textSecondary),
                  ),
                ),
              ],
            ),
        ],
      );
    }

    final List<Widget> children = <Widget>[
      ?titleWidget,
      if (showsGroups) ...<Widget>[
        for (final LauncherGroup item in catalog.groups)
          GroupRow(group: item, onTap: () => onOpenGroup(item), onLongPress: () => onManageGroup(item)),
        NewGroupRow(label: RippleStrings.newGroup, onTap: onCreateGroup),
      ],
      if (state.status == LauncherStatus.loading)
        _Hint(text: RippleStrings.loadingApps, textTheme: textTheme),
      if (state.status == LauncherStatus.failure)
        Padding(
          padding: const EdgeInsets.all(RippleSpacing.sm),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(RippleStrings.appsUnavailable, style: textTheme.bodyMedium)),
              TextButton(onPressed: context.read<LauncherCubit>().reloadApps, child: const Text(RippleStrings.retry)),
            ],
          ),
        ),
      if (state.status == LauncherStatus.ready && entries.isEmpty && !showsGroups)
        switch (filter) {
          FavoritesFilter() => _Hint(text: RippleStrings.noFavoritesYet, textTheme: textTheme),
          LetterFilter() => _Hint(text: RippleStrings.noAppsForLetter, textTheme: textTheme),
          GroupFilter() => GestureDetector(
              onTap: group == null ? null : () => onEditGroupApps(group.group),
              child: _Hint(text: RippleStrings.emptyGroup, textTheme: textTheme),
            ),
        },
      for (final LauncherEntry entry in entries)
        AppRow(
          entry: entry,
          size: AppRowSize.favorite,
          iconStyle: iconStyle,
          onTap: () => onTap(entry),
          onLongPress: () => onLongPress(entry),
        ),
    ];

    return ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(RippleSpacing.md, 0, RippleSpacing.xl + RippleSpacing.md, RippleSpacing.xl),
      children: children,
    );
  }
}

class _ReorderBar extends StatelessWidget {
  const _ReorderBar({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(RippleSpacing.sm, 0, 0, RippleSpacing.sm),
      child: Row(
        children: <Widget>[
          const Icon(Icons.swap_vert_rounded, size: 18, color: RippleColors.accent),
          const SizedBox(width: RippleSpacing.sm),
          const Expanded(
            child: Text(RippleStrings.reorderHint, style: TextStyle(fontSize: 14, color: RippleColors.textSecondary)),
          ),
          FilledButton(onPressed: onDone, child: const Text(RippleStrings.done)),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.textTheme});

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RippleSpacing.sm),
      child: Text(text, style: textTheme.bodyMedium),
    );
  }
}
