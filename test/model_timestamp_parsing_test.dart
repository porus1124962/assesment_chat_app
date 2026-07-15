import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assesment_chat_app/data/models/message_model.dart';
import 'package:assesment_chat_app/data/models/user_model.dart';

void main() {
  group('Timestamp parsing', () {
    test('parses Firestore timestamps in message model', () {
      final message = MessageModel.fromJson({
        'id': 'msg-1',
        'senderId': 'user-1',
        'receiverId': 'user-2',
        'text': 'hello',
        'timestamp': Timestamp.fromDate(DateTime(2026, 7, 15, 5, 4, 35)),
        'editedAt': Timestamp.fromDate(DateTime(2026, 7, 15, 5, 5, 35)),
        'status': 1,
        'isDeleted': false,
      });

      expect(message.timestamp, DateTime(2026, 7, 15, 5, 4, 35));
      expect(message.editedAt, DateTime(2026, 7, 15, 5, 5, 35));
    });

    test('parses Firestore timestamps in user model', () {
      final user = UserModel.fromJson({
        'id': 'user-1',
        'email': 'user@example.com',
        'name': 'User',
        'profilePictureUrl': null,
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 15, 5, 4, 35)),
        'lastSeenAt': Timestamp.fromDate(DateTime(2026, 7, 15, 5, 5, 35)),
      });

      expect(user.createdAt, DateTime(2026, 7, 15, 5, 4, 35));
      expect(user.lastSeenAt, DateTime(2026, 7, 15, 5, 5, 35));
    });
  });
}
