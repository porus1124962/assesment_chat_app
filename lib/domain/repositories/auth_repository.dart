import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signup({
    required String email,
    required String password,
    required String name,
    String? profilePicturePath,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<User> updateUserProfile(
    User user, {
    String? profilePicturePath,
  });

  Stream<User?> get authStateChanges;
}
