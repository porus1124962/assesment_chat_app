import '../../domain/entities/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required String id,
    required List<String> participants,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) : super(
          id: id,
          participants: participants,
          lastMessage: lastMessage,
          lastMessageSenderId: lastMessageSenderId,
          updatedAt: updatedAt,
          createdAt: createdAt,
        );

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    final updated = map['updatedAt'];
    final created = map['createdAt'];

    DateTime? updatedAt;
    DateTime? createdAt;
    if (updated is Timestamp) updatedAt = updated.toDate();
    if (updated is String) updatedAt = DateTime.tryParse(updated);
    if (created is Timestamp) createdAt = created.toDate();
    if (created is String) createdAt = DateTime.tryParse(created);

    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      updatedAt: updatedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ChatEntity toEntity() => this;
}
