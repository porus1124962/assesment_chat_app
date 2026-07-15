import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<void> updateUserProfile(User user);

  Stream<User?> get authStateChanges;
}
