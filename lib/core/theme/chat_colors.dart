import 'package:flutter/material.dart';

/// Chat-specific color palette for messages and assessment indicators.
class ChatColors {
  ChatColors._();

  // User message bubble colors
  static const Color userBubbleLight = Color(0xFF2563EB);
  static const Color userBubbleDark = Color(0xFF1D4ED8);

  // AI message bubble colors
  static const Color aiBubbleLight = Color(0xFFE2E8F0);
  static const Color aiBubbleDark = Color(0xFF1E293B);

  // Assessment status colors (same for both themes)
  static const Color correct = Color(0xFF16A34A);
  static const Color wrong = Color(0xFFDC2626);
  static const Color review = Color(0xFFF59E0B);
  static const Color current = Color(0xFF2563EB);

  /// Get user message bubble color based on theme
  static Color getUserBubbleColor(bool isDarkMode) =>
      isDarkMode ? userBubbleDark : userBubbleLight;

  /// Get AI message bubble color based on theme
  static Color getAIBubbleColor(bool isDarkMode) =>
      isDarkMode ? aiBubbleDark : aiBubbleLight;

  /// Get assessment status color
  static Color getAssessmentColor(AssessmentStatus status) {
    return switch (status) {
      AssessmentStatus.correct => correct,
      AssessmentStatus.wrong => wrong,
      AssessmentStatus.review => review,
      AssessmentStatus.current => current,
    };
  }
}

/// Enum for assessment status types
enum AssessmentStatus {
  correct,
  wrong,
  review,
  current,
}
