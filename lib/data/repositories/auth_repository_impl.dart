import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
    String? profilePicturePath,
  }) async {
    try {
      final userModel = await remoteDataSource.signup(
        email: email,
        password: password,
        name: name,
        profilePicturePath: profilePicturePath,
      );
      // Cache user session
      await localDataSource.cacheUserSession(userModel);
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      // Cache user session
      await localDataSource.cacheUserSession(userModel);
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearUserSession();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel != null) {
        await localDataSource.cacheUserSession(userModel);
      }
      return userModel?.toEntity();
    } catch (e) {
      // Try to get from cache if remote fails
      try {
        final cachedUser = await localDataSource.getCachedUserSession();
        return cachedUser?.toEntity();
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<User> updateUserProfile(
    User user, {
    String? profilePicturePath,
  }) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUserModel = await remoteDataSource.updateUserProfile(
       userModel,
       profilePicturePath: profilePicturePath,
      );
      await localDataSource.cacheUserSession(updatedUserModel);
      return updatedUserModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((authUser) async {
      if (authUser == null) {
        await localDataSource.clearUserSession();
        return null;
      }
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel != null) {
        await localDataSource.cacheUserSession(userModel);
      }
      return userModel?.toEntity();
    });
  }
}
