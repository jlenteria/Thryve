class UserProfile {
  final String name;
  final String? avatarUrl;
  final int streakDays;
  final String? bigDream;
  final String? anchor;
  final String? anchorImageUrl;
  final String? focusWindow; // e.g. "08:00 AM"

  const UserProfile({
    required this.name,
    this.avatarUrl,
    this.streakDays = 0,
    this.bigDream,
    this.anchor,
    this.anchorImageUrl,
    this.focusWindow,
  });

  UserProfile copyWith({
    String? name,
    String? avatarUrl,
    int? streakDays,
    String? bigDream,
    String? anchor,
    String? anchorImageUrl,
    String? focusWindow,
  }) => UserProfile(
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    streakDays: streakDays ?? this.streakDays,
    bigDream: bigDream ?? this.bigDream,
    anchor: anchor ?? this.anchor,
    anchorImageUrl: anchorImageUrl ?? this.anchorImageUrl,
    focusWindow: focusWindow ?? this.focusWindow,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'avatarUrl': avatarUrl,
    'streakDays': streakDays,
    'bigDream': bigDream,
    'anchor': anchor,
    'anchorImageUrl': anchorImageUrl,
    'focusWindow': focusWindow,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Friend',
    avatarUrl: json['avatarUrl'] as String?,
    streakDays: json['streakDays'] as int? ?? 0,
    bigDream: json['bigDream'] as String?,
    anchor: json['anchor'] as String?,
    anchorImageUrl: json['anchorImageUrl'] as String?,
    focusWindow: json['focusWindow'] as String?,
  );
}

class Goal {
  final String id;
  final String title;
  final String category;
  final double currentAmount;
  final double targetAmount;
  final String currencySymbol;
  final String? quote;
  final String? why;
  final String? whyImageUrl;
  final List<Milestone> milestones;
  final bool isActive;
  final bool isAchieved;
  final int? daysTaken;
  final int? consistencyStreak;
  final GoalTrackingType trackingType;

  const Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.currentAmount,
    required this.targetAmount,
    this.currencySymbol = '₱',
    this.quote,
    this.why,
    this.whyImageUrl,
    this.milestones = const [],
    this.isActive = true,
    this.isAchieved = false,
    this.daysTaken,
    this.consistencyStreak,
    this.trackingType = GoalTrackingType.money,
  });

  double get progress {
    if (isAchieved) return 1.0;
    if (!isFinancial && milestones.isNotEmpty) {
      return milestones
              .where(
                (Milestone item) => item.status == MilestoneStatus.completed,
              )
              .length /
          milestones.length;
    }
    if (targetAmount > 0) {
      return (currentAmount / targetAmount).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  int get progressPercent => (progress * 100).round();

  bool get isFinancial => trackingType == GoalTrackingType.money;

  Goal copyWith({
    String? title,
    String? category,
    double? currentAmount,
    double? targetAmount,
    String? why,
    List<Milestone>? milestones,
    bool? isActive,
    bool? isAchieved,
    int? daysTaken,
    int? consistencyStreak,
    GoalTrackingType? trackingType,
  }) => Goal(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    currentAmount: currentAmount ?? this.currentAmount,
    targetAmount: targetAmount ?? this.targetAmount,
    currencySymbol: currencySymbol,
    quote: quote,
    why: why ?? this.why,
    whyImageUrl: whyImageUrl,
    milestones: milestones ?? this.milestones,
    isActive: isActive ?? this.isActive,
    isAchieved: isAchieved ?? this.isAchieved,
    daysTaken: daysTaken ?? this.daysTaken,
    consistencyStreak: consistencyStreak ?? this.consistencyStreak,
    trackingType: trackingType ?? this.trackingType,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'category': category,
    'currentAmount': currentAmount,
    'targetAmount': targetAmount,
    'currencySymbol': currencySymbol,
    'quote': quote,
    'why': why,
    'whyImageUrl': whyImageUrl,
    'milestones': milestones.map((Milestone m) => m.toJson()).toList(),
    'isActive': isActive,
    'isAchieved': isAchieved,
    'daysTaken': daysTaken,
    'consistencyStreak': consistencyStreak,
    'trackingType': trackingType.name,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Active Goal',
    currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
    targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
    currencySymbol: json['currencySymbol'] as String? ?? '₱',
    quote: json['quote'] as String?,
    why: json['why'] as String?,
    whyImageUrl: json['whyImageUrl'] as String?,
    milestones: (json['milestones'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic value) => Milestone.fromJson(value as Map<String, dynamic>),
        )
        .toList(),
    isActive: json['isActive'] as bool? ?? true,
    isAchieved: json['isAchieved'] as bool? ?? false,
    daysTaken: json['daysTaken'] as int?,
    consistencyStreak: json['consistencyStreak'] as int?,
    trackingType: GoalTrackingType.values.firstWhere(
      (GoalTrackingType value) => value.name == json['trackingType'],
      orElse: () => GoalTrackingType.money,
    ),
  );
}

enum GoalTrackingType { money, progress }

class Milestone {
  final String id;
  final String title;
  final MilestoneStatus status;
  final String? subtitle;
  final String? amountLabel;

  const Milestone({
    required this.id,
    required this.title,
    required this.status,
    this.subtitle,
    this.amountLabel,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'status': status.name,
    'subtitle': subtitle,
    'amountLabel': amountLabel,
  };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json['id'] as String,
    title: json['title'] as String,
    status: MilestoneStatus.values.firstWhere(
      (MilestoneStatus value) => value.name == json['status'],
      orElse: () => MilestoneStatus.pending,
    ),
    subtitle: json['subtitle'] as String?,
    amountLabel: json['amountLabel'] as String?,
  );
}

enum MilestoneStatus { completed, inProgress, pending }

class DisciplineTask {
  final String id;
  final String title;
  final bool completed;

  const DisciplineTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'completed': completed,
  };

  factory DisciplineTask.fromJson(Map<String, dynamic> json) => DisciplineTask(
    id: json['id'] as String,
    title: json['title'] as String,
    completed: json['completed'] as bool? ?? false,
  );
}

class WallItem {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String note;
  final String nextStep;
  final bool isPinned;

  const WallItem({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    this.note = '',
    this.nextStep = '',
    this.isPinned = false,
  });

  WallItem copyWith({
    String? title,
    String? category,
    String? imageUrl,
    String? note,
    String? nextStep,
    bool? isPinned,
  }) => WallItem(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    imageUrl: imageUrl ?? this.imageUrl,
    note: note ?? this.note,
    nextStep: nextStep ?? this.nextStep,
    isPinned: isPinned ?? this.isPinned,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'category': category,
    'imageUrl': imageUrl,
    'note': note,
    'nextStep': nextStep,
    'isPinned': isPinned,
  };

  factory WallItem.fromJson(Map<String, dynamic> json) => WallItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    imageUrl: json['imageUrl'] as String,
    note: json['note'] as String? ?? '',
    nextStep: json['nextStep'] as String? ?? '',
    isPinned: json['isPinned'] as bool? ?? false,
  );
}

class InspirationCard {
  final String title;
  final String body;
  final String imageUrl;
  final String ctaLabel;

  const InspirationCard({
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.ctaLabel,
  });
}

/// Demo data matching the Stitch designs
class DemoData {
  static const user = UserProfile(
    name: 'Juan',
    streakDays: 14,
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
    bigDream: 'Land a freelance client',
    anchor: 'For my family',
    focusWindow: '08:00 AM',
  );

  static final goals = [
    Goal(
      id: '1',
      title: 'Income Goal',
      category: 'Active Focus • Financial Health',
      currentAmount: 12000,
      targetAmount: 50000,
      quote:
          '"Success is the sum of small efforts, repeated day in and day out."',
      why: 'Doing this for: My Family',
      whyImageUrl:
          'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&h=400&fit=crop',
      milestones: const [
        Milestone(
          id: 'm1',
          title: 'Portfolio Website Launch',
          status: MilestoneStatus.completed,
          subtitle: 'Completed on Oct 12',
          amountLabel: '+ ₱0',
        ),
        Milestone(
          id: 'm2',
          title: 'Outreach: 20 Cold Emails',
          status: MilestoneStatus.inProgress,
          subtitle: '14 / 20 sent',
          amountLabel: 'Pending',
        ),
        Milestone(
          id: 'm3',
          title: 'First Contract Signed',
          status: MilestoneStatus.pending,
          subtitle: 'Target: End of Month',
          amountLabel: '₱50,000',
        ),
      ],
    ),
    Goal(
      id: '2',
      title: 'Land a freelance client',
      category: 'ACTIVE GOAL',
      currentAmount: 18500,
      targetAmount: 50000,
      why: 'Doing this for: My Family',
      whyImageUrl:
          'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&h=400&fit=crop',
      milestones: const [
        Milestone(
          id: 'm1',
          title: 'Portfolio Website Launch',
          status: MilestoneStatus.completed,
          subtitle: 'Completed on Oct 12',
          amountLabel: '+ ₱0',
        ),
        Milestone(
          id: 'm2',
          title: 'Outreach: 20 Cold Emails',
          status: MilestoneStatus.inProgress,
          subtitle: '14 / 20 sent',
          amountLabel: 'Pending',
        ),
        Milestone(
          id: 'm3',
          title: 'First Contract Signed',
          status: MilestoneStatus.pending,
          subtitle: 'Target: End of Month',
          amountLabel: '₱50,000',
        ),
      ],
    ),
  ];

  static const achievedGoal = Goal(
    id: 'achieved',
    title: 'Land a freelance client',
    category: 'GOAL ACHIEVED',
    currentAmount: 50000,
    targetAmount: 50000,
    isAchieved: true,
    isActive: false,
    daysTaken: 47,
    consistencyStreak: 31,
    why: 'Doing this for: My Family',
  );

  static const disciplineTasks = [
    DisciplineTask(
      id: '1',
      title: 'Draft portfolio case study',
      completed: true,
    ),
    DisciplineTask(id: '2', title: 'Client outreach', completed: true),
    DisciplineTask(id: '3', title: 'Design exploration', completed: false),
  ];

  static const wallItems = [
    WallItem(
      id: '1',
      title: 'Nanay & Tatay',
      category: 'Family',
      imageUrl:
          'https://images.unsplash.com/photo-1609220136736-425f409d0bf0?w=600&h=400&fit=crop',
    ),
    WallItem(
      id: '2',
      title: 'The Lakehouse',
      category: 'Architecture',
      imageUrl:
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop',
    ),
    WallItem(
      id: '3',
      title: 'Swiss Alps',
      category: 'Nature',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&h=400&fit=crop',
    ),
    WallItem(
      id: '4',
      title: 'Studio Setup',
      category: 'Workspace',
      imageUrl:
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop',
    ),
  ];

  static const inspiration = InspirationCard(
    title: "Nature's Resilience",
    body:
        "Observe the way a sapling pushes through the densest terrain. Your growth isn't measured by speed, but by the persistence of your roots.",
    imageUrl:
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=500&fit=crop',
    ctaLabel: 'Read Meditation',
  );

  static const forestBanner =
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=400&fit=crop';
}
