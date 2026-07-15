import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/home/all_user_list.dart';
import '../../presentation/pages/chat/chat_page.dart';
import '../../presentation/pages/profile/edit_profile.dart';
import '../presentation/cubits/all_users/all_user_list_cubit.dart';
import 'firebase_config.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String allUserListRoute = '/allUsers';
  static const String chatRoute = '/chat';
  static const String editProfileRoute = '/editProfile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (context) => LoginPage(
            onRegisterTap: () => _navigateToRegister(context),
          ),
        );
      case registerRoute:
        return MaterialPageRoute(
          builder: (context) => RegisterPage(
            onLoginTap: () => _navigateToLogin(context),
          ),
        );
      case homeRoute:
        return MaterialPageRoute(
          builder: (context) => HomePage(
            onLogout: () => _navigateToLogin(context),
            navigateAllUsers: () => _navigateToAllUser(context),
            navigateEditProfile: () => _navigateToEditProfile(context),
            onUserTap: (userId, userName) {
              _navigateToChat(context, userId, userName);
            },
          ),
        );
      case allUserListRoute:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => AllUserListCubit(
              userRepository: getIt<UserRepositoryImpl>(),
              chatRepository: getIt<ChatRepository>(),
            ),
            child: AllUserList(
              onUserTap: (userId, userName) {
                _navigateToChat(context, userId, userName);
              },
            ),
          ),
        );
      case chatRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ChatPage(
            otherUserId: args['userId'] as String,
            otherUserName: args['userName'] as String,
            onBack: () => Navigator.pop(context),
          ),
        );
      case editProfileRoute:
        return MaterialPageRoute(
          builder: (context) => const EditProfilePage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, loginRoute);
  }

  static void _navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, registerRoute);
  }
  static void _navigateToAllUser(BuildContext context) {
    Navigator.pushNamed(context, allUserListRoute);
  }
  static void _navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, editProfileRoute);
  }
  static void _navigateToChat(
    BuildContext context,
    String userId,
    String userName,
  ) {
    Navigator.pushNamed(
      context,
      chatRoute,
      arguments: {'userId': userId, 'userName': userName},
    );
  }
}
