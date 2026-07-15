import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final userModels = await remoteDataSource.getAllUsers();
      return userModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final userModel = await remoteDataSource.getUserById(userId);
      return userModel?.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await remoteDataSource.updateUserProfile(userModel);
    } catch (e) {
      rethrow;
    }
  }
}
