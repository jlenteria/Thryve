import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../view_models/app_view_model.dart';
import '../../widgets/common_widgets.dart';
import 'goal_achieved_screen.dart';
import 'goal_detail_screen.dart';

class GoalsHubScreen extends StatelessWidget {
  const GoalsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final List<Goal> activeGoals = app.goals
        .where((Goal goal) => !goal.isAchieved)
        .toList();
    final Goal? active = activeGoals.isEmpty ? null : activeGoals.first;
    final List<Goal> completed = app.goals
        .where((Goal goal) => goal.isAchieved)
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          ThryveSliverHeader(avatarUrl: app.user.avatarUrl),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Text('Goals', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text(
                  'Turn what matters to you into small, visible progress.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _sectionTitle(context, 'Active goal'),
                const SizedBox(height: 10),
                if (active == null)
                  ThryveCard(
                    child: Text(
                      'You have no active goal. Start something meaningful next.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ThryveCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GoalDetailScreen(goalId: active.id),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          active.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          active.isFinancial
                              ? '${active.currencySymbol}${active.currentAmount.toStringAsFixed(0)} of ${active.currencySymbol}${active.targetAmount.toStringAsFixed(0)}'
                              : '${active.progressPercent}% complete',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        ProgressBar(progress: active.progress, height: 9),
                        const SizedBox(height: 12),
                        Text(
                          '${active.milestones.where((Milestone item) => item.status == MilestoneStatus.completed).length}/${active.milestones.length} milestones complete',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                _sectionTitle(context, 'Completed goals'),
                const SizedBox(height: 10),
                if (completed.isEmpty)
                  Text(
                    'Completed goals will stay here as a record of your growth.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...completed.map(
                    (Goal goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text(goal.title),
                        subtitle: Text(
                          goal.isFinancial ? 'Financial goal' : 'Personal goal',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GoalAchievedScreen(goalId: goal.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Add another goal',
                  icon: Icons.add,
                  onPressed: () => _addGoal(context, app),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) =>
      Text(title, style: Theme.of(context).textTheme.titleLarge);

  Future<void> _addGoal(BuildContext context, AppViewModel app) async {
    String title = '';
    String target = '';
    String why = '';
    GoalTrackingType type = GoalTrackingType.progress;
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Add a goal',
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                onChanged: (String value) => title = value,
                decoration: const InputDecoration(
                  labelText: 'What do you want to achieve?',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GoalTrackingType>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'How will you track it?',
                ),
                items: const <DropdownMenuItem<GoalTrackingType>>[
                  DropdownMenuItem(
                    value: GoalTrackingType.progress,
                    child: Text('Personal progress'),
                  ),
                  DropdownMenuItem(
                    value: GoalTrackingType.money,
                    child: Text('Financial progress'),
                  ),
                ],
                onChanged: (GoalTrackingType? value) {
                  if (value != null) setState(() => type = value);
                },
              ),
              if (type == GoalTrackingType.money) ...<Widget>[
                const SizedBox(height: 12),
                TextField(
                  onChanged: (String value) => target = value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target amount'),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                onChanged: (String value) => why = value,
                decoration: const InputDecoration(
                  labelText: 'Why does this matter?',
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create goal'),
          ),
        ],
      ),
    );
    final double? parsed = double.tryParse(target.replaceAll(',', '').trim());
    final double amount = type == GoalTrackingType.progress && parsed == null
        ? 0
        : (parsed ?? -1);
    if (saved == true &&
        title.trim().isNotEmpty &&
        amount >= 0 &&
        (type == GoalTrackingType.progress || amount > 0)) {
      app.addGoal(
        title: title,
        targetAmount: amount,
        why: why,
        trackingType: type,
      );
    }
  }
}
