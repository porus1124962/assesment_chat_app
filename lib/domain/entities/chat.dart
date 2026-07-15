import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final int? lastMessageStatus;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const ChatEntity({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageStatus,
    this.updatedAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    participants,
    lastMessage,
    lastMessageSenderId,
    lastMessageStatus,
    updatedAt,
    createdAt,
  ];

  ChatEntity copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageSenderId,
    int? lastMessageStatus,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageStatus: lastMessageStatus ?? this.lastMessageStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
