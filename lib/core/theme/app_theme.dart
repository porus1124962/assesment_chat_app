import 'package:flutter/material.dart';

/// Material 3 theme definitions for the application.
/// Provides light and dark themes with consistent styling.
class AppTheme {
  AppTheme._();

  // Light theme colors
  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightSecondary = Color(0xFF6366F1);
  static const Color _lightTertiary = Color(0xFF0891B2);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF475569);
  static const Color _lightBorder = Color(0xFFE2E8F0);
  static const Color _lightError = Color(0xFFDC2626);

  // Dark theme colors
  static const Color _darkBg = Color(0xFF0B1120);
  static const Color _darkSurface = Color(0xFF111827);
  static const Color _darkPrimary = Color(0xFF60A5FA);
  static const Color _darkSecondary = Color(0xFF818CF8);
  static const Color _darkTertiary = Color(0xFF06B6D4);
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);
  static const Color _darkTextSecondary = Color(0xFFCBD5E1);
  static const Color _darkBorder = Color(0xFF263244);
  static const Color _darkError = Color(0xFFF87171);

  // Border radius constants
  static const double _borderRadiusMedium = 12.0;
  static const double _borderRadiusLarge = 16.0;

  /// Light theme definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      primaryColor: _lightPrimary,
      appBarTheme: _buildAppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      cardTheme: _buildCardThemeData(_lightSurface),
      inputDecorationTheme: _buildInputDecorationTheme(
        fillColor: Colors.grey[100]!,
        borderColor: _lightBorder,
        textColor: _lightTextPrimary,
        hintColor: _lightTextSecondary,
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: _buildFilledButtonTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        foregroundColor: _lightPrimary,
        borderColor: _lightBorder,
      ),
      dialogTheme: _buildDialogThemeData(_lightSurface),
      bottomNavigationBarTheme: _buildBottomNavBarTheme(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightTextSecondary,
      ),
      dividerTheme: _buildDividerTheme(_lightBorder),
      textTheme: _buildTextTheme(
        primaryColor: _lightTextPrimary,
        secondaryColor: _lightTextSecondary,
      ),
      colorScheme: ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        tertiary: _lightTertiary,
        surface: _lightSurface,
        error: _lightError,
        outline: _lightBorder,
        outlineVariant: _lightBorder,
      ),
    );
  }

  /// Dark theme definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      primaryColor: _darkPrimary,
      appBarTheme: _buildAppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
      ),
      cardTheme: _buildCardThemeData(_darkSurface),
      inputDecorationTheme: _buildInputDecorationTheme(
        fillColor: const Color(0xFF1F2937),
        borderColor: _darkBorder,
        textColor: _darkTextPrimary,
        hintColor: _darkTextSecondary,
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: _buildFilledButtonTheme(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
      ),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        foregroundColor: _darkPrimary,
        borderColor: _darkBorder,
      ),
      dialogTheme: _buildDialogThemeData(_darkSurface),
      bottomNavigationBarTheme: _buildBottomNavBarTheme(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkTextSecondary,
      ),
      dividerTheme: _buildDividerTheme(_darkBorder),
      textTheme: _buildTextTheme(
        primaryColor: _darkTextPrimary,
        secondaryColor: _darkTextSecondary,
      ),
      colorScheme: ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        tertiary: _darkTertiary,
        surface: _darkSurface,
        error: _darkError,
        outline: _darkBorder,
        outlineVariant: _darkBorder,
      ),
    );
  }

  // Helper methods for building theme components

  static AppBarTheme _buildAppBarTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: IconThemeData(color: foregroundColor),
      titleTextStyle: TextStyle(
        color: foregroundColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static CardThemeData _buildCardThemeData(Color backgroundColor) {
    return CardThemeData(
      color: backgroundColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
      ),
      margin: const EdgeInsets.all(0),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        borderSide: BorderSide(color: textColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        borderSide: const BorderSide(color: _lightError, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        borderSide: const BorderSide(color: _lightError, width: 2),
      ),
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      labelStyle: TextStyle(color: textColor, fontSize: 14),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static DialogThemeData _buildDialogThemeData(Color backgroundColor) {
    return DialogThemeData(
      backgroundColor: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadiusLarge),
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavBarTheme({
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static DividerThemeData _buildDividerTheme(Color color) {
    return DividerThemeData(
      color: color,
      thickness: 1,
      space: 16,
    );
  }

  static TextTheme _buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primaryColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: primaryColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        color: primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: secondaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: secondaryColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
