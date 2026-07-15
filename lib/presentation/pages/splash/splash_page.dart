import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/router.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _didStartAuthCheck = false;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didStartAuthCheck) return;
      _didStartAuthCheck = true;
      final authCubit = context.read<AuthCubit>();
      authCubit.listenToAuthChanges();
      authCubit.checkAuthStatus();
    });
  }

  void _navigate(String routeName) {
    if (_didNavigate || !mounted) return;
    _didNavigate = true;
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _navigate(AppRouter.homeRoute);
          } else if (state is AuthLoggedOut || state is AuthSessionExpired) {
            _navigate(AppRouter.loginRoute);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.onPrimary,
                    child: Icon(
                      Icons.chat_bubble_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Assessment Chat App',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Opening your secure session...',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (authState is AuthError)
                    Text(
                      'Unable to verify your session right now.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  if (authState is AuthError) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        _didStartAuthCheck = false;
                        context.read<AuthCubit>().checkAuthStatus();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        side: BorderSide(color: colorScheme.onPrimary),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
