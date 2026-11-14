import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_theme.dart';
import '../../domain/entities/launcher_entry.dart';
import 'app_row.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    required this.results,
    required this.showIcons,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

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
