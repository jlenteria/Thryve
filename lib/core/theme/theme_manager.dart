import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Persists the user's appearance choice. Platform brightness changes are
/// handled by [MaterialApp] itself when [themeMode] is [ThemeMode.system].
class ThemeManager extends ChangeNotifier {
  ThemeManager() {
    _restore();
  }

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> _restore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(AppConstants.themeKey);
    final ThemeMode restored = ThemeMode.values.firstWhere(
      (ThemeMode mode) => mode.name == stored,
      orElse: () => ThemeMode.light,
    );
    if (restored != _themeMode) {
      _themeMode = restored;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, mode.name);
  }
}
