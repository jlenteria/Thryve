import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_view_model.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/thryve_card.dart';
import '../../../core/widgets/thryve_page.dart';
import '../../../data/models/goal.dart';
import '../../shell/view_models/main_shell_view_model.dart';
import '../goal_flows.dart';
import '../widgets/goal_widgets.dart';

class GoalsHubScreen extends StatelessWidget {
  const GoalsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final List<Goal> active = app.activeGoals;
    final List<Goal> completed = app.completedGoals;
    final TextTheme text = Theme.of(context).textTheme;

    return ThryveTabPage(
      onAvatarTap: () => context.goToTab(ShellTab.settings),
      children: <Widget>[
        const PageHeading(
          title: 'Goals',
          subtitle: 'Turn what matters to you into small, visible progress.',
        ),
        const SizedBox(height: 24),
        Text('Active', style: text.titleLarge),
        const SizedBox(height: 10),
        if (active.isEmpty)
          CalloutCard(
            icon: Icons.flag_outlined,
            title: 'Nothing in progress',
            message: 'Start something meaningful — one goal is enough.',
            onTap: () => GoalFlows.create(context),
          )
        else
          for (final (int index, Goal goal) in active.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GoalProgressCard(
                goal: goal,
                label: index == 0 ? 'Focus goal' : null,
                onTap: () => GoalFlows.openDetail(context, goal.id),
              ),
            ),
        const SizedBox(height: 4),
        PrimaryButton(
          label: 'Add a goal',
          icon: Icons.add,
          onPressed: () => GoalFlows.create(context),
        ),
        const SizedBox(height: 28),
        Text('Completed', style: text.titleLarge),
        const SizedBox(height: 10),
        if (completed.isEmpty)
          Text(
            'Completed goals stay here as a record of your growth.',
            style: text.bodyMedium,
          )
        else
          for (final Goal goal in completed)
            CompletedGoalTile(
              goal: goal,
              onTap: () => GoalFlows.openAchieved(context, goal.id),
            ),
      ],
    );
  }
}
