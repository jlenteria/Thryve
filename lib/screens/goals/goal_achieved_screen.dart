import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../../view_models/app_view_model.dart';

class GoalAchievedScreen extends StatelessWidget {
  final String goalId;

  const GoalAchievedScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final Goal goal = app.goals.firstWhere((Goal value) => value.id == goalId);
    final String anchor = app.user.anchor ?? goal.why ?? 'your purpose';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const SizedBox.shrink(),
        title: Text(
          'Thryve',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            SectionLabel('Goal Achieved', color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              goal.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            // Trophy
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),

            // Why recap
            ThryveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SectionLabel('The Why Recap'),
                      const Spacer(),
                      Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: AppColors.outlineVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.titleLarge,
                      children: [
                        const TextSpan(text: 'Doing this for: '),
                        TextSpan(
                          text: anchor,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"$anchor"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Completion bar
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'COMPLETION',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                Text(
                  '100%',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(progress: 1.0, height: 8),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: ThryveCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal.isFinancial ? 'EARNED' : 'MILESTONES',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.isFinancial
                              ? '${goal.currencySymbol}${goal.currentAmount.toStringAsFixed(0)}'
                              : '${goal.milestones.where((Milestone m) => m.status == MilestoneStatus.completed).length}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThryveCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TIME TAKEN',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${goal.daysTaken ?? 47} Days',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Consistency
            ThryveCard(
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONSISTENCY',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '${goal.consistencyStreak ?? 31}-day streak',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MASTERED',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              label: 'Level up this goal',
              icon: Icons.trending_up,
              onPressed: () {
                app.addGoal(
                  title: '${goal.title} — Next Level',
                  targetAmount: goal.targetAmount * 2,
                  why: goal.why ?? 'Keep growing',
                );
                Navigator.popUntil(
                  context,
                  (Route<dynamic> route) => route.isFirst,
                );
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Start a new goal',
              icon: Icons.add,
              onPressed: () => _startNewGoal(context, app),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Text(
                'BACK TO HOME →',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reflection card
            ThryveCard(
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  NetworkImageSafe(
                    url:
                        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&h=300&fit=crop',
                    height: 140,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REFLECTION',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          'Your new workspace awaits.',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
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
    );
  }

  Future<void> _startNewGoal(BuildContext context, AppViewModel app) async {
    String title = '';
    String target = '';
    String why = '';
    GoalTrackingType trackingType = GoalTrackingType.progress;
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => ThryveBottomSheet(
        title: 'Start a new goal',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                onChanged: (String value) => title = value,
                decoration: const InputDecoration(labelText: 'Goal title'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (String value) => target = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target amount (optional for personal goals)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GoalTrackingType>(
                initialValue: trackingType,
                decoration: const InputDecoration(labelText: 'Goal type'),
                items: const <DropdownMenuItem<GoalTrackingType>>[
                  DropdownMenuItem(
                    value: GoalTrackingType.progress,
                    child: Text('Personal goal'),
                  ),
                  DropdownMenuItem(
                    value: GoalTrackingType.money,
                    child: Text('Financial goal'),
                  ),
                ],
                onChanged: (GoalTrackingType? value) {
                  if (value != null) trackingType = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (String value) => why = value,
                decoration: const InputDecoration(labelText: 'Why it matters'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    final double? parsed = double.tryParse(target.trim());
    final double amount =
        trackingType == GoalTrackingType.progress && parsed == null
        ? 0
        : (parsed ?? -1);
    if (saved == true &&
        title.trim().isNotEmpty &&
        amount >= 0 &&
        (trackingType == GoalTrackingType.progress || amount > 0)) {
      app.addGoal(
        title: title,
        targetAmount: amount,
        why: why,
        trackingType: trackingType,
      );
      if (context.mounted)
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
    }
  }
}
