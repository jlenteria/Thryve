/// App-wide constants that are not part of the design system.
abstract final class AppConstants {
  static const String appName = 'Thryve';
  static const String defaultCurrency = '₱';

  /// SharedPreferences key for the serialized [AppState]. The `v1` suffix is
  /// kept so data saved by earlier builds is still read; the schema version
  /// now lives inside the payload.
  static const String stateKey = 'thryve.app_state.v1';
  static const String themeKey = 'current_theme';

  static const int dailyReminderId = 1001;

  /// How many days of activity history to keep for streaks and reviews.
  static const int activityRetentionDays = 400;
}
