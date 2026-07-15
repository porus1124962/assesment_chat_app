// This is a smoke test for the Flutter app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assesment_chat_app/app.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChatApp());
    await tester.pumpAndSettle();

    // Verify the app renders without crashing
    expect(find.byType(ChatApp), findsOneWidget);
  });
}
