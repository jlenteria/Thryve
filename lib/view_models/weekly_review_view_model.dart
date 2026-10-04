import 'package:flutter/material.dart';

import 'app_view_model.dart';

class WeeklyReviewViewModel extends ChangeNotifier {
  WeeklyReviewViewModel(AppViewModel app)
    : _vibeStars = app.vibeStars,
      reflectionController = TextEditingController(text: app.reflection);

  int _vibeStars;
  final TextEditingController reflectionController;

  int get vibeStars => _vibeStars;

  void setVibeStars(int stars) {
    if (stars < 1 || stars > 5) return;
    _vibeStars = stars;
    notifyListeners();
  }

  @override
  void dispose() {
    reflectionController.dispose();
    super.dispose();
  }
}
