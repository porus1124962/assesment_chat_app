import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for theme persistence using SharedPreferences.
class ThemeLocalDataSource {
  static const String _themeKey = 'app_theme_mode';

  final SharedPreferences prefs;

  ThemeLocalDataSource({required this.prefs});

  /// Save theme mode preference.
  /// 
  /// Saves the theme mode as a string representation.
  /// Possible values: 'light', 'dark', 'system'
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final themeModeString = _themeModeToString(themeMode);
    await prefs.setString(_themeKey, themeModeString);
  }

  /// Get saved theme mode preference.
  /// 
  /// Returns the saved theme mode or null if no preference exists.
  /// Defaults to system theme if no preference is found.
  ThemeMode? getThemeMode() {
    final themeModeString = prefs.getString(_themeKey);
    if (themeModeString == null) return null;
    return _stringToThemeMode(themeModeString);
  }

  /// Clear theme preference from storage.
  Future<void> clearThemeMode() async {
    await prefs.remove(_themeKey);
  }

  /// Convert ThemeMode to string representation.
  String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  /// Convert string to ThemeMode.
  ThemeMode _stringToThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }
}
