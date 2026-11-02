import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greatingcard/greeting.dart';
import 'package:greatingcard/main.dart';

void main() {
  testWidgets('Compose form is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const GreetingCardApp());

    expect(find.text('Greeting Card'), findsOneWidget);
    expect(find.text('Send greeting'), findsOneWidget);
    expect(find.text('Your email'), findsOneWidget);
    expect(find.text('Recipient email'), findsOneWidget);
  });

  testWidgets('Send greeting opens share page and accept reveals message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GreetingCardApp());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Greeting message'),
      'Happy birthday!',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Your email'),
      'sender@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Recipient email'),
      'friend@example.com',
    );
    await tester.tap(find.text('Send greeting'));
    await tester.pumpAndSettle();

    expect(find.textContaining('email is not sent'), findsOneWidget);
    expect(find.textContaining('friend@example.com'), findsWidgets);

    await tester.tap(find.text('Preview recipient view'));
    await tester.pumpAndSettle();

    expect(find.text('A greeting is waiting'), findsOneWidget);
    await tester.tap(find.text('Accept greeting'));
    await tester.pumpAndSettle();

    expect(find.text('Happy birthday!'), findsOneWidget);
    expect(find.text('From sender@example.com'), findsOneWidget);
  });

  test('payload round-trips greeting data', () {
    const greeting = Greeting(
      message: 'Hello',
      senderEmail: 'a@b.com',
      recipientEmail: 'c@d.com',
    );
    final decoded = Greeting.fromPayload(greeting.toPayload());
    expect(decoded?.message, 'Hello');
    expect(decoded?.senderEmail, 'a@b.com');
    expect(decoded?.recipientEmail, 'c@d.com');
  });
}
