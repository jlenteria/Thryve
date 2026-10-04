import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thryve/main.dart';
import 'package:thryve/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('shows the Thryve onboarding flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ThryveApp());
    await tester.pumpAndSettle();

    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    expect(find.text("What's your name?"), findsOneWidget);
    expect(find.text('And your big dream?'), findsOneWidget);
  });

  testWidgets('primary button does not overflow in a narrow action row',
      (WidgetTester tester) async {
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
