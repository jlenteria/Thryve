import 'package:flutter/material.dart';

/// Standard layout for Thryve bottom sheets: title, scrollable content and a
/// right-aligned action row that stays above the keyboard.
class ThryveBottomSheet extends StatelessWidget {
  const ThryveBottomSheet({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            content,
            const SizedBox(height: 20),
            Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}

Future<T?> showThryveSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: builder,
  );
}

/// Asks for confirmation before a destructive action. Resolves to true only
/// when the user taps the confirm button.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final bool? confirmed = await showThryveSheet<bool>(
    context,
    (BuildContext context) => ThryveBottomSheet(
      title: title,
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
