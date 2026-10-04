import 'package:flutter/material.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    this.avatar,
    this.bigDream,
    this.anchor,
    this.anchorImage,
    this.reminderHour = 8,
    this.reminderMinute = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final TimeOfDay reminder = json.containsKey('reminderHour')
        ? TimeOfDay(
            hour: json['reminderHour'] as int? ?? 8,
            minute: json['reminderMinute'] as int? ?? 0,
          )
        : _parseLegacyFocusWindow(json['focusWindow'] as String?);
    return UserProfile(
      name: json['name'] as String? ?? '',
      avatar: (json['avatar'] ?? json['avatarUrl']) as String?,
      bigDream: json['bigDream'] as String?,
      anchor: json['anchor'] as String?,
      anchorImage: (json['anchorImage'] ?? json['anchorImageUrl']) as String?,
      reminderHour: reminder.hour,
      reminderMinute: reminder.minute,
    );
  }

  static const UserProfile empty = UserProfile(name: '');

  final String name;

  /// Image reference understood by `AppImage` (local file, data URI or URL).
  final String? avatar;
  final String? bigDream;
  final String? anchor;
  final String? anchorImage;
  final int reminderHour;
  final int reminderMinute;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  String get anchorOrDefault =>
      anchor?.trim().isNotEmpty == true ? anchor!.trim() : 'your purpose';

  UserProfile copyWith({
    String? name,
    String? Function()? avatar,
    String? bigDream,
    String? anchor,
    String? Function()? anchorImage,
    TimeOfDay? reminderTime,
  }) => UserProfile(
    name: name ?? this.name,
    avatar: avatar != null ? avatar() : this.avatar,
    bigDream: bigDream ?? this.bigDream,
    anchor: anchor ?? this.anchor,
    anchorImage: anchorImage != null ? anchorImage() : this.anchorImage,
    reminderHour: reminderTime?.hour ?? reminderHour,
    reminderMinute: reminderTime?.minute ?? reminderMinute,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'avatar': avatar,
    'bigDream': bigDream,
    'anchor': anchor,
    'anchorImage': anchorImage,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
  };

  /// Earlier builds stored the reminder as a formatted string, e.g. "8:00 AM".
  static TimeOfDay _parseLegacyFocusWindow(String? value) {
    const TimeOfDay fallback = TimeOfDay(hour: 8, minute: 0);
    if (value == null) {
      return fallback;
    }
    final RegExpMatch? match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) {
      return fallback;
    }
    int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    final String? period = match.group(3)?.toUpperCase();
    if (period == 'PM' && hour < 12) {
      hour += 12;
    }
    if (period == 'AM' && hour == 12) {
      hour = 0;
    }
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }
}
