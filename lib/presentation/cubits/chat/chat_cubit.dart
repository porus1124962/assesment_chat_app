import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/message_repository.dart';
import 'chat_state.dart';

const uuid = Uuid();

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  final MessageRepository messageRepository;
  final Connectivity _connectivity;

  StreamSubscription<List<Message>>? _messagesSub;
  StreamSubscription<dynamic>? _connectivitySub;
  String? _chatId;

  ChatCubit({
    required this.chatRepository,
    required this.messageRepository,
    Connectivity? connectivity,
    bool listenConnectivity = false,
  }) : _connectivity = connectivity ?? Connectivity(),
       super(const ChatInitial()) {
    if (listenConnectivity) {
      _connectivitySub = _connectivity.onConnectivityChanged.listen((
        event,
      ) async {
        if (_hasConnection(event)) {
          await messageRepository.processQueuedUploads();
        }
      });
    }
  }

  Future<void> fetchMessages(String currentUserId, String otherUserId) async {
    emit(const ChatLoading());
    await _messagesSub?.cancel();

    try {
      _chatId = await chatRepository.getOrCreateChatId(
        currentUserId,
        otherUserId,
      );
      _messagesSub = messageRepository.getMessages(_chatId!).listen((messages) {
        if (messages.isEmpty) {
          emit(const ChatEmpty());
        } else {
          emit(ChatLoaded(messages));
        }
      }, onError: (e) => emit(ChatError(e.toString())));
    } on FirestoreException catch (e) {
      emit(ChatError(e.message));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage({
    required String currentUserId,
    required String receiverId,
    required String messageText,
  }) async {
    try {
      final current = _messagesFromState();
      emit(MessageSending(current));

      final message = Message(
        id: uuid.v4(),
        senderId: currentUserId,
        receiverId: receiverId,
        text: messageText,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      await messageRepository.sendMessage(message);
      final updatedMessage = message.copyWith(status: MessageStatus.sent);
      final newMessages = <Message>[...current, updatedMessage];

      emit(MessageSent(newMessages));
      emit(ChatLoaded(newMessages));
    } catch (e) {
      final messages = _messagesFromState();
      emit(ChatError('Failed to send message: $e'));
      emit(ChatLoaded(messages));
    }
  }

  Future<void> sendImage({
    required String currentUserId,
    required String receiverId,
    required String filePath,
  }) {
    return _sendMedia(
      currentUserId: currentUserId,
      receiverId: receiverId,
      filePath: filePath,
      messageType: MessageType.image,
    );
  }

  Future<void> sendVideo({
    required String currentUserId,
    required String receiverId,
    required String filePath,
  }) {
    return _sendMedia(
      currentUserId: currentUserId,
      receiverId: receiverId,
      filePath: filePath,
      messageType: MessageType.video,
    );
  }

  Future<void> sendAudio({
    required String currentUserId,
    required String receiverId,
    required String filePath,
  }) {
    return _sendMedia(
      currentUserId: currentUserId,
      receiverId: receiverId,
      filePath: filePath,
      messageType: MessageType.audio,
    );
  }

  Future<void> sendDocument({
    required String currentUserId,
    required String receiverId,
    required String filePath,
  }) {
    return _sendMedia(
      currentUserId: currentUserId,
      receiverId: receiverId,
      filePath: filePath,
      messageType: MessageType.document,
    );
  }

  Future<void> _sendMedia({
    required String currentUserId,
    required String receiverId,
    required String filePath,
    required MessageType messageType,
  }) async
  {
    final draft = Message(
      id: uuid.v4(),
      senderId: currentUserId,
      receiverId: receiverId,
      text: '',
      timestamp: DateTime.now(),
      messageType: messageType,
      localPath: filePath,
      fileName: filePath.split(Platform.pathSeparator).last,
      uploadStatus: TransferStatus.inProgress,
      status: MessageStatus.sending,
    );

    final baseMessages = _messagesFromState();
    final optimistic = <Message>[...baseMessages, draft];
    emit(MediaUploading(optimistic, draft.id));
    emit(ChatLoaded(optimistic));

    try {
      Future<void> sender;
      switch (messageType) {
        case MessageType.image:
          sender = messageRepository.sendImageMessage(
            draft,
            filePath: filePath,
            onProgress: (progress) => _emitProgress(draft.id, progress, true),
          );
          break;
        case MessageType.video:
          sender = messageRepository.sendVideoMessage(
            draft,
            filePath: filePath,
            onProgress: (progress) => _emitProgress(draft.id, progress, true),
          );
          break;
        case MessageType.audio:
          sender = messageRepository.sendAudioMessage(
            draft,
            filePath: filePath,
            onProgress: (progress) => _emitProgress(draft.id, progress, true),
          );
          break;
        case MessageType.document:
          sender = messageRepository.sendDocumentMessage(
            draft,
            filePath: filePath,
            onProgress: (progress) => _emitProgress(draft.id, progress, true),
          );
          break;
        case MessageType.text:
          sender = messageRepository.sendMessage(draft);
          break;
      }
      await sender;

      final success = _replaceMessageById(
        draft.id,
        (m) => m.copyWith(
          uploadStatus: TransferStatus.success,
          uploadProgress: 1,
          status: MessageStatus.sent,
        ),
      );
      emit(MediaUploadSuccess(success, draft.id));
      emit(ChatLoaded(success));
    } catch (e) {
      final failed = _replaceMessageById(
        draft.id,
        (m) => m.copyWith(
          uploadStatus: TransferStatus.failed,
          status: MessageStatus.sending,
        ),
      );
      emit(MediaUploadFailed(failed, draft.id, e.toString()));
      emit(ChatLoaded(failed));
    }
  }

  Future<void> retryUpload({
    required Message message,
    required String filePath,
  }) async {
    final working = _replaceMessageById(
      message.id,
      (m) => m.copyWith(
        uploadStatus: TransferStatus.inProgress,
        uploadProgress: 0,
      ),
    );
    emit(MediaUploading(working, message.id));
    emit(ChatLoaded(working));

    try {
      await messageRepository.retryUpload(
        message,
        filePath: filePath,
        onProgress: (progress) => _emitProgress(message.id, progress, true),
      );
      final success = _replaceMessageById(
        message.id,
        (m) =>
            m.copyWith(uploadStatus: TransferStatus.success, uploadProgress: 1),
      );
      emit(MediaUploadSuccess(success, message.id));
      emit(ChatLoaded(success));
    } catch (e) {
      final failed = _replaceMessageById(
        message.id,
        (m) => m.copyWith(uploadStatus: TransferStatus.failed),
      );
      emit(MediaUploadFailed(failed, message.id, e.toString()));
      emit(ChatLoaded(failed));
    }
  }

  Future<void> cancelUpload(String messageId) async {
    await messageRepository.cancelUpload(messageId);
    final canceled = _replaceMessageById(
      messageId,
      (m) => m.copyWith(uploadStatus: TransferStatus.canceled),
    );
    emit(ChatLoaded(canceled));
  }

  Future<String> openMedia(Message message) async {
    final downloading = _replaceMessageById(
      message.id,
      (m) => m.copyWith(
        downloadStatus: TransferStatus.inProgress,
        downloadProgress: 0,
      ),
    );
    emit(ChatLoaded(downloading));
    final local = await messageRepository.getOrDownloadMedia(
      message,
      onProgress: (progress) => _emitProgress(message.id, progress, false),
    );
    final done = _replaceMessageById(
      message.id,
      (m) => m.copyWith(
        localPath: local,
        downloadStatus: TransferStatus.success,
        downloadProgress: 1,
      ),
    );
    emit(ChatLoaded(done));
    return local;
  }

  Future<void> updateMessage({
    required String messageId,
    required String newText,
  }) async {
    if (_chatId == null) return;
    try {
      final current = _messagesFromState();
      final message = current.firstWhere((m) => m.id == messageId);
      final updated = message.copyWith(text: newText, editedAt: DateTime.now());
      await messageRepository.updateMessage(_chatId!, updated);
      final updatedMessages = current
          .map((m) => m.id == messageId ? updated : m)
          .toList();
      emit(MessageUpdated(updatedMessages));
      emit(ChatLoaded(updatedMessages));
    } catch (e) {
      emit(ChatError('Failed to update message: $e'));
      emit(ChatLoaded(_messagesFromState()));
    }
  }

  Future<void> deleteMessage({required String messageId}) async {
    if (_chatId == null) return;
    try {
      final current = _messagesFromState();
      await messageRepository.deleteMessage(_chatId!, messageId);
      final updatedMessages = current.where((m) => m.id != messageId).toList();
      emit(MessageDeleted(updatedMessages));
      emit(ChatLoaded(updatedMessages));
    } catch (e) {
      emit(ChatError('Failed to delete message: $e'));
      emit(ChatLoaded(_messagesFromState()));
    }
  }

  void _emitProgress(String messageId, double progress, bool isUpload) {
    final updated = _replaceMessageById(
      messageId,
      (m) => isUpload
          ? m.copyWith(
              uploadProgress: progress,
              uploadStatus: TransferStatus.inProgress,
            )
          : m.copyWith(
              downloadProgress: progress,
              downloadStatus: TransferStatus.inProgress,
            ),
    );
    emit(
      MediaProgressChanged(
        messages: updated,
        messageId: messageId,
        progress: progress,
        isUpload: isUpload,
      ),
    );
    emit(ChatLoaded(updated));
  }

  List<Message> _messagesFromState() {
    final current = state;
    if (current is ChatLoaded) return current.messages;
    if (current is MessageSent) return current.messages;
    if (current is MessageSending) return current.messages;
    if (current is MessageUpdated) return current.messages;
    if (current is MessageDeleted) return current.messages;
    if (current is MediaUploading) return current.messages;
    if (current is MediaUploadSuccess) return current.messages;
    if (current is MediaUploadFailed) return current.messages;
    if (current is MediaProgressChanged) return current.messages;
    return <Message>[];
  }

  List<Message> _replaceMessageById(
    String messageId,
    Message Function(Message message) transform,
  ) {
    return _messagesFromState()
        .map((m) => m.id == messageId ? transform(m) : m)
        .toList();
  }

  bool _hasConnection(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    if (result is List<ConnectivityResult>) {
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    }
    return true;
  }

  void resetChat() {
    _messagesSub?.cancel();
    _messagesSub = null;
    _chatId = null;
    emit(const ChatInitial());
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    await _connectivitySub?.cancel();
    return super.close();
  }
}
