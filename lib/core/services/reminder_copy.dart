/// Text for the daily reminder. Shared by the onboarding preview and the
/// scheduled notification so what users see is what they get.
class ReminderCopy {
  const ReminderCopy({required this.name, required this.anchor});

  final String name;
  final String anchor;

  String get title => name.trim().isNotEmpty
      ? 'Hey ${name.trim()}, time to thryve 🌱'
      : 'Time to thryve 🌱';

  /// The part of [body] that the preview highlights.
  String get highlight {
    if (anchor.trim().isNotEmpty) {
      return anchor.trim();
    }
    if (name.trim().isNotEmpty) {
      return '${name.trim()}. Keep going.';
    }
    return 'Your future self will thank you.';
  }

  String get body {
    const String lead = 'Take a few minutes of action today.';
    if (anchor.trim().isNotEmpty) {
      return '$lead $highlight';
    }
    if (name.trim().isNotEmpty) {
      return 'Take a few minutes of action today, $highlight';
    }
    return '$lead $highlight';
  }
}
