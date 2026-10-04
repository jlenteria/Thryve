import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../view_model.dart';

class OnboardScreenViewModel extends ViewModel {
  final PageController pageController = PageController();
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // ── Step 1: Name + Dream ───────────────────────────────────────
  final TextEditingController nameController  = TextEditingController();
  final TextEditingController dreamController = TextEditingController();
  String get name  => nameController.text.trim();
  String get dream => dreamController.text.trim();

  bool get isStep1Valid => name.isNotEmpty && dream.isNotEmpty;

  bool get canContinue => isStep1Valid;

  bool _nameTouched = false;
  bool _dreamTouched = false;

  bool get showNameError => _nameTouched && name.isEmpty;
  bool get showDreamError => _dreamTouched && dream.isEmpty;

  void onNameChanged(String text) {
    _nameTouched = true;
    notifyListeners();
  }

  void onDreamChanged(String text) {
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

  // ── Step 2: Who + Anchor ───────────────────────────────────────
  final TextEditingController anchorController = TextEditingController();
  File? _anchorImage;
 
  File? get anchorImage => _anchorImage;
  String get anchorText => anchorController.text.trim();

  bool get isStep2Valid => anchorText.isNotEmpty;
  bool get canContinueStep2 => isStep1Valid && isStep2Valid;

  bool _anchorTouched = false;
  bool get showAnchorError => _anchorTouched && anchorText.isEmpty;

  void onAnchorChanged(String text) {
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
  
   Future<void> pickAnchorImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      _anchorImage = File(picked.path);
      notifyListeners();
    }
  }
 
  void removeAnchorImage() {
    _anchorImage = null;
    notifyListeners();
  }

  // ── Step 3: Reminder time ──────────────────────────────────────
  int  _reminderHour    = 8;
  int  _reminderMinute  = 0;
  bool _isAm            = true;
  bool _reminderEnabled = true;
 
  int  get reminderHour    => _reminderHour;
  int  get reminderMinute  => _reminderMinute;
  bool get isAm            => _isAm;
  bool get reminderEnabled => _reminderEnabled;
 

  
  String get formattedTime {
    final String h      = _reminderHour.toString().padLeft(2, '0');
    final String m      = _reminderMinute.toString().padLeft(2, '0');
    final String period = _isAm ? 'AM' : 'PM';
    return '$h:$m $period';
  }
 
  // Convert to 24-hour for storage / notification scheduling
  int get reminderHour24 {
    if (_isAm && _reminderHour == 12) {
      return 0;
    }
    if (!_isAm && _reminderHour != 12) {
      return _reminderHour + 12;
    }
    return _reminderHour;
  }

  String get notifTitle {
    return name.isNotEmpty
      ? 'Hey $name, time to thryve 🌱'
      : 'Time to thryve 🌱';
  }

  String get highlighted {
    if (anchorText.isNotEmpty) {
      return anchorText;
    }
    if (name.isNotEmpty) {
      return '$name. Keep going.';
    }
    return 'Your future self will thank you';
  }

  String get notifBody {
    const String timeLabel = 'Take a few minutes';
    if (anchorText.isNotEmpty) {
      return '$timeLabel of action today. $anchorText';
    } else if (name.isNotEmpty) {
      return '$timeLabel of action today, $name. Keep going.';
    }

    return '$timeLabel of action today. Your future self will thank you.';
  }
 
  void setReminderHour(int hour) {
    _reminderHour = hour.clamp(1, 12);
    notifyListeners();
  }
 
  void setReminderMinute(int minute) {
    _reminderMinute = minute.clamp(0, 59);
    notifyListeners();
  }
 
  void setAmPm(bool isAm) {
    _isAm = isAm;
    notifyListeners();
  }
 
  void toggleReminder(bool enabled) {
    _reminderEnabled = enabled;
    notifyListeners();
  }
 
  // ── Navigation ─────────────────────────────────────────────────
  void nextStep() {
    if (_currentStep >= 2) {
      return;
    }
    _currentStep++;
    pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }
 
  void prevStep() {
    if (_currentStep <= 0) {
      return;
    }
    _currentStep--;
    pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }
 
  // ── Saving state ───────────────────────────────────────────────
  bool _isSaving = false;
  bool get isSaving => _isSaving;
  
   Future<bool> completeOnboarding() async {
    return true;
   }
  
  

}