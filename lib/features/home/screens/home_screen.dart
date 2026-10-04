import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_view_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/thryve_card.dart';
import '../../../core/widgets/thryve_page.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/user_profile.dart';
import '../../goals/goal_flows.dart';
import '../../goals/widgets/goal_widgets.dart';
import '../../shell/view_models/main_shell_view_model.dart';
import '../widgets/discipline_card.dart';
import '../widgets/featured_wall_card.dart';

/// Answers "what matters today?": focus goal, daily practices and the
/// featured Wall reminder.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final UserProfile user = app.user;
    final Goal? goal = app.focusGoal;
    final int streak = app.currentStreak;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ThryveTabPage(
      onAvatarTap: () => context.goToTab(ShellTab.settings),
      children: <Widget>[
        PageHeading(
          title: 'Hello, ${user.name.isEmpty ? 'friend' : user.name}.',
          subtitle: user.bigDream?.isNotEmpty == true
              ? 'Growing toward ${user.bigDream}'
              : null,
          trailing: Tooltip(
            message: 'Days in a row with at least one action',
            child: Pill(
              icon: Icons.local_fire_department,
              label: Formatters.plural(streak, 'day'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (user.anchor?.isNotEmpty == true) ...<Widget>[
          ThryveCard(
            color: colors.primary.withValues(alpha: 0.07),
            child: Row(
              children: <Widget>[
                Icon(Icons.favorite_outline, color: colors.primary),
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
          const SizedBox(height: 16),
        ],
        if (goal == null)
          CalloutCard(
            icon: Icons.flag_outlined,
            title: 'Choose your next goal',
            message: 'Pick one meaningful thing to grow toward.',
            onTap: () => GoalFlows.create(context),
          )
        else
          GoalProgressCard(
            goal: goal,
            label: 'Focus goal',
            onTap: () => GoalFlows.openDetail(context, goal.id),
          ),
        const SizedBox(height: 16),
        const DisciplineCard(),
        const SizedBox(height: 16),
        FeaturedWallCard(
          item: app.featuredWallItem,
          onOpenWall: () => context.goToTab(ShellTab.wall),
        ),
      ],
    );
  }
}
