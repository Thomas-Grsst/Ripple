import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/AppIcons/app_icon_style.dart';
import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_entry.dart';
import '../cubit/launcher_cubit.dart';
import '../cubit/launcher_state.dart';
import '../widgets/alphabet_wave.dart';
import '../widgets/app_row.dart';
import '../widgets/entry_actions.dart';

class AllAppsView extends StatefulWidget {
  const AllAppsView({required this.iconStyle, super.key});

  final AppIconStyle iconStyle;

  @override
  State<AllAppsView> createState() => _AllAppsViewState();
}

class _AllAppsViewState extends State<AllAppsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToLetter(LauncherState state, String letter) {
    final int? index = state.catalog.letterIndex[letter];
    if (index == null || !_scrollController.hasClients) {
      return;
    }
    final double target = index * AppRowSize.regular.height;
    _scrollController.jumpTo(target.clamp(0, _scrollController.position.maxScrollExtent));
  }

  Future<void> _launch(LauncherEntry entry) async {
    final LauncherCubit cubit = context.read<LauncherCubit>();
    Navigator.of(context).pop();
    await cubit.launch(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RippleColors.background,
      body: SafeArea(
        child: BlocBuilder<LauncherCubit, LauncherState>(
          builder: (BuildContext context, LauncherState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(RippleSpacing.lg, RippleSpacing.md, RippleSpacing.sm, RippleSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(RippleStrings.allApps, style: Theme.of(context).textTheme.titleLarge)),
                      Text('${state.catalog.visible.length}', style: Theme.of(context).textTheme.labelMedium),
                      IconButton(
                        tooltip: RippleStrings.close,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: RippleColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      ListView.builder(
                        controller: _scrollController,
                        itemExtent: AppRowSize.regular.height,
                        padding: EdgeInsets.only(
                          left: RippleSpacing.sm,
                          right: RippleSpacing.xl + RippleSpacing.sm,
                          bottom: MediaQuery.sizeOf(context).height * 0.4,
                        ),
                        itemCount: state.catalog.visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final LauncherEntry entry = state.catalog.visible[index];
                          final bool startsGroup = index == 0 || state.catalog.visible[index - 1].letter != entry.letter;
                          return AppRow(
                            entry: entry,
                            size: AppRowSize.regular,
                            iconStyle: widget.iconStyle,
                            reserveLetterColumn: true,
                            leadingLetter: startsGroup ? entry.letter : null,
                            onTap: () => _launch(entry),
                            onLongPress: () => showEntryActions(context, entry),
                          );
                        },
                      ),
                      Positioned(
                        top: RippleSpacing.sm,
                        bottom: RippleSpacing.lg,
                        right: RippleSpacing.xs,
                        child: AlphabetWave(
                          letters: state.catalog.letters,
                          onLetterSelected: (String letter) => _jumpToLetter(state, letter),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
