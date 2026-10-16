import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/features/common/view/error_screen.dart';

void main() {
  testWidgets('ErrorScreen renders message correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ErrorScreen(message: '/test-route'),
      ),
    );

    expect(find.text('No route defined for /test-route'), findsOneWidget);
  });
}
