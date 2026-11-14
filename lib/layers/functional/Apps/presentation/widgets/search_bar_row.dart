import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';

class SearchBarRow extends StatelessWidget {
  const SearchBarRow({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onOpenSettings,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(RippleSpacing.md, RippleSpacing.sm, RippleSpacing.sm, RippleSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted(),
              textInputAction: TextInputAction.go,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(color: RippleColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: RippleStrings.searchHint,
                prefixIcon: const Icon(Icons.search_rounded, color: RippleColors.textSecondary),
                suffixIcon: ListenableBuilder(
                  listenable: controller,
                  builder: (BuildContext context, Widget? child) {
                    if (controller.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.close_rounded, color: RippleColors.textSecondary),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: RippleStrings.settings,
            onPressed: onOpenSettings,
            icon: const Icon(Icons.tune_rounded, color: RippleColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
