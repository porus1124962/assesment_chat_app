import '../entities/message.dart';

abstract class MessageRepository {
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<void> sendImageMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  });
  Future<void> sendVideoMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  });
  Future<void> sendAudioMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  });
  Future<void> sendDocumentMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  });
  Future<void> cancelUpload(String messageId);
  Future<void> retryUpload(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  });
  Future<void> processQueuedUploads();
  Future<String> getOrDownloadMedia(
    Message message, {
    void Function(double progress)? onProgress,
  });
  Future<void> updateMessage(String chatId, Message message);
  Future<void> deleteMessage(String chatId, String messageId);
}
