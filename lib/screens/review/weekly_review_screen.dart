import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../../view_models/weekly_review_view_model.dart';
import '../../view_models/app_view_model.dart';
import 'package:intl/intl.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyReviewViewModel>(
      builder: (context, vm, _) {
        final AppViewModel app = context.watch<AppViewModel>();
        final DateTime now = DateTime.now();
        final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
        final DateTime sunday = monday.add(const Duration(days: 6));
        final List<String> wins = <String>[
          if (app.tasks.any((DisciplineTask task) => task.completed))
            '${app.tasks.where((DisciplineTask task) => task.completed).length} discipline practice${app.tasks.where((DisciplineTask task) => task.completed).length == 1 ? '' : 's'} completed',
          if (app.activeGoal.milestones.any(
            (Milestone milestone) =>
                milestone.status == MilestoneStatus.completed,
          ))
            '${app.activeGoal.milestones.where((Milestone milestone) => milestone.status == MilestoneStatus.completed).length} milestone${app.activeGoal.milestones.where((Milestone milestone) => milestone.status == MilestoneStatus.completed).length == 1 ? '' : 's'} completed',
          if (app.activeGoal.progressPercent > 0)
            '${app.activeGoal.progressPercent}% progress on ${app.activeGoal.title}',
        ];
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              ThryveSliverHeader(avatarUrl: app.user.avatarUrl),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Weekly Review',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d').format(monday)} – ${DateFormat('MMM d, y').format(sunday)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ThryveCard(
                      child: Column(
                        children: [
                          const SectionLabel('How did this week feel?'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final filled = i < vm.vibeStars;
                              return GestureDetector(
                                onTap: () => vm.setVibeStars(i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Icon(
                                    filled ? Icons.star : Icons.star_border,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vm.vibeStars == 0
                                ? 'Tap a star to check in'
                                : <String>[
                                    '',
                                    'Heavy week',
                                    'A little difficult',
                                    'Steady week',
                                    'Good momentum',
                                    'Great week',
                                  ][vm.vibeStars],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
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
                                Icons.celebration_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Wins this week',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (wins.isEmpty)
                            Text(
                              'Your wins will appear here as you complete practices and milestones.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            ...wins.map((String win) => _WinItem(win)),
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
                                Icons.center_focus_strong,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Focus next week',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Keep moving toward ${app.user.bigDream ?? 'your big dream'} and protect your ${app.user.focusWindow ?? 'focus'} window.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ThryveCard(
                      color: AppColors.primaryContainer.withValues(alpha: 0.12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your weekly takeaway',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Write one thing you learned, noticed, or want to remember from this week.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your reflection',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: vm.reflectionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  'Example: I made more progress when I protected my focus time.',
                              filled: true,
                              fillColor: AppColors.surfaceContainerLowest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: app.reviewSavedAt == null
                          ? 'Save review'
                          : 'Save changes',
                      onPressed: () async {
                        if (vm.vibeStars == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Choose an overall vibe first.'),
                            ),
                          );
                          return;
                        }
                        await app.saveReview(
                          stars: vm.vibeStars,
                          text: vm.reflectionController.text,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Weekly review saved.'),
                            ),
                          );
                        }
                      },
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
}

class _WinItem extends StatelessWidget {
  final String text;
  const _WinItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
