import 'package:flutter/material.dart';

/// Abstract repository for theme management.
/// 
/// Defines the contract for theme persistence operations.
abstract class ThemeRepository {
  /// Save theme mode preference.
  /// 
  /// Persists the selected theme mode to local storage.
  Future<void> saveThemeMode(ThemeMode themeMode);

  /// Get saved theme mode preference.
  /// 
  /// Retrieves the previously saved theme mode preference.
  /// Returns null if no preference has been saved yet.
  ThemeMode? getThemeMode();

  /// Clear theme preference from storage.
  /// 
  /// Removes the saved theme preference, allowing the system theme to be used.
  Future<void> clearThemeMode();
}
