import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_ext.dart';
import '../../../core/state/app_view_model.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/thryve_card.dart';
import '../../../core/widgets/thryve_page.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/weekly_review.dart';
import '../../shell/view_models/main_shell_view_model.dart';
import '../view_models/weekly_review_view_model.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the form when the calendar week changes while the app is open.
    final String weekKey = context.select<AppViewModel, String>(
      (AppViewModel app) => DateKeys.weekKey(app.clock()),
    );
    return ChangeNotifierProvider<WeeklyReviewViewModel>(
      key: ValueKey<String>(weekKey),
      create: (BuildContext context) =>
          WeeklyReviewViewModel(context.read<AppViewModel>()),
      child: const _WeeklyReviewView(),
    );
  }
}

class _WeeklyReviewView extends StatelessWidget {
  const _WeeklyReviewView();

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final WeeklyReviewViewModel vm = context.watch<WeeklyReviewViewModel>();
    final WeekSummary week = app.weekSummary;
    final Goal? focus = app.focusGoal;
    final ColorScheme colors = context.colors;
    final TextTheme text = context.text;

    final List<String> wins = <String>[
      if (week.actions > 0)
        '${Formatters.plural(week.actions, 'action')} taken on ${Formatters.plural(week.activeDays, 'day')}',
      if (week.milestonesCompleted > 0)
        '${Formatters.plural(week.milestonesCompleted, 'milestone')} completed',
      if (week.goalsAchieved > 0)
        '${Formatters.plural(week.goalsAchieved, 'goal')} achieved 🎉',
      if (app.currentStreak > 1)
        '${Formatters.plural(app.currentStreak, 'day')} streak and counting',
    ];

    return ThryveTabPage(
      onAvatarTap: () => context.goToTab(ShellTab.settings),
      children: <Widget>[
        PageHeading(
          title: 'Weekly Review',
          subtitle:
              '${Formatters.shortDate(week.start)} – '
              '${Formatters.longDate(week.end)}',
        ),
        const SizedBox(height: 24),
        ThryveCard(
          child: Column(
            children: <Widget>[
              const SectionLabel('How did this week feel?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: WeeklyReview.vibeLabels[i],
                      onPressed: () => vm.setStars(i),
                      iconSize: 32,
                      color: colors.primary,
                      icon: Icon(
                        i <= vm.stars ? Icons.star : Icons.star_border,
                      ),
                    ),
                ],
              ),
              Text(vm.vibeLabel, style: text.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReviewSection(
          icon: Icons.celebration_outlined,
          title: 'Wins this week',
          child: wins.isEmpty
              ? Text(
                  'Complete a practice or milestone and your wins will '
                  'show up here.',
                  style: text.bodyMedium,
                )
              : Column(
                  children: <Widget>[for (final String w in wins) CheckRow(w)],
                ),
        ),
        const SizedBox(height: 16),
        _ReviewSection(
          icon: Icons.center_focus_strong,
          title: 'Focus next week',
          child: Text(
            focus == null
                ? 'Choose a goal to focus on next week.'
                : 'Keep moving toward "${focus.title}" and protect your '
                      '${Formatters.timeOfDay(app.user.reminderTime)} focus time.',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 16),
        ThryveCard(
          color: colors.primaryContainer.withValues(alpha: 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your weekly takeaway',
                style: text.titleLarge?.copyWith(color: colors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'One thing you learned, noticed, or want to remember.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vm.reflection,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. I made more progress when I protected my '
                      'focus time.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: vm.isSaved ? 'Save changes' : 'Save review',
          onPressed: () async {
            final String? error = await vm.save();
            if (context.mounted) {
              context.showSnack(error ?? 'Weekly review saved.');
            }
          },
        ),
        if (app.pastReviews.isNotEmpty) ...<Widget>[
          const SizedBox(height: 32),
          Text('Past reviews', style: text.titleLarge),
          const SizedBox(height: 10),
          for (final WeeklyReview review in app.pastReviews.take(8))
            _PastReviewTile(review: review),
        ],
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ThryveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: context.colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: context.text.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PastReviewTile extends StatelessWidget {
  const _PastReviewTile({required this.review});

  final WeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final DateTime start = DateKeys.parse(review.weekKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ThryveCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Week of ${Formatters.longDate(start)}',
                    style: context.text.titleSmall,
                  ),
                ),
                Text(
                  '${'★' * review.stars}${'☆' * (5 - review.stars)}',
                  style: TextStyle(color: context.colors.primary),
                ),
              ],
            ),
            if (review.reflection.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(review.reflection, style: context.text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
