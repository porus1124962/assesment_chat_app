import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_local_datasource.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../core/errors/exceptions.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // --- Chat-level API required by domain repository ---
  @override
  Stream<List<ChatEntity>> getUserChats(String userId) {
    try {
      return remoteDataSource.getUserChatsStream(userId).map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );
    } catch (e) {
      throw FirestoreException('Failed to stream user chats: $e');
    }
  }

  @override
  Future<void> createChat(String user1, String user2) async {
    try {
      await remoteDataSource.createChat(user1, user2);
    } catch (e) {
      throw FirestoreException('Failed to create chat: $e');
    }
  }

  @override
  Future<String> getOrCreateChatId(String user1, String user2) {
    return remoteDataSource.getOrCreateChatId(user1, user2);
  }

  // --- Message-level helpers (kept for presentation layer compatibility) ---
  Stream<List<Message>> getMessagesStream(String userId1, String userId2) async* {
    try {
      final chatId = await remoteDataSource.getOrCreateChatId(userId1, userId2);
      await for (final messageModels in
          remoteDataSource.getMessagesStream(userId1, userId2)) {
        // Cache messages locally
        await localDataSource.cacheMessages(chatId, messageModels);

        // Convert to entities and filter deleted messages
        final messages = messageModels
            .where((m) => !m.isDeleted)
            .map((model) => model.toEntity())
            .toList();
        yield messages;
      }
    } catch (e) {
      // Try to return cached messages on error
      try {
        final chatId = await remoteDataSource.getOrCreateChatId(userId1, userId2);
        final cachedMessages = await localDataSource.getCachedMessages(chatId);
        yield cachedMessages
            .where((m) => !m.isDeleted)
            .map((model) => model.toEntity())
            .toList();
      } catch (_) {
        throw FirestoreException('Failed to get messages: $e');
      }
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      await remoteDataSource.sendMessage(messageModel);

      // Cache locally
      final chatId = await remoteDataSource.getOrCreateChatId(
        message.senderId,
        message.receiverId,
      );
      await localDataSource.cacheMessage(chatId, messageModel);
    } catch (e) {
      throw FirestoreException('Failed to send message: $e');
    }
  }

  Future<void> updateMessage(String chatId, String messageId, String newText) async {
    try {
      await remoteDataSource.updateMessage(chatId, messageId, newText);
    } catch (e) {
      throw FirestoreException('Failed to update message: $e');
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await remoteDataSource.deleteMessage(chatId, messageId);
    } catch (e) {
      throw FirestoreException('Failed to delete message: $e');
    }
  }

  Future<String> getChatId(String userId1, String userId2) {
    return remoteDataSource.getOrCreateChatId(userId1, userId2);
  }

  Future<List<String>> getChatPartners(String userId) async {
    try {
      return await remoteDataSource.getChatPartners(userId);
    } catch (e) {
      throw FirestoreException('Failed to fetch chat partners: $e');
    }
  }
}
