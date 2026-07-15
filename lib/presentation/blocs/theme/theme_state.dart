import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Base class for all theme states.
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Initial theme state.
/// 
/// Represents the state before the first theme is loaded.
class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

/// Active theme state containing the current theme mode.
/// 
/// Holds the current ThemeMode and triggers MaterialApp rebuild
/// when state changes.
class ThemeStateData extends ThemeState {
  final ThemeMode themeMode;

  const ThemeStateData({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];

  /// Create a copy with modified fields.
  ThemeStateData copyWith({ThemeMode? themeMode}) {
    return ThemeStateData(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
