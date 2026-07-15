import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';

/// Example widget for theme switching.
///
/// Provides a button that cycles through light, dark, and system themes.
/// Uses BLoC to dispatch theme change events.
class ThemeToggleButton extends StatelessWidget {
  final void Function()? onThemeChanged;

  const ThemeToggleButton({super.key, this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentMode = state is ThemeStateData
            ? state.themeMode
            : ThemeMode.system;

        return Tooltip(
          message: _getTooltipMessage(currentMode),
          child: IconButton(
            icon: _getThemeIcon(currentMode),
            onPressed: () => _toggleTheme(context, currentMode),
            tooltip: 'Toggle theme',
          ),
        );
      },
    );
  }

  /// Get the icon for the current theme mode.
  Icon _getThemeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => const Icon(Icons.light_mode),
      ThemeMode.dark => const Icon(Icons.dark_mode),
      ThemeMode.system => const Icon(Icons.brightness_auto),
    };
  }

  /// Get tooltip message for the current theme mode.
  String _getTooltipMessage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light mode - tap to switch to dark',
      ThemeMode.dark => 'Dark mode - tap to switch to system',
      ThemeMode.system => 'System mode - tap to switch to light',
    };
  }

  /// Toggle between theme modes in sequence: light -> dark -> system -> light.
  void _toggleTheme(BuildContext context, ThemeMode currentMode) {
    final nextMode = switch (currentMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };

    // Dispatch theme change event
    context.read<ThemeBloc>().add(ThemeChanged(nextMode));

    // Optional callback
    onThemeChanged?.call();

    // Show feedback
    AppSnackBar.showInfo(
      context,
      'Theme changed to ${nextMode.name}',
      duration: const Duration(milliseconds: 800),
    );
  }
}

/// Alternative: Theme mode menu button for AppBar.
///
/// Displays a dropdown menu with theme options instead of cycling.
class ThemeMenuButton extends StatelessWidget {
  final void Function()? onThemeChanged;

  const ThemeMenuButton({super.key, this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentMode = state is ThemeStateData
            ? state.themeMode
            : ThemeMode.system;

        return PopupMenuButton<ThemeMode>(
          initialValue: currentMode,
          onSelected: (ThemeMode mode) {
            context.read<ThemeBloc>().add(ThemeChanged(mode));
            onThemeChanged?.call();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.light_mode, size: 20),
                  SizedBox(width: 12),
                  Text('Light'),
                ],
              ),
            ),
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dark_mode, size: 20),
                  SizedBox(width: 12),
                  Text('Dark'),
                ],
              ),
            ),
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.brightness_auto, size: 20),
                  SizedBox(width: 12),
                  Text('System'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
