import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

class AppViewModel extends ChangeNotifier {
  static const String _stateKey = 'thryve.app_state.v1';
  static const Uuid _uuid = Uuid();

  bool isLoaded = false;
  bool onboardingComplete = false;
  bool notificationsEnabled = true;
  UserProfile user = DemoData.user;
  List<Goal> goals = List<Goal>.from(DemoData.goals);
  List<DisciplineTask> tasks = List<DisciplineTask>.from(
    DemoData.disciplineTasks,
  );
  List<WallItem> wallItems = List<WallItem>.from(DemoData.wallItems);
  int vibeStars = 0;
  String reflection = '';
  DateTime? reviewSavedAt;
  String _tasksDay = '';

  InspirationCard get inspiration {
    if (wallItems.isEmpty) return DemoData.inspiration;
    final WallItem item = wallItems.firstWhere(
      (WallItem value) => value.isPinned,
      orElse: () => wallItems.first,
    );
    return InspirationCard(
      title: item.title,
      body: item.note.trim().isEmpty ? item.category : item.note,
      imageUrl: item.imageUrl,
      ctaLabel: 'Open on My Wall',
    );
  }

  Goal get activeGoal =>
      goals.firstWhere((Goal goal) => goal.isActive, orElse: () => goals.first);

  Future<void> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? encoded = preferences.getString(_stateKey);
    if (encoded != null) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(encoded) as Map<String, dynamic>;
        onboardingComplete = json['onboardingComplete'] as bool? ?? false;
        notificationsEnabled = json['notificationsEnabled'] as bool? ?? true;
        user = UserProfile.fromJson(json['user'] as Map<String, dynamic>);
        goals = (json['goals'] as List<dynamic>)
            .map(
              (dynamic value) => Goal.fromJson(value as Map<String, dynamic>),
            )
            .toList();
        tasks = (json['tasks'] as List<dynamic>)
            .map(
              (dynamic value) =>
                  DisciplineTask.fromJson(value as Map<String, dynamic>),
            )
            .toList();
        wallItems = (json['wallItems'] as List<dynamic>)
            .map(
              (dynamic value) =>
                  WallItem.fromJson(value as Map<String, dynamic>),
            )
            .toList();
        vibeStars = json['vibeStars'] as int? ?? 0;
        reflection = json['reflection'] as String? ?? '';
        reviewSavedAt = DateTime.tryParse(
          json['reviewSavedAt'] as String? ?? '',
        );
        _tasksDay = json['tasksDay'] as String? ?? '';
      } on Object {
        // Keep safe demo defaults when locally stored data is malformed.
      }
    }
    final String today = _todayKey();
    if (_tasksDay != today) {
      tasks = tasks
          .map(
            (DisciplineTask task) =>
                DisciplineTask(id: task.id, title: task.title),
          )
          .toList();
      _tasksDay = today;
      await _save();
    }
    // Keep the primary goal aligned with the purpose captured during onboarding
    // for users upgrading from an earlier locally stored version.
    _syncPurposeToPrimaryGoal(
      dream: user.bigDream ?? '',
      anchor: user.anchor ?? '',
    );
    isLoaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required String dream,
    required String anchor,
    String? anchorImageUrl,
    required String focusWindow,
    GoalTrackingType trackingType = GoalTrackingType.progress,
  }) async {
    user = user.copyWith(
      name: name.trim(),
      bigDream: dream.trim(),
      anchor: anchor.trim(),
      anchorImageUrl: anchorImageUrl,
      focusWindow: focusWindow,
    );
    _syncPurposeToPrimaryGoal(dream: dream, anchor: anchor);
    if (goals.isNotEmpty) {
      goals[0] = goals[0].copyWith(trackingType: trackingType);
    }
    onboardingComplete = true;
    notifyListeners();
    await _save();
  }

  Future<void> updateProfile({
    required String name,
    required String dream,
    required String anchor,
    String? focusWindow,
    String? avatarUrl,
  }) async {
    user = user.copyWith(
      name: name.trim(),
      bigDream: dream.trim(),
      anchor: anchor.trim(),
      focusWindow: focusWindow,
      avatarUrl: avatarUrl,
    );
    _syncPurposeToPrimaryGoal(dream: dream, anchor: anchor);
    notifyListeners();
    await _save();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled = enabled;
    notifyListeners();
    await _save();
  }

  void _syncPurposeToPrimaryGoal({
    required String dream,
    required String anchor,
  }) {
    if (goals.isEmpty || dream.trim().isEmpty) return;
    goals[0] = goals[0].copyWith(
      title: dream.trim(),
      why: anchor.trim().isEmpty ? goals[0].why : anchor.trim(),
      trackingType: _looksFinancial(dream)
          ? GoalTrackingType.money
          : GoalTrackingType.progress,
    );
  }

  bool _looksFinancial(String value) {
    final String dream = value.toLowerCase();
    const List<String> financialTerms = <String>[
      'income',
      'money',
      'save',
      'saving',
      'earn',
      'salary',
      'debt',
      'budget',
      'client',
      'freelance',
      'business',
    ];
    return financialTerms.any(dream.contains);
  }

  Future<void> resetApp() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_stateKey);
    onboardingComplete = false;
    user = DemoData.user;
    goals = List<Goal>.from(DemoData.goals);
    tasks = List<DisciplineTask>.from(DemoData.disciplineTasks);
    _tasksDay = _todayKey();
    wallItems = List<WallItem>.from(DemoData.wallItems);
    vibeStars = 0;
    reflection = '';
    reviewSavedAt = null;
    notifyListeners();
  }

  void toggleTask(String id) {
    final int index = tasks.indexWhere((DisciplineTask task) => task.id == id);
    if (index < 0) return;
    final DisciplineTask task = tasks[index];
    tasks[index] = DisciplineTask(
      id: task.id,
      title: task.title,
      completed: !task.completed,
    );
    notifyListeners();
    _save();
  }

  void saveTask({String? taskId, required String title}) {
    final String cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;
    final DisciplineTask value = DisciplineTask(
      id: taskId ?? _uuid.v4(),
      title: cleanTitle,
      completed: taskId == null
          ? false
          : tasks
                .firstWhere(
                  (DisciplineTask task) => task.id == taskId,
                  orElse: () => const DisciplineTask(id: '', title: ''),
                )
                .completed,
    );
    if (taskId == null) {
      tasks = <DisciplineTask>[...tasks, value];
    } else {
      tasks = tasks
          .map((DisciplineTask task) => task.id == taskId ? value : task)
          .toList();
    }
    notifyListeners();
    _save();
  }

  void deleteTask(String id) {
    tasks = tasks.where((DisciplineTask task) => task.id != id).toList();
    notifyListeners();
    _save();
  }

  void addMilestone(String goalId, String title) {
    _updateGoal(
      goalId,
      (Goal goal) => goal.copyWith(
        milestones: <Milestone>[
          ...goal.milestones,
          Milestone(
            id: _uuid.v4(),
            title: title.trim(),
            status: MilestoneStatus.pending,
          ),
        ],
      ),
    );
  }

  void saveMilestone(
    String goalId, {
    String? milestoneId,
    required String title,
    required MilestoneStatus status,
    String? subtitle,
    String? amountLabel,
  }) {
    _updateGoal(goalId, (Goal goal) {
      final Milestone value = Milestone(
        id: milestoneId ?? _uuid.v4(),
        title: title.trim(),
        status: status,
        subtitle: subtitle?.trim().isEmpty == true ? null : subtitle?.trim(),
        amountLabel: amountLabel?.trim().isEmpty == true
            ? null
            : amountLabel?.trim(),
      );
      final List<Milestone> values = milestoneId == null
          ? <Milestone>[...goal.milestones, value]
          : goal.milestones
                .map((Milestone item) => item.id == milestoneId ? value : item)
                .toList();
      return goal.copyWith(milestones: values);
    });
  }

  void deleteMilestone(String goalId, String milestoneId) {
    _updateGoal(
      goalId,
      (Goal goal) => goal.copyWith(
        milestones: goal.milestones
            .where((Milestone item) => item.id != milestoneId)
            .toList(),
      ),
    );
  }

  void setGoalCompleted(String goalId, bool completed) {
    _updateGoal(
      goalId,
      (Goal goal) => goal.copyWith(isAchieved: completed, isActive: !completed),
    );
  }

  void cycleMilestone(String goalId, String milestoneId) {
    _updateGoal(goalId, (Goal goal) {
      final List<Milestone> milestones = goal.milestones.map((
        Milestone milestone,
      ) {
        if (milestone.id != milestoneId) return milestone;
        final MilestoneStatus status = switch (milestone.status) {
          MilestoneStatus.pending => MilestoneStatus.inProgress,
          MilestoneStatus.inProgress => MilestoneStatus.completed,
          MilestoneStatus.completed => MilestoneStatus.pending,
        };
        return Milestone(
          id: milestone.id,
          title: milestone.title,
          status: status,
          subtitle: status == MilestoneStatus.completed
              ? 'Completed today'
              : milestone.subtitle,
          amountLabel: milestone.amountLabel,
        );
      }).toList();
      return goal.copyWith(milestones: milestones);
    });
  }

  void updateGoal(
    String goalId, {
    required String title,
    required double targetAmount,
    required String why,
    GoalTrackingType? trackingType,
  }) {
    _updateGoal(
      goalId,
      (Goal goal) => goal.copyWith(
        title: title.trim(),
        targetAmount: targetAmount,
        why: why.trim(),
        trackingType: trackingType,
      ),
    );
  }

  Goal logEarnings(String goalId, double amount) {
    late Goal result;
    _updateGoal(goalId, (Goal goal) {
      final double total = (goal.currentAmount + amount).clamp(
        0,
        goal.targetAmount,
      );
      result = goal.copyWith(
        currentAmount: total,
        isAchieved: total >= goal.targetAmount,
        isActive: total < goal.targetAmount,
      );
      return result;
    });
    return result;
  }

  void addGoal({
    required String title,
    required double targetAmount,
    required String why,
    GoalTrackingType trackingType = GoalTrackingType.money,
  }) {
    goals = <Goal>[
      ...goals,
      Goal(
        id: _uuid.v4(),
        title: title.trim(),
        category: 'Active Goal',
        currentAmount: 0,
        targetAmount: targetAmount,
        why: why.trim(),
        trackingType: trackingType,
      ),
    ];
    notifyListeners();
    _save();
  }

  void addWallItem({
    required String title,
    required String category,
    required String imageUrl,
    String note = '',
    String nextStep = '',
    bool isPinned = false,
  }) {
    wallItems = <WallItem>[
      WallItem(
        id: _uuid.v4(),
        title: title.trim(),
        category: category.trim(),
        imageUrl: imageUrl.trim(),
        note: note.trim(),
        nextStep: nextStep.trim(),
        isPinned: isPinned,
      ),
      ...wallItems,
    ];
    notifyListeners();
    _save();
  }

  void updateWallItem(
    String id, {
    required String title,
    required String category,
    required String imageUrl,
    required String note,
    String nextStep = '',
  }) {
    final int index = wallItems.indexWhere((WallItem item) => item.id == id);
    if (index < 0) return;
    wallItems[index] = wallItems[index].copyWith(
      title: title.trim(),
      category: category.trim(),
      imageUrl: imageUrl.trim(),
      note: note.trim(),
      nextStep: nextStep.trim(),
    );
    notifyListeners();
    _save();
  }

  void toggleWallPinned(String id) {
    final int index = wallItems.indexWhere((WallItem item) => item.id == id);
    if (index < 0) return;
    final bool shouldPin = !wallItems[index].isPinned;
    wallItems = wallItems
        .map(
          (WallItem item) => item.copyWith(
            isPinned: shouldPin
                ? item.id == id
                : (item.id == id ? false : item.isPinned),
          ),
        )
        .toList();
    notifyListeners();
    _save();
  }

  void featureWallItem(String id) {
    wallItems = wallItems
        .map((WallItem item) => item.copyWith(isPinned: item.id == id))
        .toList();
    notifyListeners();
    _save();
  }

  void removeWallItem(String id) {
    wallItems = wallItems.where((WallItem item) => item.id != id).toList();
    notifyListeners();
    _save();
  }

  Future<void> saveReview({required int stars, required String text}) async {
    vibeStars = stars;
    reflection = text.trim();
    reviewSavedAt = DateTime.now();
    notifyListeners();
    await _save();
  }

  void _updateGoal(String id, Goal Function(Goal) update) {
    final int index = goals.indexWhere((Goal goal) => goal.id == id);
    if (index < 0) return;
    final Goal changed = update(goals[index]);
    final bool milestonesComplete =
        changed.milestones.isNotEmpty &&
        changed.milestones.every(
          (Milestone milestone) =>
              milestone.status == MilestoneStatus.completed,
        );
    final bool targetComplete =
        changed.isFinancial &&
        changed.targetAmount > 0 &&
        changed.currentAmount >= changed.targetAmount;
    goals[index] = changed.copyWith(
      isAchieved: milestonesComplete || targetComplete,
      isActive: !(milestonesComplete || targetComplete),
    );
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _stateKey,
      jsonEncode(<String, dynamic>{
        'onboardingComplete': onboardingComplete,
        'notificationsEnabled': notificationsEnabled,
        'user': user.toJson(),
        'goals': goals.map((Goal goal) => goal.toJson()).toList(),
        'tasks': tasks.map((DisciplineTask task) => task.toJson()).toList(),
        'tasksDay': _tasksDay,
        'wallItems': wallItems.map((WallItem item) => item.toJson()).toList(),
        'vibeStars': vibeStars,
        'reflection': reflection,
        'reviewSavedAt': reviewSavedAt?.toIso8601String(),
      }),
    );
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
