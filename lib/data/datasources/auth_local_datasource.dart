import '../models/user_model.dart';
import '../../config/hive_config.dart';
import '../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserSession(UserModel user);
  Future<UserModel?> getCachedUserSession();
  Future<void> clearUserSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheUserSession(UserModel user) async {
    try {
      final box = getUserSessionBox();
      await box.put('current_user', user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user session: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUserSession() async {
    try {
      final box = getUserSessionBox();
      final userData = box.get('current_user') as Map?;
      if (userData == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    } catch (e) {
      throw CacheException('Failed to get cached user session: $e');
    }
  }

  @override
  Future<void> clearUserSession() async {
    try {
      final box = getUserSessionBox();
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear user session: $e');
    }
  }
}
