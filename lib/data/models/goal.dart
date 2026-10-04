import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import 'milestone.dart';

enum GoalTrackingType { money, progress }

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.trackingType,
    required this.createdAt,
    this.currentAmount = 0,
    this.targetAmount = 0,
    this.currencySymbol = AppConstants.defaultCurrency,
    this.why,
    this.image,
    this.milestones = const <Milestone>[],
    this.achievedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    final DateTime createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    DateTime? achievedAt = DateTime.tryParse(
      json['achievedAt'] as String? ?? '',
    );
    // Earlier builds only stored a flag.
    if (achievedAt == null && json['isAchieved'] == true) {
      achievedAt = createdAt;
    }
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      trackingType: GoalTrackingType.values.firstWhere(
        (GoalTrackingType value) => value.name == json['trackingType'],
        orElse: () => GoalTrackingType.money,
      ),
      createdAt: createdAt,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currencySymbol:
          json['currencySymbol'] as String? ?? AppConstants.defaultCurrency,
      why: json['why'] as String?,
      image: (json['image'] ?? json['whyImageUrl']) as String?,
      milestones: (json['milestones'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic value) =>
                Milestone.fromJson(value as Map<String, dynamic>),
          )
          .toList(),
      achievedAt: achievedAt,
    );
  }

  final String id;
  final String title;
  final GoalTrackingType trackingType;
  final DateTime createdAt;
  final double currentAmount;
  final double targetAmount;
  final String currencySymbol;
  final String? why;
  final String? image;
  final List<Milestone> milestones;
  final DateTime? achievedAt;

  bool get isAchieved => achievedAt != null;

  bool get isFinancial => trackingType == GoalTrackingType.money;

  int get completedMilestones => milestones
      .where((Milestone item) => item.status == MilestoneStatus.completed)
      .length;

  bool get allMilestonesComplete =>
      milestones.isNotEmpty && completedMilestones == milestones.length;

  bool get targetReached =>
      isFinancial && targetAmount > 0 && currentAmount >= targetAmount;

  double get progress {
    if (isAchieved) {
      return 1;
    }
    if (isFinancial) {
      return targetAmount > 0
          ? (currentAmount / targetAmount).clamp(0.0, 1.0)
          : 0;
    }
    return milestones.isEmpty ? 0 : completedMilestones / milestones.length;
  }

  int get progressPercent => (progress * 100).round();

  /// Calendar days from creation to completion (or to today while active),
  /// counting the first day.
  int get daysActive =>
      DateKeys.daysBetween(createdAt, achievedAt ?? DateTime.now()) + 1;

  Goal copyWith({
    String? title,
    GoalTrackingType? trackingType,
    double? currentAmount,
    double? targetAmount,
    String? why,
    String? Function()? image,
    List<Milestone>? milestones,
    DateTime? Function()? achievedAt,
  }) => Goal(
    id: id,
    title: title ?? this.title,
    trackingType: trackingType ?? this.trackingType,
    createdAt: createdAt,
    currentAmount: currentAmount ?? this.currentAmount,
    targetAmount: targetAmount ?? this.targetAmount,
    currencySymbol: currencySymbol,
    why: why ?? this.why,
    image: image != null ? image() : this.image,
    milestones: milestones ?? this.milestones,
    achievedAt: achievedAt != null ? achievedAt() : this.achievedAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'trackingType': trackingType.name,
    'createdAt': createdAt.toIso8601String(),
    'currentAmount': currentAmount,
    'targetAmount': targetAmount,
    'currencySymbol': currencySymbol,
    'why': why,
    'image': image,
    'milestones': milestones.map((Milestone m) => m.toJson()).toList(),
    'achievedAt': achievedAt?.toIso8601String(),
  };
}
