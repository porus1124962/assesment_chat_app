import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(String userId);
  Future<void> updateUserProfile(User user);
}
