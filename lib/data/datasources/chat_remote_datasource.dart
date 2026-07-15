import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/constants.dart';

abstract class ChatRemoteDataSource {
  /// Stream of chats where [userId] is a participant
  Stream<List<ChatModel>> getUserChatsStream(String userId);

  /// Ensure a chat document exists for the two users
  Future<void> createChat(String user1, String user2);

  /// Deterministic chat id for two users (sorted join). Creates the chat doc if it does not exist.
  Future<String> getOrCreateChatId(String user1, String user2);

  /// Message-level operations
  Stream<List<MessageModel>> getMessagesStream(String userId1, String userId2);
  Future<void> sendMessage(MessageModel message);
  Future<void> updateMessage(String chatId, String messageId, String newText);
  Future<void> deleteMessage(String chatId, String messageId);

  /// Return list of other userIds who have exchanged messages with given user
  Future<List<String>> getChatPartners(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;

  ChatRemoteDataSourceImpl({required this.firebaseFirestore});

  String _deterministicChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Future<String> getOrCreateChatId(String user1, String user2) async {
    final chatId = _deterministicChatId(user1, user2);
    final docRef = firebaseFirestore.collection(chatsCollection).doc(chatId);

    try {
      final snapshot = await docRef.get().timeout(firestoreTimeout);
      if (!snapshot.exists) {
        final participants = [user1, user2]..sort();
        await docRef
            .set({
              'participants': participants,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(firestoreTimeout);
      }
      return chatId;
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to get/create chat id: ${e.message}');
    } catch (e) {
      throw FirestoreException('Failed to get/create chat id: $e');
    }
  }

  @override
  Future<void> createChat(String user1, String user2) async {
    final chatId = _deterministicChatId(user1, user2);
    final docRef = firebaseFirestore.collection(chatsCollection).doc(chatId);

    try {
      final snapshot = await docRef.get().timeout(firestoreTimeout);
      if (!snapshot.exists) {
        final participants = [user1, user2]..sort();
        await docRef
            .set({
              'participants': participants,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(firestoreTimeout);
      }
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to create chat: ${e.message}');
    } catch (e) {
      throw FirestoreException('Failed to create chat: $e');
    }
  }

  @override
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    try {
      final query = firebaseFirestore
          .collection(chatsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('updatedAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => ChatModel.fromMap(
                doc.id,
                Map<String, dynamic>.from(doc.data() as Map),
              ),
            )
            .toList();
      });
    } catch (e) {
      // Wrap synchronous errors
      throw FirestoreException('Failed to listen to chats: $e');
    }
  }

  Map<String, dynamic> _normalizeMessageData(QueryDocumentSnapshot doc) {
    final raw = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

    // ensure id
    raw['id'] = raw['id'] ?? doc.id;

    // normalize timestamp -> ISO string (MessageModel expects ISO strings)
    final ts = raw['timestamp'];
    if (ts is Timestamp) {
      raw['timestamp'] = ts.toDate().toIso8601String();
    } else if (ts == null) {
      raw['timestamp'] = DateTime.now().toIso8601String();
    }

    final edited = raw['editedAt'];
    if (edited is Timestamp) {
      raw['editedAt'] = edited.toDate().toIso8601String();
    }

    // other fields are expected to already be primitives
    return raw;
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String userId1, String userId2) {
    try {
      final chatId = _deterministicChatId(userId1, userId2);
      final ref = firebaseFirestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .orderBy('timestamp', descending: false);

      return ref.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromJson(_normalizeMessageData(doc)))
            .toList();
      });
    } catch (e) {
      throw FirestoreException('Failed to get messages stream: $e');
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    final chatId = _deterministicChatId(message.senderId, message.receiverId);
    final chatRef = firebaseFirestore.collection(chatsCollection).doc(chatId);
    final msgRef = chatRef.collection(messagesSubcollection).doc(message.id);

    final participants = [message.senderId, message.receiverId]..sort();

    final messageData = <String, dynamic>{
      'id': message.id,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'text': message.text,
      'timestamp': FieldValue.serverTimestamp(),
      'status': message.status,
      'editedAt': message.editedAt == null
          ? null
          : FieldValue.serverTimestamp(),
      'isDeleted': message.isDeleted,
    };

    final chatUpdate = <String, dynamic>{
      'participants': participants,
      'lastMessage': message.text,
      'lastMessageSenderId': message.senderId,
      'lastMessageStatus': message.status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = firebaseFirestore.batch();
    batch.set(msgRef, messageData);
    batch.set(chatRef, chatUpdate, SetOptions(merge: true));

    try {
      await batch.commit().timeout(firestoreTimeout);
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to send message: ${e.message}');
    } catch (e) {
      throw FirestoreException('Failed to send message: $e');
    }
  }

  @override
  Future<void> updateMessage(
    String chatId,
    String messageId,
    String newText,
  ) async {
    try {
      final msgRef = firebaseFirestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .doc(messageId);

      await msgRef
          .update({'text': newText, 'editedAt': FieldValue.serverTimestamp()})
          .timeout(firestoreTimeout);

      // Optionally update chat's lastMessage/updatedAt if this message is the last one - omitted for simplicity
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to update message: ${e.message}');
    } catch (e) {
      throw FirestoreException('Failed to update message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final msgRef = firebaseFirestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .doc(messageId);

      await msgRef
          .update({
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          })
          .timeout(firestoreTimeout);
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to delete message: ${e.message}');
    } catch (e) {
      throw FirestoreException('Failed to delete message: $e');
    }
  }

  @override
  Future<List<String>> getChatPartners(String userId) async {
    try {
      final Set<String> partners = {};

      final query = firebaseFirestore
          .collection(chatsCollection)
          .where('participants', arrayContains: userId);

      final snapshot = await query.get().timeout(firestoreTimeout);

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final participants =
            (data['participants'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        for (final p in participants) {
          if (p != userId) partners.add(p);
        }
      }

      return partners.toList();
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to fetch chat partners: ${e.message}');
    } catch (e) {
      throw FirestoreException('Failed to fetch chat partners: $e');
    }
  }
}
