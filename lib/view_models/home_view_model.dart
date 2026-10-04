import 'package:flutter/foundation.dart';
import '../models/models.dart';

class HomeViewModel extends ChangeNotifier {
  UserProfile get user => DemoData.user;
  Goal get activeGoal => DemoData.goals.first;
  Goal get detailGoal => DemoData.goals[1];
  InspirationCard get inspiration => DemoData.inspiration;

  List<DisciplineTask> _tasks = List.from(DemoData.disciplineTasks);

  List<DisciplineTask> get tasks => List.unmodifiable(_tasks);

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    _tasks[index] = DisciplineTask(
      id: task.id,
      title: task.title,
      completed: !task.completed,
    );
    notifyListeners();
  }
}
