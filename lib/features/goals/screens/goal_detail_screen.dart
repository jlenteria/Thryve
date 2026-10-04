import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_ext.dart';
import '../../../core/state/app_view_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/thryve_card.dart';
import '../../../core/widgets/thryve_page.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/milestone.dart';
import '../goal_flows.dart';
import '../widgets/goal_form_sheet.dart';
import '../widgets/goal_widgets.dart';
import '../widgets/milestone_sheet.dart';

enum _GoalMenu { focus, edit, complete, delete }

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final Goal? goal = app.goalById(goalId);
    if (goal == null) {
      // Deleted while open.
      return const Scaffold(body: SizedBox.shrink());
    }
    final bool isFocus = app.focusGoal?.id == goal.id;
    final ColorScheme colors = context.colors;
    final TextTheme text = context.text;

    return ThryveDetailPage(
      title: 'Goal',
      actions: <Widget>[
        PopupMenuButton<_GoalMenu>(
          onSelected: (_GoalMenu action) => _onMenu(context, app, goal, action),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<_GoalMenu>>[
            if (!goal.isAchieved && !isFocus)
              const PopupMenuItem<_GoalMenu>(
                value: _GoalMenu.focus,
                child: Text('Make focus goal'),
              ),
            if (!goal.isAchieved)
              const PopupMenuItem<_GoalMenu>(
                value: _GoalMenu.edit,
                child: Text('Edit goal'),
              ),
            PopupMenuItem<_GoalMenu>(
              value: _GoalMenu.complete,
              child: Text(goal.isAchieved ? 'Reopen goal' : 'Mark complete'),
            ),
            const PopupMenuItem<_GoalMenu>(
              value: _GoalMenu.delete,
              child: Text('Delete goal'),
            ),
          ],
        ),
      ],
      children: <Widget>[
        ThryveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionLabel(
                goal.isAchieved
                    ? 'Achieved'
                    : (isFocus ? 'Focus goal' : 'Active goal'),
                color: colors.primary,
              ),
              const SizedBox(height: 8),
              Text(goal.title, style: text.displayMedium),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      goal.isFinancial
                          ? '${Formatters.money(goal.currencySymbol, goal.currentAmount)}'
                                ' / ${Formatters.money(goal.currencySymbol, goal.targetAmount)}'
                          : 'Day ${goal.daysActive} of your journey',
                      style: text.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${goal.progressPercent}%',
                    style: text.titleLarge?.copyWith(color: colors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ProgressBar(progress: goal.progress),
            ],
          ),
        ),
        if (goal.why?.isNotEmpty == true || goal.image != null) ...<Widget>[
          const SizedBox(height: 16),
          ThryveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    SectionLabel('The why', color: colors.primary),
                  ],
                ),
                if (goal.why?.isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    '"${goal.why}"',
                    style: text.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (goal.image != null) ...<Widget>[
                  const SizedBox(height: 14),
                  AppImage(
                    source: goal.image,
                    height: 160,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(child: Text('Milestones', style: text.headlineMedium)),
            if (goal.milestones.isNotEmpty)
              Text(
                '${goal.completedMilestones}/${goal.milestones.length}',
                style: text.labelMedium?.copyWith(color: colors.primary),
              ),
            if (!goal.isAchieved)
              TextButton.icon(
                onPressed: () => _editMilestone(context, app, goal),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (goal.milestones.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              goal.isFinancial
                  ? 'Optional: add the steps that will get you to your target.'
                  : 'Break this goal into a few concrete steps. Completing '
                        'them all completes the goal.',
              style: text.bodySmall,
            ),
          )
        else
          for (final Milestone milestone in goal.milestones)
            MilestoneTile(
              milestone: milestone,
              onTap: goal.isAchieved
                  ? null
                  : () => _editMilestone(context, app, goal, milestone),
              onDelete: goal.isAchieved
                  ? null
                  : () => _deleteMilestone(context, app, milestone),
            ),
        const SizedBox(height: 20),
        if (goal.isAchieved)
          PrimaryButton(
            label: 'View celebration',
            icon: Icons.emoji_events_outlined,
            onPressed: () => GoalFlows.openAchieved(context, goal.id),
          )
        else if (goal.isFinancial)
          PrimaryButton(
            label: 'Log earnings',
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () => _logEarnings(context, app, goal),
          )
        else
          SecondaryButton(
            label: 'Mark goal complete',
            icon: Icons.check_circle_outline,
            onPressed: () => _setCompleted(context, app, goal, completed: true),
          ),
      ],
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    AppViewModel app,
    Goal goal,
    _GoalMenu action,
  ) async {
    switch (action) {
      case _GoalMenu.focus:
        app.setFocusGoal(goal.id);
        context.showSnack('Now showing on Home.');
      case _GoalMenu.edit:
        final GoalDraft? draft = await showGoalForm(context, initial: goal);
        if (draft == null || !context.mounted) {
          return;
        }
        final bool achieved = app.updateGoal(
          goal.id,
          title: draft.title,
          trackingType: draft.trackingType,
          targetAmount: draft.targetAmount,
          why: draft.why,
        );
        await GoalFlows.celebrateIf(
          context,
          achieved: achieved,
          goalId: goal.id,
        );
      case _GoalMenu.complete:
        await _setCompleted(context, app, goal, completed: !goal.isAchieved);
      case _GoalMenu.delete:
        final bool confirmed = await confirmDestructive(
          context,
          title: 'Delete goal?',
          message:
              '"${goal.title}" and its milestones will be removed. '
              'This cannot be undone.',
          confirmLabel: 'Delete',
        );
        if (confirmed && context.mounted) {
          Navigator.pop(context);
          app.deleteGoal(goal.id);
        }
    }
  }

  Future<void> _setCompleted(
    BuildContext context,
    AppViewModel app,
    Goal goal, {
    required bool completed,
  }) async {
    app.setGoalCompleted(goal.id, completed: completed);
    await GoalFlows.celebrateIf(context, achieved: completed, goalId: goal.id);
  }

  Future<void> _editMilestone(
    BuildContext context,
    AppViewModel app,
    Goal goal, [
    Milestone? milestone,
  ]) async {
    final MilestoneDraft? draft = await showMilestoneSheet(
      context,
      initial: milestone,
    );
    if (draft == null || !context.mounted) {
      return;
    }
    final bool achieved = app.saveMilestone(
      goal.id,
      milestoneId: milestone?.id,
      title: draft.title,
      status: draft.status,
      note: draft.note,
      valueLabel: draft.valueLabel,
    );
    await GoalFlows.celebrateIf(context, achieved: achieved, goalId: goal.id);
  }

  Future<void> _deleteMilestone(
    BuildContext context,
    AppViewModel app,
    Milestone milestone,
  ) async {
    final bool confirmed = await confirmDestructive(
      context,
      title: 'Delete milestone?',
      message: 'Remove "${milestone.title}" from this goal?',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      app.deleteMilestone(goalId, milestone.id);
    }
  }

  Future<void> _logEarnings(
    BuildContext context,
    AppViewModel app,
    Goal goal,
  ) async {
    final double? amount = await showThryveSheet<double>(
      context,
      (BuildContext context) => _LogEarningsSheet(goal: goal),
    );
    if (amount == null || !context.mounted) {
      return;
    }
    final bool achieved = app.logEarnings(goal.id, amount);
    if (!achieved) {
      context.showSnack(
        'Logged ${Formatters.money(goal.currencySymbol, amount)}. Keep going!',
      );
    }
    await GoalFlows.celebrateIf(context, achieved: achieved, goalId: goal.id);
  }
}

class _LogEarningsSheet extends StatefulWidget {
  const _LogEarningsSheet({required this.goal});

  final Goal goal;

  @override
  State<_LogEarningsSheet> createState() => _LogEarningsSheetState();
}

class _LogEarningsSheetState extends State<_LogEarningsSheet> {
  final TextEditingController _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final double? amount = Formatters.parseAmount(_amount.text);
    if (amount == null) {
      setState(() => _error = 'Enter an amount greater than zero');
      return;
    }
    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final Goal goal = widget.goal;
    final double remaining = (goal.targetAmount - goal.currentAmount).clamp(
      0,
      double.infinity,
    );
    return ThryveBottomSheet(
      title: 'Log earnings',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${Formatters.money(goal.currencySymbol, remaining)} to go',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            autofocus: true,
            onSubmitted: (_) => _submit(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: goal.currencySymbol,
              labelText: 'Amount',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Log')),
      ],
    );
  }
}
