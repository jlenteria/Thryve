import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import 'goal_achieved_screen.dart';
import '../../view_models/app_view_model.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  final bool embedded;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final Goal goal = app.goals.firstWhere((Goal value) => value.id == goalId);
    final List<Goal> completedGoals = app.goals
        .where((Goal value) => value.isAchieved)
        .toList();
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Goal header card
        ThryveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Active Goal', color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                goal.title,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${goal.progressPercent}%',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                goal.isFinancial
                    ? '${goal.currencySymbol}${_fmt(goal.currentAmount)} / ${goal.currencySymbol}${_fmt(goal.targetAmount)}'
                    : 'A meaningful goal • ${goal.progressPercent}% complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ProgressBar(progress: goal.progress, height: 10),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // The Why
        if (goal.why != null)
          ThryveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    SectionLabel('The Why', color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"${goal.why}"',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                ),
                if (goal.whyImageUrl != null) ...[
                  const SizedBox(height: 14),
                  NetworkImageSafe(
                    url: goal.whyImageUrl!,
                    height: 140,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Milestones
        Row(
          children: [
            Text(
              'Milestones',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Spacer(),
            if (goal.milestones.isNotEmpty)
              Text(
                '${goal.milestones.where((Milestone m) => m.status == MilestoneStatus.completed).length}/${goal.milestones.length}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
              ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: goal.isAchieved
                  ? null
                  : () => _openMilestoneEditor(context, app),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Milestone'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (goal.milestones.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProgressBar(
              progress:
                  goal.milestones
                      .where(
                        (Milestone m) => m.status == MilestoneStatus.completed,
                      )
                      .length /
                  goal.milestones.length,
              height: 6,
            ),
          ),
        ...goal.milestones.map(
          (Milestone m) => _MilestoneTile(
            milestone: m,
            onTap: goal.isAchieved
                ? () {}
                : () => _openMilestoneEditor(context, app, m),
            onDelete: goal.isAchieved
                ? () {}
                : () => _deleteMilestone(context, app, m),
          ),
        ),
        const SizedBox(height: 24),

        if (!goal.isFinancial || goal.isAchieved)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _toggleGoalCompleted(context, app, goal),
              icon: Icon(
                goal.isAchieved
                    ? Icons.restart_alt
                    : Icons.check_circle_outline,
              ),
              label: Text(
                goal.isAchieved ? 'Reopen goal' : 'Mark goal complete',
              ),
            ),
          ),
        if (!goal.isFinancial || goal.isAchieved) const SizedBox(height: 12),

        // Actions
        Row(
          children: [
            if (goal.isFinancial && !goal.isAchieved)
              Expanded(
                child: PrimaryButton(
                  label: 'Log Earnings',
                  icon: Icons.account_balance_wallet_outlined,
                  onPressed: () => _logEarnings(context, app, goal),
                ),
              ),
            if (goal.isFinancial && !goal.isAchieved) const SizedBox(width: 12),
            if (!goal.isAchieved)
              Expanded(
                child: SecondaryButton(
                  label: 'Edit Goal',
                  icon: Icons.edit_outlined,
                  onPressed: () => _editGoal(context, app, goal),
                ),
              ),
          ],
        ),
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            'Completed goals',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          ...completedGoals.map(
            (Goal completed) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(completed.title),
                subtitle: Text(
                  completed.isFinancial
                      ? 'Financial goal completed'
                      : 'Personal goal completed',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GoalAchievedScreen(goalId: completed.id),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: embedded
          ? null
          : AppHeader(
              title: 'Goal Detail',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              avatarUrl: app.user.avatarUrl,
            ),
      body: embedded
          ? CustomScrollView(
              slivers: <Widget>[
                ThryveSliverHeader(avatarUrl: app.user.avatarUrl),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverToBoxAdapter(child: content),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: content,
            ),
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  Future<void> _openMilestoneEditor(
    BuildContext context,
    AppViewModel app, [
    Milestone? milestone,
  ]) async {
    final _MilestoneDraft? draft = await showModalBottomSheet<_MilestoneDraft>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => _MilestoneEditor(milestone: milestone),
    );
    if (draft != null) {
      final bool wasAchieved = app.goals
          .firstWhere((Goal g) => g.id == goalId)
          .isAchieved;
      app.saveMilestone(
        goalId,
        milestoneId: milestone?.id,
        title: draft.title,
        status: draft.status,
        subtitle: draft.subtitle,
        amountLabel: draft.amountLabel,
      );
      final Goal updated = app.goals.firstWhere((Goal g) => g.id == goalId);
      if (!wasAchieved && updated.isAchieved && context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GoalAchievedScreen(goalId: goalId),
          ),
        );
      }
    }
  }

  Future<void> _toggleGoalCompleted(
    BuildContext context,
    AppViewModel app,
    Goal goal,
  ) async {
    final bool completing = !goal.isAchieved;
    app.setGoalCompleted(goalId, completing);
    if (completing && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GoalAchievedScreen(goalId: goalId),
        ),
      );
    }
  }

  Future<void> _deleteMilestone(
    BuildContext context,
    AppViewModel app,
    Milestone milestone,
  ) async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Delete milestone?',
        content: Text('Remove "${milestone.title}" from this goal?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) app.deleteMilestone(goalId, milestone.id);
  }

  Future<void> _logEarnings(
    BuildContext context,
    AppViewModel app,
    Goal goal,
  ) async {
    String amountText = '';
    final bool? logged = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Log earnings',
        content: TextField(
          autofocus: true,
          onChanged: (String value) => amountText = value,
          onSubmitted: (String value) {
            amountText = value;
            Navigator.pop(context, true);
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: goal.currencySymbol,
            labelText: 'Amount',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log'),
          ),
        ],
      ),
    );
    final double? amount = double.tryParse(
      amountText.replaceAll(',', '').trim(),
    );
    if (logged != true || amount == null || amount <= 0 || !context.mounted) {
      return;
    }
    final Goal updated = app.logEarnings(goalId, amount);
    if (updated.isAchieved && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GoalAchievedScreen(goalId: goalId),
        ),
      );
    }
  }

  Future<void> _editGoal(
    BuildContext context,
    AppViewModel app,
    Goal goal,
  ) async {
    String title = goal.title;
    String target = goal.targetAmount.toStringAsFixed(0);
    String why = goal.why ?? '';
    GoalTrackingType trackingType = goal.trackingType;
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Edit goal',
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: goal.title,
                      onChanged: (String value) => title = value,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<GoalTrackingType>(
                      initialValue: trackingType,
                      decoration: const InputDecoration(labelText: 'Goal type'),
                      items: const <DropdownMenuItem<GoalTrackingType>>[
                        DropdownMenuItem(
                          value: GoalTrackingType.money,
                          child: Text('Financial goal'),
                        ),
                        DropdownMenuItem(
                          value: GoalTrackingType.progress,
                          child: Text('Personal / progress goal'),
                        ),
                      ],
                      onChanged: (GoalTrackingType? value) {
                        if (value != null) {
                          setState(() => trackingType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (trackingType == GoalTrackingType.money) ...[
                      TextFormField(
                        initialValue: goal.targetAmount.toStringAsFixed(0),
                        onChanged: (String value) => target = value,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target amount',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      initialValue: goal.why ?? '',
                      onChanged: (String value) => why = value,
                      decoration: const InputDecoration(labelText: 'Why'),
                    ),
                  ],
                ),
              ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final String cleanTarget = target.replaceAll(',', '').trim();
    final double? parsedAmount = double.tryParse(cleanTarget);
    final double amount =
        trackingType == GoalTrackingType.progress && cleanTarget.isEmpty
        ? 0
        : (parsedAmount ?? -1);
    if (saved == true &&
        title.trim().isNotEmpty &&
        amount >= 0 &&
        (trackingType == GoalTrackingType.progress || amount > 0)) {
      app.updateGoal(
        goalId,
        title: title.trim(),
        targetAmount: amount,
        why: why.trim(),
        trackingType: trackingType,
      );
    }
  }
}

class _MilestoneTile extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _MilestoneTile({
    required this.milestone,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = milestone.status == MilestoneStatus.completed;
    final isPending = milestone.status == MilestoneStatus.pending;

    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (milestone.status) {
      case MilestoneStatus.completed:
        icon = Icons.check_circle;
        iconBg = AppColors.primary;
        iconColor = Colors.white;
        break;
      case MilestoneStatus.inProgress:
        icon = Icons.chat_bubble_outline;
        iconBg = AppColors.primaryContainer;
        iconColor = AppColors.onPrimaryContainer;
        break;
      case MilestoneStatus.pending:
        icon = Icons.schedule;
        iconBg = AppColors.surfaceContainer;
        iconColor = AppColors.onSurfaceVariant;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPending
                ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPending
                  ? AppColors.outlineVariant.withValues(alpha: 0.3)
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
              style: isPending ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isPending
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                    ),
                    if (milestone.subtitle != null)
                      Text(
                        milestone.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (milestone.amountLabel != null)
                Text(
                  milestone.amountLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilestoneDraft {
  const _MilestoneDraft({
    required this.title,
    required this.status,
    this.subtitle,
    this.amountLabel,
  });

  final String title;
  final MilestoneStatus status;
  final String? subtitle;
  final String? amountLabel;
}

class _MilestoneEditor extends StatefulWidget {
  const _MilestoneEditor({this.milestone});

  final Milestone? milestone;

  @override
  State<_MilestoneEditor> createState() => _MilestoneEditorState();
}

class _MilestoneEditorState extends State<_MilestoneEditor> {
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _amount;
  late MilestoneStatus _status;

  @override
  void initState() {
    super.initState();
    final Milestone? milestone = widget.milestone;
    _title = TextEditingController(text: milestone?.title ?? '');
    _subtitle = TextEditingController(text: milestone?.subtitle ?? '');
    _amount = TextEditingController(text: milestone?.amountLabel ?? '');
    _status = milestone?.status ?? MilestoneStatus.pending;
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      _MilestoneDraft(
        title: _title.text,
        status: _status,
        subtitle: _subtitle.text,
        amountLabel: _amount.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThryveBottomSheet(
      title: widget.milestone == null ? 'Add milestone' : 'Edit milestone',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _title,
            autofocus: widget.milestone == null,
            decoration: const InputDecoration(
              labelText: 'Milestone title',
              hintText: 'e.g. Send the proposal',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MilestoneStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const <DropdownMenuItem<MilestoneStatus>>[
              DropdownMenuItem(
                value: MilestoneStatus.pending,
                child: Text('Pending'),
              ),
              DropdownMenuItem(
                value: MilestoneStatus.inProgress,
                child: Text('In progress'),
              ),
              DropdownMenuItem(
                value: MilestoneStatus.completed,
                child: Text('Completed'),
              ),
            ],
            onChanged: (MilestoneStatus? value) {
              if (value != null) setState(() => _status = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitle,
            decoration: const InputDecoration(
              labelText: 'Details (optional)',
              hintText: 'Due Friday, 20 sent, or a short note',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(
              labelText: 'Value label (optional)',
              hintText: 'e.g. ₱5,000 or 20 minutes',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save milestone')),
      ],
    );
  }
}
