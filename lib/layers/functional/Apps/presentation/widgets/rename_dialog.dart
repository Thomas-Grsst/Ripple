import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';

Future<String?> showRenameDialog(BuildContext context, {required String currentName}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => _RenameDialog(currentName: currentName),
  );
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.currentName});

  final String currentName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.currentName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(RippleStrings.renameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: RippleStrings.renameHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(RippleStrings.cancel)),
        FilledButton(onPressed: _submit, child: const Text(RippleStrings.save)),
      ],
    );
  }
}
