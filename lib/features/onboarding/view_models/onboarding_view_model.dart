import 'package:flutter/material.dart';

import '../../../core/services/image_store.dart';
import '../../../core/services/reminder_copy.dart';
import '../../../core/state/app_view_model.dart';
import '../../../core/state/view_model.dart';
import '../../../core/utils/formatters.dart';

class OnboardingViewModel extends ViewModel {
  OnboardingViewModel(this._app);

  static const int stepCount = 3;

  final AppViewModel _app;
  final PageController pageController = PageController();
  int _currentStep = 0;

  int get currentStep => _currentStep;

  // ── Step 1: Name + Dream ───────────────────────────────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dreamController = TextEditingController();
  bool _nameTouched = false;
  bool _dreamTouched = false;

  String get name => nameController.text.trim();
  String get dream => dreamController.text.trim();
  bool get isStep1Valid => name.isNotEmpty && dream.isNotEmpty;
  bool get showNameError => _nameTouched && name.isEmpty;
  bool get showDreamError => _dreamTouched && dream.isEmpty;

  void onNameChanged(String _) {
    _nameTouched = true;
    notifyListeners();
  }

  void onDreamChanged(String _) {
    _dreamTouched = true;
    notifyListeners();
  }

  void continueFromStep1() {
    if (!isStep1Valid) {
      _nameTouched = true;
      _dreamTouched = true;
      notifyListeners();
      return;
    }
    nextStep();
  }

  // ── Step 2: Anchor ─────────────────────────────────────────────
  final TextEditingController anchorController = TextEditingController();
  String? _anchorImage;
  bool _anchorTouched = false;

  String? get anchorImage => _anchorImage;
  String get anchorText => anchorController.text.trim();
  bool get isStep2Valid => anchorText.isNotEmpty;
  bool get showAnchorError => _anchorTouched && anchorText.isEmpty;

  void onAnchorChanged(String _) {
    _anchorTouched = true;
    notifyListeners();
  }

  void continueFromStep2() {
    if (!isStep2Valid) {
      _anchorTouched = true;
      notifyListeners();
      return;
    }
    nextStep();
  }

  /// Returns false if the photo library couldn't be opened.
  Future<bool> pickAnchorImage() async {
    try {
      final String? ref = await ImageStore.pickFromGallery();
      if (ref != null) {
        await ImageStore.delete(_anchorImage);
        _anchorImage = ref;
        notifyListeners();
      }
      return true;
    } on Object {
      return false;
    }
  }

  void removeAnchorImage() {
    ImageStore.delete(_anchorImage);
    _anchorImage = null;
    notifyListeners();
  }

  // ── Step 3: Reminder time ──────────────────────────────────────
  int _reminderHour = 8;
  int _reminderMinute = 0;
  bool _isAm = true;

  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  bool get isAm => _isAm;

  TimeOfDay get reminderTime {
    final int hour24 = _isAm
        ? (_reminderHour == 12 ? 0 : _reminderHour)
        : (_reminderHour == 12 ? 12 : _reminderHour + 12);
    return TimeOfDay(hour: hour24, minute: _reminderMinute);
  }

  String get formattedTime => Formatters.timeOfDay(reminderTime);

  ReminderCopy get reminderCopy => ReminderCopy(name: name, anchor: anchorText);

  void setReminderHour(int hour) {
    _reminderHour = hour.clamp(1, 12);
    notifyListeners();
  }

  void setReminderMinute(int minute) {
    _reminderMinute = minute.clamp(0, 59);
    notifyListeners();
  }

  void setAmPm({required bool isAm}) {
    _isAm = isAm;
    notifyListeners();
  }

  // ── Navigation ─────────────────────────────────────────────────
  void nextStep() {
    if (_currentStep >= stepCount - 1) {
      return;
    }
    _currentStep++;
    _animateToStep();
  }

  void prevStep() {
    if (_currentStep <= 0) {
      return;
    }
    _currentStep--;
    _animateToStep();
  }

  void _animateToStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  // ── Completion ─────────────────────────────────────────────────
  bool _completed = false;

  /// Saves the profile and first goal. The app root then switches to the
  /// main shell on its own.
  Future<void> complete({required bool enableReminders}) async {
    if (isLoading) {
      return;
    }
    startLoading();
    try {
      await _app.completeOnboarding(
        name: name,
        dream: dream,
        anchor: anchorText,
        anchorImage: _anchorImage,
        reminderTime: reminderTime,
        remindersEnabled: enableReminders,
      );
      _completed = true;
    } finally {
      stopLoading();
    }
  }

  @override
  void dispose() {
    if (!_completed) {
      ImageStore.delete(_anchorImage);
    }
    pageController.dispose();
    nameController.dispose();
    dreamController.dispose();
    anchorController.dispose();
    super.dispose();
  }
}
