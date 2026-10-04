/// One check-in per calendar week, keyed by the Monday it starts on.
class WeeklyReview {
  const WeeklyReview({
    required this.weekKey,
    required this.stars,
    required this.reflection,
    required this.savedAt,
  });

  factory WeeklyReview.fromJson(Map<String, dynamic> json) => WeeklyReview(
    weekKey: json['weekKey'] as String,
    stars: json['stars'] as int? ?? 0,
    reflection: json['reflection'] as String? ?? '',
    savedAt:
        DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
  );

  static const List<String> vibeLabels = <String>[
    'Tap a star to check in',
    'Heavy week',
    'A little difficult',
    'Steady week',
    'Good momentum',
    'Great week',
  ];

  /// `yyyy-MM-dd` of the week's Monday.
  final String weekKey;
  final int stars;
  final String reflection;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'weekKey': weekKey,
    'stars': stars,
    'reflection': reflection,
    'savedAt': savedAt.toIso8601String(),
  };
}
