import 'package:flutter/material.dart';

enum AppSnackBarType { info, success, warning, error }

class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final (backgroundColor, icon) = switch (type) {
      AppSnackBarType.info => (
        colorScheme.inverseSurface,
        Icons.info_outline_rounded,
      ),
      AppSnackBarType.success => (
        Colors.green.shade700,
        Icons.check_circle_outline_rounded,
      ),
      AppSnackBarType.warning => (
        Colors.orange.shade800,
        Icons.warning_amber_rounded,
      ),
      AppSnackBarType.error => (
        colorScheme.errorContainer,
        Icons.error_outline_rounded,
      ),
    };

    final foregroundColor = switch (type) {
      AppSnackBarType.error => colorScheme.onErrorContainer,
      _ => Colors.white,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          content: Row(
            children: [
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _normalizeMessage(message),
                  style: TextStyle(color: foregroundColor),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.error,
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.success,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.info,
      duration: duration,
    );
  }

  static String _normalizeMessage(String message) {
    final trimmed = message.trim();
    const prefixes = ['Exception:', 'FirebaseException:'];

    for (final prefix in prefixes) {
      if (trimmed.startsWith(prefix)) {
        return trimmed.substring(prefix.length).trim();
      }
    }

    return trimmed;
  }
}
