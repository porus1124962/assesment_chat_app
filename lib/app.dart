import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/firebase_config.dart';
import 'config/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';
import 'presentation/blocs/theme/theme_state.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: provideBlocProviders(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Initialize theme on first load
          if (themeState is ThemeInitial) {
            final themeBloc = context.read<ThemeBloc>();
            Future.microtask(() {
              themeBloc.add(const ThemeInitialized());
            });
          }

          // Extract current theme mode
          final themeMode = themeState is ThemeStateData
              ? themeState.themeMode
              : ThemeMode.system;

          return MaterialApp(
            title: 'Assessment Chat App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashPage(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
