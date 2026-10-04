import 'package:flutter/material.dart';

import '../../../core/state/app_view_model.dart';
import '../../../data/models/weekly_review.dart';

/// Form state for this week's check-in, seeded from any saved review.
class WeeklyReviewViewModel extends ChangeNotifier {
  WeeklyReviewViewModel(this._app)
    : _stars = _app.currentReview?.stars ?? 0,
      reflection = TextEditingController(
        text: _app.currentReview?.reflection ?? '',
      );

  final AppViewModel _app;
  final TextEditingController reflection;
  int _stars;

  int get stars => _stars;

  String get vibeLabel => WeeklyReview.vibeLabels[_stars];

  bool get isSaved => _app.currentReview != null;

  void setStars(int value) {
    if (value < 1 || value > 5 || value == _stars) {
      return;
    }
    _stars = value;
    notifyListeners();
  }

  /// Returns an error message, or null when saved.
  Future<String?> save() async {
    if (_stars == 0) {
      return 'Choose how the week felt first.';
    }
    await _app.saveReview(stars: _stars, reflection: reflection.text);
    notifyListeners();
    return null;
  }

  @override
  void dispose() {
    reflection.dispose();
    super.dispose();
  }
}
