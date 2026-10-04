import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/goal.dart';

class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.trackingType,
    required this.targetAmount,
    required this.why,
  });

  final String title;
  final GoalTrackingType trackingType;
  final double targetAmount;
  final String why;
}

/// Create or edit a goal. Resolves to null if the user cancels.
Future<GoalDraft?> showGoalForm(BuildContext context, {Goal? initial}) =>
    showThryveSheet<GoalDraft>(
      context,
      (BuildContext context) => _GoalFormSheet(initial: initial),
    );

class _GoalFormSheet extends StatefulWidget {
  const _GoalFormSheet({this.initial});

  final Goal? initial;

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _why;
  late GoalTrackingType _type;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Goal? goal = widget.initial;
    _title = TextEditingController(text: goal?.title ?? '');
    _target = TextEditingController(
      text: goal != null && goal.targetAmount > 0
          ? Formatters.amount(goal.targetAmount)
          : '',
    );
    _why = TextEditingController(text: goal?.why ?? '');
    _type = goal?.trackingType ?? GoalTrackingType.progress;
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _why.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) {
      return;
    }
    Navigator.pop(
      context,
      GoalDraft(
        title: _title.text.trim(),
        trackingType: _type,
        targetAmount: _type == GoalTrackingType.money
            ? Formatters.parseAmount(_target.text)!
            : 0,
        why: _why.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThryveBottomSheet(
      title: _isEditing ? 'Edit goal' : 'Add a goal',
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _title,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What do you want to achieve?',
              ),
              validator: (String? value) =>
                  value == null || value.trim().isEmpty
                  ? 'Give your goal a name'
                  : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<GoalTrackingType>(
              segments: const <ButtonSegment<GoalTrackingType>>[
                ButtonSegment<GoalTrackingType>(
                  value: GoalTrackingType.progress,
                  label: Text('Milestones'),
                  icon: Icon(Icons.flag_outlined),
                ),
                ButtonSegment<GoalTrackingType>(
                  value: GoalTrackingType.money,
                  label: Text('Money'),
                  icon: Icon(Icons.account_balance_wallet_outlined),
                ),
              ],
              selected: <GoalTrackingType>{_type},
              showSelectedIcon: false,
              onSelectionChanged: (Set<GoalTrackingType> value) =>
                  setState(() => _type = value.first),
            ),
            if (_type == GoalTrackingType.money) ...<Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _target,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Target amount',
                  prefixText: widget.initial?.currencySymbol ?? '₱',
                ),
                validator: (String? value) =>
                    Formatters.parseAmount(value ?? '') == null
                    ? 'Enter an amount greater than zero'
                    : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _why,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Why does this matter? (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Create goal'),
        ),
      ],
    );
  }
}
