import 'package:flutter/material.dart';
import '../models/models.dart';

class OnboardingViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dreamController = TextEditingController();
  final TextEditingController anchorController = TextEditingController();

  int _step = 0;
  TimeOfDay _focusTime = const TimeOfDay(hour: 8, minute: 0);
  String? _anchorImageUrl;
  GoalTrackingType _trackingType = GoalTrackingType.progress;

  int get step => _step;
  TimeOfDay get focusTime => _focusTime;
  String? get anchorImageUrl => _anchorImageUrl;
  GoalTrackingType get trackingType => _trackingType;

  String get name =>
      nameController.text.trim().isEmpty ? 'you' : nameController.text.trim();

  String get anchor {
    final text = anchorController.text.trim();
    if (text.isEmpty) return 'your family';
    return text;
  }

  double get progress => (_step + 1) / 3.0;

  bool get isLastStep => _step >= 2;

  void nextStep() {
    if (_step < 2) {
      _step++;
      pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      notifyListeners();
    }
  }

  void setFocusTime(TimeOfDay time) {
    _focusTime = time;
    notifyListeners();
  }

  void setAnchorImageUrl(String value) {
    _anchorImageUrl = value.trim().isEmpty ? null : value.trim();
    notifyListeners();
  }

  void setTrackingType(GoalTrackingType value) {
    _trackingType = value;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    dreamController.dispose();
    anchorController.dispose();
    super.dispose();
  }
}
