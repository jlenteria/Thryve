enum MilestoneStatus {
  pending('Pending'),
  inProgress('In progress'),
  completed('Completed');

  const MilestoneStatus(this.label);

  final String label;
}

class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    this.status = MilestoneStatus.pending,
    this.note,
    this.valueLabel,
    this.completedAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json['id'] as String,
    title: json['title'] as String,
    status: MilestoneStatus.values.firstWhere(
      (MilestoneStatus value) => value.name == json['status'],
      orElse: () => MilestoneStatus.pending,
    ),
    note: (json['note'] ?? json['subtitle']) as String?,
    valueLabel: (json['valueLabel'] ?? json['amountLabel']) as String?,
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
  );

  final String id;
  final String title;
  final MilestoneStatus status;

  /// Free-form details such as "Due Friday" or "14 / 20 sent".
  final String? note;

  /// Optional value shown on the trailing edge, e.g. "₱5,000".
  final String? valueLabel;
  final DateTime? completedAt;

  bool get isCompleted => status == MilestoneStatus.completed;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'status': status.name,
    'note': note,
    'valueLabel': valueLabel,
    'completedAt': completedAt?.toIso8601String(),
  };
}
