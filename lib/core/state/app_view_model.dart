import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/app_state.dart';
import '../../data/models/discipline_task.dart';
import '../../data/models/goal.dart';
import '../../data/models/milestone.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/wall_item.dart';
import '../../data/models/weekly_review.dart';
import '../../data/repositories/app_state_repository.dart';
import '../constants/app_constants.dart';
import '../services/image_store.dart';
import '../services/notification_service.dart';
import '../services/reminder_copy.dart';
import '../utils/date_utils.dart';
import '../utils/streak_calculator.dart';

/// What the current week looks like, for the Weekly Review.
class WeekSummary {
  const WeekSummary({
    required this.start,
    required this.actions,
    required this.activeDays,
    required this.milestonesCompleted,
    required this.goalsAchieved,
  });

  final DateTime start;
  final int actions;
  final int activeDays;
  final int milestonesCompleted;
  final int goalsAchieved;

  DateTime get end => start.add(const Duration(days: 6));

  bool get isEmpty =>
      actions == 0 && milestonesCompleted == 0 && goalsAchieved == 0;
}

/// App-wide state: profile, goals, daily practices, Wall and reviews.
///
/// All business rules (achievement, streaks, day rollover, image cleanup,
/// reminder scheduling) live here so screens only render and forward input.
class AppViewModel extends ChangeNotifier {
  AppViewModel({AppStateRepository? repository, this.clock = DateTime.now})
    : _repository = repository ?? AppStateRepository();

  static const Uuid _uuid = Uuid();

  final AppStateRepository _repository;

  /// Injectable for tests.
  final DateTime Function() clock;

  AppState _state = const AppState();
  bool _isLoaded = false;

  // ── Read model ───────────────────────────────────────────────────

  bool get isLoaded => _isLoaded;
  bool get onboardingComplete => _state.onboardingComplete;
  bool get notificationsEnabled => _state.notificationsEnabled;
  UserProfile get user => _state.user;
  List<Goal> get goals => List<Goal>.unmodifiable(_state.goals);
  List<DisciplineTask> get tasks =>
      List<DisciplineTask>.unmodifiable(_state.tasks);
  List<WallItem> get wallItems => List<WallItem>.unmodifiable(_state.wallItems);

  List<Goal> get activeGoals =>
      _state.goals.where((Goal goal) => !goal.isAchieved).toList();

  List<Goal> get completedGoals {
    final List<Goal> done = _state.goals
        .where((Goal goal) => goal.isAchieved)
        .toList();
    done.sort((Goal a, Goal b) => b.achievedAt!.compareTo(a.achievedAt!));
    return done;
  }

  /// The goal shown on Home: the first active goal in the user's order.
  Goal? get focusGoal {
    for (final Goal goal in _state.goals) {
      if (!goal.isAchieved) {
        return goal;
      }
    }
    return null;
  }

  Goal? goalById(String id) {
    for (final Goal goal in _state.goals) {
      if (goal.id == id) {
        return goal;
      }
    }
    return null;
  }

  /// Pinned items first, otherwise newest first (insertion order).
  List<WallItem> get sortedWallItems {
    final List<WallItem> items = List<WallItem>.of(_state.wallItems);
    items.sort((WallItem a, WallItem b) {
      if (a.isPinned == b.isPinned) {
        return 0;
      }
      return a.isPinned ? -1 : 1;
    });
    return items;
  }

  WallItem? get featuredWallItem {
    if (_state.wallItems.isEmpty) {
      return null;
    }
    return sortedWallItems.first;
  }

  int get completedTasksToday =>
      _state.tasks.where((DisciplineTask task) => task.completed).length;

  int get currentStreak =>
      StreakCalculator.current(_state.activity, now: clock());

  WeeklyReview? get currentReview {
    final String key = DateKeys.weekKey(clock());
    for (final WeeklyReview review in _state.reviews) {
      if (review.weekKey == key) {
        return review;
      }
    }
    return null;
  }

  List<WeeklyReview> get pastReviews {
    final String key = DateKeys.weekKey(clock());
    final List<WeeklyReview> past = _state.reviews
        .where((WeeklyReview review) => review.weekKey != key)
        .toList();
    past.sort(
      (WeeklyReview a, WeeklyReview b) => b.weekKey.compareTo(a.weekKey),
    );
    return past;
  }

  WeekSummary get weekSummary {
    final DateTime start = DateKeys.weekStart(clock());
    final DateTime end = start.add(const Duration(days: 7));
    bool inWeek(DateTime? date) =>
        date != null && !date.isBefore(start) && date.isBefore(end);

    int actions = 0;
    int activeDays = 0;
    for (int i = 0; i < 7; i++) {
      final int count =
          _state.activity[DateKeys.of(start.add(Duration(days: i)))] ?? 0;
      actions += count;
      if (count > 0) {
        activeDays++;
      }
    }
    int milestones = 0;
    for (final Goal goal in _state.goals) {
      milestones += goal.milestones
          .where((Milestone m) => m.isCompleted && inWeek(m.completedAt))
          .length;
    }
    return WeekSummary(
      start: start,
      actions: actions,
      activeDays: activeDays,
      milestonesCompleted: milestones,
      goalsAchieved: _state.goals
          .where((Goal goal) => inWeek(goal.achievedAt))
          .length,
    );
  }

  /// Longest streak while the goal was active, for the achievement screen.
  int consistencyFor(Goal goal) => StreakCalculator.longest(
    _state.activity,
    from: goal.createdAt,
    to: goal.achievedAt ?? clock(),
  );

  // ── Lifecycle ────────────────────────────────────────────────────

  Future<void> load() async {
    _state = await _repository.load();
    _isLoaded = true;
    refreshDay();
    notifyListeners();
  }

  /// Resets today's practice checkmarks once the calendar day changes.
  /// Called on load and whenever the app returns to the foreground.
  void refreshDay() {
    final String today = DateKeys.today(clock());
    if (_state.tasksDay == today) {
      return;
    }
    _commit(
      _copy(
        tasks: _state.tasks
            .map((DisciplineTask task) => task.copyWith(completed: false))
            .toList(),
        tasksDay: today,
      ),
    );
  }

  Future<void> completeOnboarding({
    required String name,
    required String dream,
    required String anchor,
    required TimeOfDay reminderTime,
    required bool remindersEnabled,
    String? anchorImage,
  }) async {
    final Goal firstGoal = Goal(
      id: _uuid.v4(),
      title: dream.trim(),
      trackingType: _looksFinancial(dream)
          ? GoalTrackingType.money
          : GoalTrackingType.progress,
      createdAt: clock(),
      why: anchor.trim().isEmpty ? null : anchor.trim(),
      image: anchorImage,
    );
    await _commit(
      _copy(
        onboardingComplete: true,
        notificationsEnabled: remindersEnabled,
        user: UserProfile(
          name: name.trim(),
          bigDream: dream.trim(),
          anchor: anchor.trim(),
          anchorImage: anchorImage,
          reminderHour: reminderTime.hour,
          reminderMinute: reminderTime.minute,
        ),
        goals: <Goal>[firstGoal, ..._state.goals],
        tasksDay: DateKeys.today(clock()),
      ),
    );
    await _syncReminder();
  }

  /// Completes once all pending changes are written to disk.
  Future<void> flush() => _repository.flush();

  Future<void> resetApp() async {
    await NotificationService.cancelDaily();
    final List<String?> images = <String?>[
      _state.user.avatar,
      _state.user.anchorImage,
      ..._state.goals.map((Goal goal) => goal.image),
      ..._state.wallItems.map((WallItem item) => item.image),
    ];
    await Future.wait(images.toSet().map(ImageStore.delete));
    await _repository.clear();
    _state = const AppState();
    notifyListeners();
  }

  // ── Profile & reminders ──────────────────────────────────────────

  Future<void> updateProfile({
    required String name,
    required String dream,
    required String anchor,
  }) async {
    final bool copyChanged =
        name.trim() != user.name || anchor.trim() != (user.anchor ?? '');
    _commit(
      _copy(
        user: user.copyWith(
          name: name.trim(),
          bigDream: dream.trim(),
          anchor: anchor.trim(),
        ),
      ),
    );
    if (copyChanged) {
      await _syncReminder();
    }
  }

  void setAvatar(String? ref) {
    final String? previous = user.avatar;
    _commit(_copy(user: user.copyWith(avatar: () => ref)));
    if (previous != ref) {
      ImageStore.delete(previous);
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _commit(_copy(user: user.copyWith(reminderTime: time)));
    await _syncReminder();
  }

  /// Returns false if reminders were requested but couldn't be scheduled
  /// (e.g. permission denied), so the UI can explain why.
  Future<bool> setNotificationsEnabled(bool enabled) async {
    _commit(_copy(notificationsEnabled: enabled));
    return _syncReminder();
  }

  Future<bool> _syncReminder() async {
    if (!_state.notificationsEnabled) {
      await NotificationService.cancelDaily();
      return true;
    }
    return NotificationService.scheduleDaily(
      hour: user.reminderHour,
      minute: user.reminderMinute,
      copy: ReminderCopy(name: user.name, anchor: user.anchor ?? ''),
    );
  }

  // ── Daily practices ──────────────────────────────────────────────

  void toggleTask(String id) {
    refreshDay();
    bool? nowCompleted;
    final List<DisciplineTask> tasks = _state.tasks.map((DisciplineTask task) {
      if (task.id != id) {
        return task;
      }
      nowCompleted = !task.completed;
      return task.copyWith(completed: nowCompleted);
    }).toList();
    if (nowCompleted == null) {
      return;
    }
    _commit(
      _copy(tasks: tasks, activity: _activityDelta(nowCompleted! ? 1 : -1)),
    );
  }

  void saveTask({String? taskId, required String title}) {
    final String clean = title.trim();
    if (clean.isEmpty) {
      return;
    }
    final List<DisciplineTask> tasks = taskId == null
        ? <DisciplineTask>[
            ..._state.tasks,
            DisciplineTask(id: _uuid.v4(), title: clean),
          ]
        : _state.tasks
              .map(
                (DisciplineTask task) =>
                    task.id == taskId ? task.copyWith(title: clean) : task,
              )
              .toList();
    _commit(_copy(tasks: tasks));
  }

  void deleteTask(String id) {
    _commit(
      _copy(
        tasks: _state.tasks
            .where((DisciplineTask task) => task.id != id)
            .toList(),
      ),
    );
  }

  // ── Goals ────────────────────────────────────────────────────────

  Goal createGoal({
    required String title,
    required GoalTrackingType trackingType,
    double targetAmount = 0,
    String why = '',
    String? image,
  }) {
    final Goal goal = Goal(
      id: _uuid.v4(),
      title: title.trim(),
      trackingType: trackingType,
      createdAt: clock(),
      targetAmount: trackingType == GoalTrackingType.money ? targetAmount : 0,
      why: why.trim().isEmpty ? null : why.trim(),
      image: image,
    );
    _commit(_copy(goals: <Goal>[..._state.goals, goal]));
    return goal;
  }

  /// Returns true if this edit completed the goal (e.g. target lowered
  /// below the amount already saved).
  bool updateGoal(
    String id, {
    required String title,
    required GoalTrackingType trackingType,
    required double targetAmount,
    required String why,
  }) => _updateGoal(
    id,
    (Goal goal) => goal.copyWith(
      title: title.trim(),
      trackingType: trackingType,
      targetAmount: trackingType == GoalTrackingType.money ? targetAmount : 0,
      why: why.trim(),
    ),
  );

  void deleteGoal(String id) {
    final Goal? goal = goalById(id);
    if (goal == null) {
      return;
    }
    _commit(_copy(goals: _state.goals.where((Goal g) => g.id != id).toList()));
    if (goal.image != user.anchorImage) {
      ImageStore.delete(goal.image);
    }
  }

  /// Moves a goal to the front so it becomes the Home focus.
  void setFocusGoal(String id) {
    final Goal? goal = goalById(id);
    if (goal == null) {
      return;
    }
    _commit(
      _copy(goals: <Goal>[goal, ..._state.goals.where((Goal g) => g.id != id)]),
    );
  }

  void setGoalCompleted(String id, {required bool completed}) {
    final List<Goal> goals = _state.goals
        .map(
          (Goal goal) => goal.id == id
              ? goal.copyWith(achievedAt: () => completed ? clock() : null)
              : goal,
        )
        .toList();
    _commit(
      _copy(goals: goals, activity: completed ? _activityDelta(1) : null),
    );
  }

  /// Adds [amount] to a financial goal. Returns true if this completed it.
  bool logEarnings(String id, double amount) {
    if (amount <= 0) {
      return false;
    }
    return _updateGoal(
      id,
      (Goal goal) => goal.copyWith(currentAmount: goal.currentAmount + amount),
      activity: 1,
    );
  }

  /// Starts a follow-up goal of the same kind with a doubled target.
  Goal levelUpGoal(String id) {
    final Goal source = goalById(id)!;
    final Goal next = createGoal(
      title: '${source.title} — Next Level',
      trackingType: source.trackingType,
      targetAmount: source.targetAmount * 2,
      why: source.why ?? '',
      image: source.image,
    );
    setFocusGoal(next.id);
    return next;
  }

  /// Adds or updates a milestone. Returns true if this completed the goal.
  bool saveMilestone(
    String goalId, {
    String? milestoneId,
    required String title,
    required MilestoneStatus status,
    String? note,
    String? valueLabel,
  }) {
    final Goal? goal = goalById(goalId);
    if (goal == null || title.trim().isEmpty) {
      return false;
    }
    Milestone? previous;
    for (final Milestone m in goal.milestones) {
      if (m.id == milestoneId) {
        previous = m;
      }
    }
    final bool newlyCompleted =
        status == MilestoneStatus.completed && previous?.isCompleted != true;
    String? clean(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    final Milestone value = Milestone(
      id: previous?.id ?? _uuid.v4(),
      title: title.trim(),
      status: status,
      note: clean(note),
      valueLabel: clean(valueLabel),
      completedAt: status == MilestoneStatus.completed
          ? (previous?.completedAt ?? clock())
          : null,
    );
    return _updateGoal(
      goalId,
      activity: newlyCompleted ? 1 : 0,
      (Goal g) => g.copyWith(
        milestones: previous == null
            ? <Milestone>[...g.milestones, value]
            : g.milestones
                  .map((Milestone m) => m.id == milestoneId ? value : m)
                  .toList(),
      ),
    );
  }

  void deleteMilestone(String goalId, String milestoneId) {
    _updateGoal(
      goalId,
      (Goal goal) => goal.copyWith(
        milestones: goal.milestones
            .where((Milestone m) => m.id != milestoneId)
            .toList(),
      ),
    );
  }

  /// Applies [change] and auto-completes the goal when its milestones or
  /// target are reached. Returns true if the goal became achieved.
  bool _updateGoal(String id, Goal Function(Goal) change, {int activity = 0}) {
    bool achieved = false;
    final List<Goal> goals = _state.goals.map((Goal goal) {
      if (goal.id != id) {
        return goal;
      }
      Goal updated = change(goal);
      if (!updated.isAchieved &&
          (updated.allMilestonesComplete || updated.targetReached)) {
        updated = updated.copyWith(achievedAt: clock);
        achieved = true;
      }
      return updated;
    }).toList();
    _commit(
      _copy(
        goals: goals,
        activity: activity != 0 ? _activityDelta(activity) : null,
      ),
    );
    return achieved;
  }

  // ── Wall ─────────────────────────────────────────────────────────

  void addWallItem({
    required String title,
    required String category,
    required String image,
    String note = '',
    String nextStep = '',
  }) {
    final WallItem item = WallItem(
      id: _uuid.v4(),
      title: title.trim(),
      category: category.trim(),
      image: image.trim(),
      note: note.trim(),
      nextStep: nextStep.trim(),
    );
    _commit(_copy(wallItems: <WallItem>[item, ..._state.wallItems]));
  }

  void updateWallItem(
    String id, {
    required String title,
    required String category,
    required String image,
    required String note,
    required String nextStep,
  }) {
    String? replacedImage;
    final List<WallItem> items = _state.wallItems.map((WallItem item) {
      if (item.id != id) {
        return item;
      }
      if (item.image != image) {
        replacedImage = item.image;
      }
      return item.copyWith(
        title: title.trim(),
        category: category.trim(),
        image: image.trim(),
        note: note.trim(),
        nextStep: nextStep.trim(),
      );
    }).toList();
    _commit(_copy(wallItems: items));
    ImageStore.delete(replacedImage);
  }

  /// Only one item can be pinned; pinning another moves the pin.
  void toggleWallPinned(String id) {
    final bool pin = !_state.wallItems.any(
      (WallItem item) => item.id == id && item.isPinned,
    );
    _commit(
      _copy(
        wallItems: _state.wallItems
            .map(
              (WallItem item) => item.copyWith(isPinned: pin && item.id == id),
            )
            .toList(),
      ),
    );
  }

  void removeWallItem(String id) {
    String? image;
    final List<WallItem> items = _state.wallItems.where((WallItem item) {
      if (item.id == id) {
        image = item.image;
        return false;
      }
      return true;
    }).toList();
    _commit(_copy(wallItems: items));
    ImageStore.delete(image);
  }

  // ── Weekly review ────────────────────────────────────────────────

  Future<void> saveReview({required int stars, required String reflection}) {
    final String key = DateKeys.weekKey(clock());
    final WeeklyReview review = WeeklyReview(
      weekKey: key,
      stars: stars.clamp(1, 5),
      reflection: reflection.trim(),
      savedAt: clock(),
    );
    return _commit(
      _copy(
        reviews: <WeeklyReview>[
          review,
          ..._state.reviews.where((WeeklyReview r) => r.weekKey != key),
        ],
      ),
    );
  }

  // ── Internals ────────────────────────────────────────────────────

  Future<void> _commit(AppState next) {
    _state = next;
    notifyListeners();
    return _repository.save(next);
  }

  /// Adjusts today's activity count, pruning entries past the retention
  /// window so the stored map stays small.
  Map<String, int> _activityDelta(int delta) {
    final DateTime now = clock();
    final String today = DateKeys.today(now);
    final String cutoff = DateKeys.of(
      now.subtract(const Duration(days: AppConstants.activityRetentionDays)),
    );
    final Map<String, int> activity = <String, int>{
      for (final MapEntry<String, int> entry in _state.activity.entries)
        if (entry.key.compareTo(cutoff) >= 0) entry.key: entry.value,
    };
    final int next = (activity[today] ?? 0) + delta;
    if (next > 0) {
      activity[today] = next;
    } else {
      activity.remove(today);
    }
    return activity;
  }

  AppState _copy({
    bool? onboardingComplete,
    bool? notificationsEnabled,
    UserProfile? user,
    List<Goal>? goals,
    List<DisciplineTask>? tasks,
    String? tasksDay,
    List<WallItem>? wallItems,
    List<WeeklyReview>? reviews,
    Map<String, int>? activity,
  }) => AppState(
    onboardingComplete: onboardingComplete ?? _state.onboardingComplete,
    notificationsEnabled: notificationsEnabled ?? _state.notificationsEnabled,
    user: user ?? _state.user,
    goals: goals ?? _state.goals,
    tasks: tasks ?? _state.tasks,
    tasksDay: tasksDay ?? _state.tasksDay,
    wallItems: wallItems ?? _state.wallItems,
    reviews: reviews ?? _state.reviews,
    activity: activity ?? _state.activity,
  );

  static bool _looksFinancial(String dream) {
    const List<String> terms = <String>[
      'income', 'money', 'save', 'saving', 'earn', 'salary', 'debt', //
      'budget', 'client', 'freelance', 'business', '₱', r'$', 'peso',
    ];
    final String value = dream.toLowerCase();
    return terms.any(value.contains);
  }
}
