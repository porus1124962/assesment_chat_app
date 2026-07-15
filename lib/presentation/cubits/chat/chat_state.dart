import 'package:equatable/equatable.dart';
import '../../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatEmpty extends ChatState {
  const ChatEmpty();
}

class MessageSending extends ChatState {
  final List<Message> messages;
  const MessageSending(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ChatState {
  final List<Message> messages;
  const MessageSent(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageUpdated extends ChatState {
  final List<Message> messages;
  const MessageUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageDeleted extends ChatState {
  final List<Message> messages;
  const MessageDeleted(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MediaUploading extends ChatState {
  final List<Message> messages;
  final String messageId;
  const MediaUploading(this.messages, this.messageId);

  @override
  List<Object?> get props => [messages, messageId];
}

class MediaProgressChanged extends ChatState {
  final List<Message> messages;
  final String messageId;
  final double progress;
  final bool isUpload;
  const MediaProgressChanged({
    required this.messages,
    required this.messageId,
    required this.progress,
    required this.isUpload,
  });

  @override
  List<Object?> get props => [messages, messageId, progress, isUpload];
}

class MediaUploadSuccess extends ChatState {
  final List<Message> messages;
  final String messageId;
  const MediaUploadSuccess(this.messages, this.messageId);

  @override
  List<Object?> get props => [messages, messageId];
}

class MediaUploadFailed extends ChatState {
  final List<Message> messages;
  final String messageId;
  final String error;
  const MediaUploadFailed(this.messages, this.messageId, this.error);

  @override
  List<Object?> get props => [messages, messageId, error];
}
