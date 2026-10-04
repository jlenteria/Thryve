import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thryve/view_models/app_view_model.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('persists onboarding and user changes', () async {
    final AppViewModel app = AppViewModel();
    await app.load();

    await app.completeOnboarding(
      name: 'Alex',
      dream: 'Build a studio',
      anchor: 'My family',
      focusWindow: '8:00 AM',
    );

    final AppViewModel restored = AppViewModel();
    await restored.load();
    expect(restored.onboardingComplete, isTrue);
    expect(restored.user.name, 'Alex');
    expect(restored.user.bigDream, 'Build a studio');
  });

  test('updates tasks, milestones, earnings, wall, and review', () async {
    final AppViewModel app = AppViewModel();
    await app.load();
    final String goalId = app.activeGoal.id;
    final bool originalTaskValue = app.tasks.first.completed;

    app.toggleTask(app.tasks.first.id);
    app.addMilestone(goalId, 'Ship the proposal');
    final double remaining = app.activeGoal.targetAmount - app.activeGoal.currentAmount;
    final goal = app.logEarnings(goalId, remaining);
    app.addWallItem(
      title: 'Future office',
      category: 'Workspace',
      imageUrl: 'https://example.com/office.jpg',
    );
    await app.saveReview(stars: 5, text: 'Consistent action worked.');

    expect(app.tasks.first.completed, isNot(originalTaskValue));
    expect(goal.isAchieved, isTrue);
    expect(app.goals.first.milestones.last.title, 'Ship the proposal');
    expect(app.wallItems.first.title, 'Future office');
    expect(app.vibeStars, 5);
    expect(app.reflection, 'Consistent action worked.');
  });
}
