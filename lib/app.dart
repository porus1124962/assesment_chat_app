import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/firebase_config.dart';
import 'config/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/cubits/connectivity/connectivity_cubit.dart';
import 'presentation/cubits/connectivity/connectivity_state.dart';

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
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
                      buildWhen: (previous, current) {
                        final wasConnected =
                            previous is! ConnectivityDisconnected;
                        final isConnected =
                            current is! ConnectivityDisconnected;
                        final shouldRebuild = wasConnected != isConnected;
                        print('[App Banner] buildWhen - previous: ${previous.runtimeType}, current: ${current.runtimeType}, should rebuild: $shouldRebuild');
                        return shouldRebuild;
                      },
                      builder: (context, state) {
                        print('[App Banner] builder called with state: ${state.runtimeType}');
                        if (state is ConnectivityDisconnected) {
                          print('[App Banner] Showing disconnected banner');
                          return AnimatedSlide(
                            offset: Offset.zero,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              color: Colors.red.shade900,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.wifi_off_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No connectivity',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white,

                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context
                                        .read<ConnectivityCubit>()
                                        .retryConnection(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Refresh',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.red.shade900,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        print('[App Banner] Hiding banner, state: ${state.runtimeType}');
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
