import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC for managing application theme state.
/// 
/// Handles theme switching events, persists user preference,
/// and emits theme state changes for the entire app to rebuild reactively.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository themeRepository;

  ThemeBloc({required this.themeRepository})
      : super(const ThemeInitial()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);
  }

  /// Handle theme initialization on app startup.
  /// 
  /// Loads saved theme preference from repository.
  /// Defaults to system theme if no preference exists.
  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      // Try to load saved theme preference
      final savedThemeMode = themeRepository.getThemeMode();
      
      // Use saved theme or default to system theme
      final themeMode = savedThemeMode ?? ThemeMode.system;
      
      emit(ThemeStateData(themeMode: themeMode));
    } catch (e) {
      // On error, default to system theme
      emit(const ThemeStateData(themeMode: ThemeMode.system));
    }
  }

  /// Handle theme change event.
  /// 
  /// Updates the theme mode and persists the choice.
  /// Emits new state to trigger app-wide rebuild.
  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      // Save the theme preference
      await themeRepository.saveThemeMode(event.themeMode);
      
      // Emit new state to trigger rebuild
      emit(ThemeStateData(themeMode: event.themeMode));
    } catch (e) {
      // On error, emit current state (no change)
      if (state is ThemeStateData) {
        emit(state as ThemeStateData);
      }
    }
  }

  /// Get the current theme mode.
  /// 
  /// Returns the current theme mode from state, or system theme if not set.
  ThemeMode get currentThemeMode {
    if (state is ThemeStateData) {
      return (state as ThemeStateData).themeMode;
    }
    return ThemeMode.system;
  }

  /// Check if dark mode is currently enabled.
  /// 
  /// Note: For ThemeMode.system, this returns false.
  /// To get actual dark mode status, check MediaQuery.of(context).platformBrightness
  bool get isDarkMode => currentThemeMode == ThemeMode.dark;
}
