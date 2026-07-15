import 'package:flutter/material.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

/// Implementation of ThemeRepository.
/// 
/// Provides concrete implementation for theme persistence using SharedPreferences.
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await localDataSource.saveThemeMode(themeMode);
  }

  @override
  ThemeMode? getThemeMode() {
    return localDataSource.getThemeMode();
  }

  @override
  Future<void> clearThemeMode() async {
    await localDataSource.clearThemeMode();
  }
}
