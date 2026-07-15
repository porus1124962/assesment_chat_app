import '../entities/chat.dart';

abstract class ChatRepository {
  /// Stream of chats where [userId] is a participant, ordered by updatedAt desc
  Stream<List<ChatEntity>> getUserChats(String userId);

  /// Create chat document for two users if it does not exist
  Future<void> createChat(String user1, String user2);

  /// Deterministic chat id for two users (sorted join)
  Future<String> getOrCreateChatId(String user1, String user2);

  /// Return list of other userIds who have exchanged messages with given user
  Future<List<String>> getChatPartners(String userId);
}
