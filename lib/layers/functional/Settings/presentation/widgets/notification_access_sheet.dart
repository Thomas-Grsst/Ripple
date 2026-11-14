import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';
import '../../../../technical/Theme/ripple_colors.dart';
import '../../../../technical/Theme/ripple_theme.dart';

Future<void> showNotificationAccessSheet(
  BuildContext context, {
  required VoidCallback onOpenAppInfo,
  required VoidCallback onOpenNotificationAccess,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) => _NotificationAccessSheet(
      onOpenAppInfo: onOpenAppInfo,
      onOpenNotificationAccess: onOpenNotificationAccess,
    ),
  );
}

class _NotificationAccessSheet extends StatelessWidget {
  const _NotificationAccessSheet({required this.onOpenAppInfo, required this.onOpenNotificationAccess});

  final VoidCallback onOpenAppInfo;
  final VoidCallback onOpenNotificationAccess;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(RippleSpacing.lg, 0, RippleSpacing.lg, RippleSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(RippleStrings.notificationGuideTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: RippleSpacing.sm),
            Text(RippleStrings.notificationGuideIntro, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: RippleSpacing.lg),
            _Step(
              number: 1,
              title: RippleStrings.notificationGuideStepOne,
              hint: RippleStrings.notificationGuideStepOneHint,
              onOpen: onOpenAppInfo,
            ),
            const SizedBox(height: RippleSpacing.md),
            _Step(
              number: 2,
              title: RippleStrings.notificationGuideStepTwo,
              hint: RippleStrings.notificationGuideStepTwoHint,
              onOpen: onOpenNotificationAccess,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.hint, required this.onOpen});

  final int number;
  final String title;
  final String hint;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 14,
          backgroundColor: RippleColors.accent,
          child: Text('$number', style: const TextStyle(color: RippleColors.onAccent, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: RippleSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontSize: 16, color: RippleColors.textPrimary)),
              const SizedBox(height: RippleSpacing.xs),
              Text(hint, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: RippleSpacing.sm),
        OutlinedButton(onPressed: onOpen, child: const Text(RippleStrings.open)),
      ],
    );
  }
}
