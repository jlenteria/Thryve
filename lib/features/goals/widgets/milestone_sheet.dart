import 'package:flutter/material.dart';

import '../../../core/widgets/sheets.dart';
import '../../../data/models/milestone.dart';

class MilestoneDraft {
  const MilestoneDraft({
    required this.title,
    required this.status,
    this.note,
    this.valueLabel,
  });

  final String title;
  final MilestoneStatus status;
  final String? note;
  final String? valueLabel;
}

Future<MilestoneDraft?> showMilestoneSheet(
  BuildContext context, {
  Milestone? initial,
}) => showThryveSheet<MilestoneDraft>(
  context,
  (BuildContext context) => _MilestoneSheet(initial: initial),
);

class _MilestoneSheet extends StatefulWidget {
  const _MilestoneSheet({this.initial});

  final Milestone? initial;

  @override
  State<_MilestoneSheet> createState() => _MilestoneSheetState();
}

class _MilestoneSheetState extends State<_MilestoneSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _value;
  late MilestoneStatus _status;

  @override
  void initState() {
    super.initState();
    final Milestone? milestone = widget.initial;
    _title = TextEditingController(text: milestone?.title ?? '');
    _note = TextEditingController(text: milestone?.note ?? '');
    _value = TextEditingController(text: milestone?.valueLabel ?? '');
    _status = milestone?.status ?? MilestoneStatus.pending;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _value.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) {
      return;
    }
    Navigator.pop(
      context,
      MilestoneDraft(
        title: _title.text,
        status: _status,
        note: _note.text,
        valueLabel: _value.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThryveBottomSheet(
      title: widget.initial == null ? 'Add milestone' : 'Edit milestone',
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _title,
              autofocus: widget.initial == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Milestone',
                hintText: 'e.g. Send the proposal',
              ),
              validator: (String? value) =>
                  value == null || value.trim().isEmpty
                  ? 'Name this milestone'
                  : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<MilestoneStatus>(
              segments: <ButtonSegment<MilestoneStatus>>[
                for (final MilestoneStatus status in MilestoneStatus.values)
                  ButtonSegment<MilestoneStatus>(
                    value: status,
                    label: Text(status.label),
                  ),
              ],
              selected: <MilestoneStatus>{_status},
              showSelectedIcon: false,
              onSelectionChanged: (Set<MilestoneStatus> value) =>
                  setState(() => _status = value.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
                hintText: 'Due Friday, 14 / 20 sent, or a short note',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _value,
              decoration: const InputDecoration(
                labelText: 'Value label (optional)',
                hintText: 'e.g. ₱5,000 or 20 minutes',
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
        FilledButton(onPressed: _submit, child: const Text('Save milestone')),
      ],
    );
  }
}
