import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assesment_chat_app/domain/entities/message.dart';
import 'package:assesment_chat_app/presentation/widgets/message_bubble.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    final testMessage = Message(
      id: 'msg-1',
      senderId: 'user-1',
      receiverId: 'user-2',
      text: 'Hello, this is a test message',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    testWidgets('renders sent message with blue background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              isSent: true,
            ),
          ),
        ),
      );

      expect(find.text('Hello, this is a test message'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders received message with gray background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              isSent: false,
            ),
          ),
        ),
      );

      expect(find.text('Hello, this is a test message'), findsOneWidget);
    });

    testWidgets('shows edited indicator when message is edited', (WidgetTester tester) async {
      final editedMessage = testMessage.copyWith(
        editedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: editedMessage,
              isSent: true,
            ),
          ),
        ),
      );

      expect(find.text('(edited)'), findsOneWidget);
    });

    testWidgets('shows read indicator for read messages', (WidgetTester tester) async {
      final readMessage = testMessage.copyWith(
        status: MessageStatus.read,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: readMessage,
              isSent: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });
  });
}
