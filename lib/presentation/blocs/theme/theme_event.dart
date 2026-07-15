import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Base class for all theme events.
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to change the application theme.
/// 
/// Emitted when the user selects a different theme mode.
/// Triggers theme persistence and app-wide theme update.
class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Event to initialize theme from saved preference.
/// 
/// Emitted during app startup to restore the user's theme choice.
/// If no saved preference exists, defaults to system theme.
class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();

  @override
  List<Object?> get props => [];
}
