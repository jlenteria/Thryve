/// A daily practice. [completed] reflects today only and is reset each day.
class DisciplineTask {
  const DisciplineTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  factory DisciplineTask.fromJson(Map<String, dynamic> json) => DisciplineTask(
    id: json['id'] as String,
    title: json['title'] as String,
    completed: json['completed'] as bool? ?? false,
  );

  final String id;
  final String title;
  final bool completed;

  DisciplineTask copyWith({String? title, bool? completed}) => DisciplineTask(
    id: id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'completed': completed,
  };
}
