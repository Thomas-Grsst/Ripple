import 'package:flutter/material.dart';

import '../../../../technical/Localization/ripple_strings.dart';

Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String hint = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => _TextPromptDialog(title: title, initialValue: initialValue, hint: hint),
  );
}

Future<String?> showRenameDialog(BuildContext context, {required String currentName}) {
  return showTextPromptDialog(
    context,
    title: RippleStrings.renameTitle,
    initialValue: currentName,
    hint: RippleStrings.renameHint,
  );
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({required this.title, required this.initialValue, required this.hint});

  final String title;
  final String initialValue;
  final String hint;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(RippleStrings.cancel)),
        FilledButton(onPressed: _submit, child: const Text(RippleStrings.save)),
      ],
    );
  }
}
