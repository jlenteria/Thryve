import 'package:flutter_test/flutter_test.dart';
import 'package:thryve/core/utils/streak_calculator.dart';

void main() {
  final DateTime today = DateTime(2026, 10, 4, 15);

  test('counts consecutive days ending today', () {
    final Map<String, int> activity = <String, int>{
      '2026-10-02': 1,
      '2026-10-03': 2,
      '2026-10-04': 1,
    };
    expect(StreakCalculator.current(activity, now: today), 3);
  });

  test("keeps yesterday's streak alive before today's first action", () {
    final Map<String, int> activity = <String, int>{
      '2026-10-02': 1,
      '2026-10-03': 1,
    };
    expect(StreakCalculator.current(activity, now: today), 2);
  });

  test('resets after a missed day', () {
    final Map<String, int> activity = <String, int>{
      '2026-10-01': 1,
      '2026-10-03': 1,
    };
    expect(StreakCalculator.current(activity, now: today), 1);
    expect(StreakCalculator.current(<String, int>{}, now: today), 0);
  });

  test('finds the longest run inside a range', () {
    final Map<String, int> activity = <String, int>{
      '2026-09-01': 1,
      '2026-09-02': 1,
      '2026-09-03': 1,
      '2026-09-05': 1,
    };
    expect(
      StreakCalculator.longest(
        activity,
        from: DateTime(2026, 9),
        to: DateTime(2026, 9, 30),
      ),
      3,
    );
  });
}
