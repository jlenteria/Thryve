/// Calendar helpers. All keys are local-time `yyyy-MM-dd` strings so they sort
/// lexically and survive JSON round-trips without timezone drift.
abstract final class DateKeys {
  static String of(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  static String today([DateTime? now]) => of(now ?? DateTime.now());

  static DateTime parse(String key) {
    final List<String> parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Monday of the week containing [date], at midnight.
  static DateTime weekStart(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static String weekKey([DateTime? now]) =>
      of(weekStart(now ?? DateTime.now()));

  /// Whole calendar days from [from] to [to], ignoring time of day.
  static int daysBetween(DateTime from, DateTime to) {
    final DateTime a = DateTime(from.year, from.month, from.day);
    final DateTime b = DateTime(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
