import '../../core/utils/date_utils.dart';
import 'discipline_task.dart';
import 'goal.dart';
import 'user_profile.dart';
import 'wall_item.dart';
import 'weekly_review.dart';

/// Everything Thryve persists, serialized as one JSON document.
class AppState {
  const AppState({
    this.onboardingComplete = false,
    this.notificationsEnabled = true,
    this.user = UserProfile.empty,
    this.goals = const <Goal>[],
    this.tasks = const <DisciplineTask>[],
    this.tasksDay = '',
    this.wallItems = const <WallItem>[],
    this.reviews = const <WeeklyReview>[],
    this.activity = const <String, int>{},
  });

  /// Reads both the current schema and the v1 schema written by earlier
  /// builds (single review, string focus window, flag-based achievement).
  factory AppState.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic value) => parse(value as Map<String, dynamic>))
            .toList();

    final List<WeeklyReview> reviews = list('reviews', WeeklyReview.fromJson);
    final DateTime? legacyReviewAt = DateTime.tryParse(
      json['reviewSavedAt'] as String? ?? '',
    );
    if (reviews.isEmpty && legacyReviewAt != null) {
      reviews.add(
        WeeklyReview(
          weekKey: DateKeys.weekKey(legacyReviewAt),
          stars: json['vibeStars'] as int? ?? 0,
          reflection: json['reflection'] as String? ?? '',
          savedAt: legacyReviewAt,
        ),
      );
    }

    return AppState(
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      user: json['user'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
          : UserProfile.empty,
      goals: list('goals', Goal.fromJson),
      tasks: list('tasks', DisciplineTask.fromJson),
      tasksDay: json['tasksDay'] as String? ?? '',
      wallItems: list('wallItems', WallItem.fromJson),
      reviews: reviews,
      activity:
          (json['activity'] as Map<String, dynamic>? ?? <String, dynamic>{})
              .map(
                (String key, dynamic value) =>
                    MapEntry<String, int>(key, (value as num).toInt()),
              ),
    );
  }

  static const int schemaVersion = 2;

  final bool onboardingComplete;
  final bool notificationsEnabled;
  final UserProfile user;
  final List<Goal> goals;
  final List<DisciplineTask> tasks;

  /// The day (`yyyy-MM-dd`) that [tasks] completion flags belong to.
  final String tasksDay;
  final List<WallItem> wallItems;
  final List<WeeklyReview> reviews;

  /// Actions taken per day (`yyyy-MM-dd` → count). Drives streaks and the
  /// weekly review.
  final Map<String, int> activity;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'version': schemaVersion,
    'onboardingComplete': onboardingComplete,
    'notificationsEnabled': notificationsEnabled,
    'user': user.toJson(),
    'goals': goals.map((Goal goal) => goal.toJson()).toList(),
    'tasks': tasks.map((DisciplineTask task) => task.toJson()).toList(),
    'tasksDay': tasksDay,
    'wallItems': wallItems.map((WallItem item) => item.toJson()).toList(),
    'reviews': reviews.map((WeeklyReview review) => review.toJson()).toList(),
    'activity': activity,
  };
}
