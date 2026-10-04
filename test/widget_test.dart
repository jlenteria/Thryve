import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thryve/app.dart';
import 'package:thryve/core/constants/app_constants.dart';
import 'package:thryve/core/state/app_view_model.dart';
import 'package:thryve/core/widgets/buttons/primary_button.dart';
import 'package:thryve/data/models/goal.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('completes onboarding and lands on Home', (
    WidgetTester tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(const ThryveApp());
    await tester.pumpAndSettle();

    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Alex');
    await tester.enterText(find.byType(TextFormField).at(1), 'Build a studio');
    await tester.ensureVisible(find.text('Continue').first);
    await tester.tap(find.text('Continue').first);
    await tester.pumpAndSettle();

    expect(find.text('STEP 2 OF 3'), findsOneWidget);
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('When will you grow?'), findsOneWidget);
    expect(find.text('Hey Alex, time to thryve 🌱'), findsOneWidget);
    await tester.ensureVisible(find.text("I'll set this later"));
    await tester.tap(find.text("I'll set this later"));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Alex.'), findsOneWidget);
    expect(find.text('Build a studio'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
  });

  testWidgets('step 1 shows validation instead of a dead button', (
    WidgetTester tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(const ThryveApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue').first);
    await tester.tap(find.text('Continue').first);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
  });

  testWidgets('every tab renders in dark mode without errors', (
    WidgetTester tester,
  ) async {
    await setPhoneSize(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConstants.themeKey: ThemeMode.dark.name,
    });
    final AppViewModel app = AppViewModel();
    await app.load();
    await app.completeOnboarding(
      name: 'Alex',
      dream: 'Build a studio',
      anchor: 'My family',
      reminderTime: const TimeOfDay(hour: 8, minute: 0),
      remindersEnabled: false,
    );
    app.createGoal(
      title: 'Emergency fund',
      trackingType: GoalTrackingType.money,
      targetAmount: 5000,
    );
    app.saveTask(title: 'Sketch');

    await tester.pumpWidget(ThryveApp(appViewModel: app));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.text('Hello, Alex.'));
    expect(Theme.of(context).brightness, Brightness.dark);

    for (final String tab in <String>['Goals', 'Wall', 'Review', 'Settings']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab tab');
    }
    expect(find.text('Shape your Thryve experience.'), findsOneWidget);
  });

  testWidgets('primary button does not overflow in a narrow row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 179,
              child: PrimaryButton(
                label: 'Log Earnings',
                icon: Icons.account_balance_wallet_outlined,
                onPressed: null,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Log Earnings'), findsOneWidget);
  });
}
