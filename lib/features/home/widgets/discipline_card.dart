import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_view_model.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/thryve_card.dart';
import '../../../data/models/discipline_task.dart';

/// Today's daily practices with add / edit / remove.
class DisciplineCard extends StatelessWidget {
  const DisciplineCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final List<DisciplineTask> tasks = app.tasks;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return ThryveCard(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.checklist_rtl, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Today's discipline", style: text.headlineSmall),
              ),
              IconButton(
                tooltip: 'Add practice',
                onPressed: () => _edit(context, app),
                icon: const Icon(Icons.add),
                color: colors.primary,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 12),
            child: Text(
              tasks.isEmpty
                  ? 'Add one small practice you can do every day.'
                  : '${app.completedTasksToday} of ${tasks.length} complete today',
              style: text.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          for (final DisciplineTask task in tasks)
            _PracticeRow(
              task: task,
              onToggle: () => app.toggleTask(task.id),
              onEdit: () => _edit(context, app, task),
              onDelete: () => _delete(context, app, task),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    AppViewModel app, [
    DisciplineTask? task,
  ]) async {
    final String? title = await showThryveSheet<String>(
      context,
      (BuildContext context) => _PracticeSheet(initial: task?.title ?? ''),
    );
    if (title != null) {
      app.saveTask(taskId: task?.id, title: title);
    }
  }

  Future<void> _delete(
    BuildContext context,
    AppViewModel app,
    DisciplineTask task,
  ) async {
    final bool confirmed = await confirmDestructive(
      context,
      title: 'Remove practice?',
      message: 'Remove "${task.title}" from your daily discipline?',
      confirmLabel: 'Remove',
    );
    if (confirmed) {
      app.deleteTask(task.id);
    }
  }
}

class _PracticeRow extends StatelessWidget {
  const _PracticeRow({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final DisciplineTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: CheckboxListTile(
            value: task.completed,
            onChanged: (_) => onToggle(),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            activeColor: colors.primary,
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            title: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed
                    ? colors.onSurfaceVariant
                    : colors.onSurface,
              ),
            ),
          ),
        ),
        PopupMenuButton<VoidCallback>(
          tooltip: 'Practice options',
          onSelected: (VoidCallback action) => action(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<VoidCallback>>[
            PopupMenuItem<VoidCallback>(
              value: onEdit,
              child: const Text('Edit'),
            ),
            PopupMenuItem<VoidCallback>(
              value: onDelete,
              child: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PracticeSheet extends StatefulWidget {
  const _PracticeSheet({required this.initial});

  final String initial;

  @override
  State<_PracticeSheet> createState() => _PracticeSheetState();
}

class _PracticeSheetState extends State<_PracticeSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    if (_title.text.trim().isNotEmpty) {
      Navigator.pop(context, _title.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThryveBottomSheet(
      title: widget.initial.isEmpty ? 'Add practice' : 'Edit practice',
      content: TextField(
        controller: _title,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'Practice',
          hintText: 'e.g. 30 minutes of client outreach',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
