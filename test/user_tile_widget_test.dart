import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assesment_chat_app/domain/entities/user.dart';
import 'package:assesment_chat_app/presentation/widgets/user_tile.dart';

void main() {
  group('UserTile Widget Tests', () {
    final testUser = User(
      id: 'user-1',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: DateTime.now(),
    );

    testWidgets('displays user name and avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTile(
              user: testUser,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays no messages text when no last message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTile(
              user: testUser,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('calls onTap when user tile is tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTile(
              user: testUser,
              onTap: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(wasPressed, true);
    });

    testWidgets('avatar shows first letter of name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTile(
              user: testUser,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('T'), findsWidgets);
    });
  });
}
