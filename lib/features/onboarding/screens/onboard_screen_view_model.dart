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



  // ── Step 2: Who + Anchor ───────────────────────────────────────
  final TextEditingController anchorController = TextEditingController();
  File? _anchorImage;
 
  File? get anchorImage => _anchorImage;
  String get anchorText => anchorController.text.trim();
  
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
    final h      = _reminderHour.toString().padLeft(2, '0');
    final m      = _reminderMinute.toString().padLeft(2, '0');
    final period = _isAm ? 'AM' : 'PM';
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
  
  
  

}