import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/firebase_config.dart';
import 'config/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/auth/auth_state.dart';
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
            Future.microtask(() {
              context.read<ThemeBloc>().add(const ThemeInitialized());
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
            home: const _AppHome(),
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.loginRoute,
          );
        },
      ),
    );
  }
}

class _AppHome extends StatefulWidget {
  const _AppHome();

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  @override
  void initState() {
    super.initState();
    // Check auth status on app startup
    Future.microtask(() {
      context.read<AuthCubit>().checkAuthStatus();
      context.read<AuthCubit>().listenToAuthChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Navigate to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
          });
        } else if (state is AuthLoggedOut || state is AuthSessionExpired) {
          // Navigate to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
          });
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
