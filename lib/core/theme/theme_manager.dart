import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/shared_pref_keys.dart';

class ThemeManager with ChangeNotifier, WidgetsBindingObserver {
  ThemeManager() {
    init();
  }

  Brightness get brightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  Key _key = UniqueKey();
  Key get key => _key;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isSystemTheme = false;
  ThemeType? _currentTheme = ThemeType.light;

  ThemeType? get currentTheme => _currentTheme;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    final String? themeName = sharedPreferences.getString(
      SharedPrefKeys.currentTheme,
    );

    _isSystemTheme = themeName == ThemeType.system.name;
    _isDarkMode =
        (_isSystemTheme && brightness == Brightness.dark) ||
        themeName == ThemeType.dark.name;
    _currentTheme = ThemeType.values.firstWhere(
      (ThemeType theme) => theme.name == themeName,
      orElse: () => ThemeType.light,
    );
    notifyListeners();
  }

  Future<void> applyTheme(ThemeType type) async {
    if (type == _currentTheme) {
      return;
    }
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    await sharedPreferences.setString(SharedPrefKeys.currentTheme, type.name);
    _key = UniqueKey();
    _currentTheme = type;
    _isSystemTheme = currentTheme == ThemeType.system;
    _isDarkMode =
        (_isSystemTheme && brightness == Brightness.dark) ||
        currentTheme == ThemeType.dark;
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    if (_isSystemTheme) {
      _isDarkMode = brightness == Brightness.dark;
    }
    notifyListeners();
    super.didChangePlatformBrightness();
  }
}

enum ThemeType { light, dark, system }
