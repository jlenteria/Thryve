import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../../view_models/app_view_model.dart';
import '../goals/goal_detail_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
      builder: (context, vm, _) {
        final Goal goal = vm.activeGoal;
        final tasks = vm.tasks;
        final inspiration = vm.inspiration;
        final user = vm.user;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              ThryveSliverHeader(avatarUrl: user.avatarUrl),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('Dashboard'),
                              const SizedBox(height: 4),
                              Text(
                                'Hello, ${user.name}.',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              if (user.bigDream?.trim().isNotEmpty == true)
                                Text(
                                  'Growing toward ${user.bigDream}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryContainer.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${user.streakDays} Days',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (user.anchor?.trim().isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ThryveCard(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.favorite_outline,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your anchor: ${user.anchor}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ThryveCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GoalDetailScreen(goalId: goal.id),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      goal.category,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                goal.isFinancial
                                    ? '${goal.currencySymbol}${_fmt(goal.currentAmount)}'
                                    : '${goal.progressPercent}% complete',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppColors.primary),
                              ),
                              const Spacer(),
                              if (goal.isFinancial)
                                Text(
                                  'of ${goal.currencySymbol}${_fmt(goal.targetAmount)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ProgressBar(progress: goal.progress, height: 10),
                          if (goal.milestones.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.flag_outlined,
                                  size: 15,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${goal.milestones.where((Milestone m) => m.status == MilestoneStatus.completed).length}/${goal.milestones.length} milestones complete',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                          if (goal.quote != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              goal.quote!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ThryveCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.checklist_rtl,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Today's Discipline",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Add practice',
                                onPressed: () => _editTask(context, vm),
                                icon: const Icon(Icons.add),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              tasks.isEmpty
                                  ? 'Add one small practice for today.'
                                  : '${tasks.where((DisciplineTask task) => task.completed).length} of ${tasks.length} complete today',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (tasks.isEmpty)
                            const SizedBox(height: 4)
                          else
                            ...tasks.map(
                              (t) => _DisciplineRow(
                                task: t,
                                onToggle: () => vm.toggleTask(t.id),
                                onEdit: () => _editTask(context, vm, t),
                                onDelete: () => _deleteTask(context, vm, t),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ThryveCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: NetworkImageSafe(
                              url: inspiration.imageUrl,
                              height: 180,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel(
                                  'Your featured Wall reminder',
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  inspiration.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  inspiration.body,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () => showModalBottomSheet<void>(
                                    context: context,
                                    showDragHandle: true,
                                    builder: (BuildContext context) => Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            inspiration.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineMedium,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(inspiration.body),
                                          const SizedBox(height: 20),
                                          PrimaryButton(
                                            label: 'Done',
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        inspiration.ctaLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppColors.primary,
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  Future<void> _editTask(
    BuildContext context,
    AppViewModel vm, [
    DisciplineTask? task,
  ]) async {
    String title = task?.title ?? '';
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: task == null ? 'Add practice' : 'Edit practice',
        content: TextFormField(
          autofocus: true,
          initialValue: title,
          onChanged: (String value) => title = value,
          decoration: const InputDecoration(
            labelText: 'Practice',
            hintText: 'e.g. Walk for 20 minutes',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && title.trim().isNotEmpty) {
      vm.saveTask(taskId: task?.id, title: title);
    }
  }

  Future<void> _deleteTask(
    BuildContext context,
    AppViewModel vm,
    DisciplineTask task,
  ) async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Remove practice?',
        content: Text('Remove "${task.title}" from today\'s discipline?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) vm.deleteTask(task.id);
  }
}

class _DisciplineRow extends StatelessWidget {
  final DisciplineTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DisciplineRow({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.completed ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.completed
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: task.completed
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.completed
                      ? AppColors.onSurfaceVariant
                      : AppColors.onSurface,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<String>>[
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
