import '../models/message_model.dart';
import '../../config/hive_config.dart';
import '../../core/errors/exceptions.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheMessages(String chatId, List<MessageModel> messages);
  Future<List<MessageModel>> getCachedMessages(String chatId);
  Future<void> cacheMessage(String chatId, MessageModel message);
  Future<void> clearCachedMessages(String chatId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  @override
  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    try {
      final box = getMessagesBox();
      for (final message in messages) {
        await box.put('${chatId}_${message.id}', message.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache messages: $e');
    }
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String chatId) async {
    try {
      final box = getMessagesBox();
      final messages = <MessageModel>[];
      for (final key in box.keys) {
        if (key.toString().startsWith('${chatId}_')) {
          final data = box.get(key);
          if (data is Map) {
            messages.add(MessageModel.fromJson(Map<String, dynamic>.from(data)));
          }
        }
      }
      // Sort by timestamp
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      throw CacheException('Failed to get cached messages: $e');
    }
  }

  @override
  Future<void> cacheMessage(String chatId, MessageModel message) async {
    try {
      final box = getMessagesBox();
      await box.put('${chatId}_${message.id}', message.toJson());
    } catch (e) {
      throw CacheException('Failed to cache message: $e');
    }
  }

  @override
  Future<void> clearCachedMessages(String chatId) async {
    try {
      final box = getMessagesBox();
      final keysToDelete = <dynamic>[];
      for (final key in box.keys) {
        if (key.toString().startsWith('${chatId}_')) {
          keysToDelete.add(key);
        }
      }
      for (final key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear cached messages: $e');
    }
  }
}
