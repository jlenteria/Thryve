import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thryve/core/state/app_view_model.dart';
import 'package:thryve/data/models/goal.dart';
import 'package:thryve/data/models/milestone.dart';
import 'package:thryve/data/models/wall_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime now;
  AppViewModel createApp() => AppViewModel(clock: () => now);

  Future<AppViewModel> onboarded({String dream = 'Build a studio'}) async {
    final AppViewModel app = createApp();
    await app.load();
    await app.completeOnboarding(
      name: 'Alex',
      dream: dream,
      anchor: 'My family',
      reminderTime: const TimeOfDay(hour: 7, minute: 30),
      remindersEnabled: false,
    );
    return app;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    now = DateTime(2026, 10, 5, 9); // A Monday.
  });

  test('new users start with no demo data', () async {
    final AppViewModel app = createApp();
    await app.load();
    expect(app.onboardingComplete, isFalse);
    expect(app.goals, isEmpty);
    expect(app.tasks, isEmpty);
    expect(app.wallItems, isEmpty);
    expect(app.user.avatar, isNull);
    expect(app.focusGoal, isNull);
  });

  test(
    'onboarding creates the first goal from the dream and persists',
    () async {
      await onboarded();

      final AppViewModel restored = createApp();
      await restored.load();
      expect(restored.onboardingComplete, isTrue);
      expect(restored.user.name, 'Alex');
      expect(restored.user.reminderTime, const TimeOfDay(hour: 7, minute: 30));
      final Goal goal = restored.goals.single;
      expect(goal.title, 'Build a studio');
      expect(goal.why, 'My family');
      expect(goal.trackingType, GoalTrackingType.progress);
    },
  );

  test('financial-sounding dreams start as money goals', () async {
    final AppViewModel app = await onboarded(dream: 'Earn ₱50k freelancing');
    expect(app.focusGoal!.trackingType, GoalTrackingType.money);
  });

  test('goal edits survive a restart (regression)', () async {
    final AppViewModel app = await onboarded();
    final String id = app.focusGoal!.id;
    app.updateGoal(
      id,
      title: 'Open a pottery studio',
      trackingType: GoalTrackingType.money,
      targetAmount: 80000,
      why: 'Independence',
    );
    await app.updateProfile(name: 'Alex', dream: 'Something else', anchor: 'x');
    await app.flush();

    final AppViewModel restored = createApp();
    await restored.load();
    final Goal goal = restored.goalById(id)!;
    expect(goal.title, 'Open a pottery studio');
    expect(goal.trackingType, GoalTrackingType.money);
    expect(goal.targetAmount, 80000);
  });

  test(
    'a goal with no milestones can be marked complete (regression)',
    () async {
      final AppViewModel app = await onboarded();
      final String id = app.focusGoal!.id;
      app.setGoalCompleted(id, completed: true);
      expect(app.goalById(id)!.isAchieved, isTrue);
      expect(app.goalById(id)!.achievedAt, now);

      app.setGoalCompleted(id, completed: false);
      expect(app.goalById(id)!.isAchieved, isFalse);
    },
  );

  test(
    'completing every milestone achieves the goal and logs activity',
    () async {
      final AppViewModel app = await onboarded();
      final String id = app.focusGoal!.id;
      expect(
        app.saveMilestone(
          id,
          title: 'Find a space',
          status: MilestoneStatus.pending,
        ),
        isFalse,
      );
      final String milestoneId = app.goalById(id)!.milestones.single.id;

      final bool achieved = app.saveMilestone(
        id,
        milestoneId: milestoneId,
        title: 'Find a space',
        status: MilestoneStatus.completed,
      );

      expect(achieved, isTrue);
      expect(app.goalById(id)!.milestones.single.completedAt, now);
      expect(app.currentStreak, 1);
      expect(app.weekSummary.milestonesCompleted, 1);
      expect(app.weekSummary.goalsAchieved, 1);
      expect(app.focusGoal, isNull);
    },
  );

  test('earnings complete a money goal when the target is reached', () async {
    final AppViewModel app = await onboarded();
    final Goal goal = app.createGoal(
      title: 'Emergency fund',
      trackingType: GoalTrackingType.money,
      targetAmount: 1000,
    );
    expect(app.logEarnings(goal.id, 400), isFalse);
    expect(app.logEarnings(goal.id, 600), isTrue);
    expect(app.goalById(goal.id)!.currentAmount, 1000);
    expect(app.weekSummary.actions, 2);
  });

  test('all active goals are listed and focus can move', () async {
    final AppViewModel app = await onboarded();
    final Goal second = app.createGoal(
      title: 'Run a 10k',
      trackingType: GoalTrackingType.progress,
    );
    expect(app.activeGoals, hasLength(2));
    expect(app.focusGoal!.title, 'Build a studio');

    app.setFocusGoal(second.id);
    expect(app.focusGoal!.id, second.id);

    app.deleteGoal(second.id);
    expect(app.activeGoals, hasLength(1));
  });

  test('practices build a streak and reset on a new day', () async {
    final AppViewModel app = await onboarded();
    app.saveTask(title: 'Sketch for 20 minutes');
    final String taskId = app.tasks.single.id;

    app.toggleTask(taskId);
    expect(app.completedTasksToday, 1);
    expect(app.currentStreak, 1);

    // Unchecking undoes today's activity.
    app.toggleTask(taskId);
    expect(app.currentStreak, 0);
    app.toggleTask(taskId);

    now = now.add(const Duration(days: 1));
    app.refreshDay();
    expect(app.completedTasksToday, 0);
    expect(app.currentStreak, 1, reason: "yesterday's streak still counts");

    app.toggleTask(taskId);
    expect(app.currentStreak, 2);
  });

  test('weekly reviews are kept per week', () async {
    final AppViewModel app = await onboarded();
    await app.saveReview(stars: 4, reflection: 'Good start');
    expect(app.currentReview!.stars, 4);

    await app.saveReview(stars: 5, reflection: 'Even better');
    expect(app.currentReview!.reflection, 'Even better');
    expect(app.pastReviews, isEmpty);

    now = now.add(const Duration(days: 7));
    expect(app.currentReview, isNull);
    expect(app.pastReviews.single.stars, 5);
  });

  test('only one Wall item can be pinned', () async {
    final AppViewModel app = await onboarded();
    app.addWallItem(
      title: 'A',
      category: 'Home',
      image: 'https://a.test/a.jpg',
    );
    app.addWallItem(
      title: 'B',
      category: 'Home',
      image: 'https://a.test/b.jpg',
    );
    final String a = app.wallItems.last.id;
    final String b = app.wallItems.first.id;

    app.toggleWallPinned(a);
    expect(app.featuredWallItem!.id, a);
    app.toggleWallPinned(b);
    expect(app.wallItems.where((WallItem item) => item.isPinned), hasLength(1));
    expect(app.featuredWallItem!.id, b);

    app.removeWallItem(b);
    expect(app.featuredWallItem!.id, a);
  });

  test('reset clears everything', () async {
    final AppViewModel app = await onboarded();
    await app.resetApp();
    expect(app.onboardingComplete, isFalse);
    expect(app.goals, isEmpty);

    final AppViewModel restored = createApp();
    await restored.load();
    expect(restored.onboardingComplete, isFalse);
  });
}
