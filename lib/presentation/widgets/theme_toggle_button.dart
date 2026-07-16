import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';

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
  }
}
