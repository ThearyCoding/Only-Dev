import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';

void main() {
  group('AppImageWidget & AppCircleAvatar Unit and Widget Tests', () {
    test('isValidUrl validates correctly', () {
      expect(AppImageWidget.isValidUrl(null), isFalse);
      expect(AppImageWidget.isValidUrl(''), isFalse);
      expect(AppImageWidget.isValidUrl('   '), isFalse);
      expect(AppImageWidget.isValidUrl('not_a_url'), isFalse);
      expect(AppImageWidget.isValidUrl('ftp://example.com/file.png'), isFalse);
      expect(AppImageWidget.isValidUrl('http://'), isFalse);
      expect(AppImageWidget.isValidUrl('https://'), isFalse);

      expect(AppImageWidget.isValidUrl('https://example.com/image.png'), isTrue);
      expect(AppImageWidget.isValidUrl('http://localhost:4000/image.jpg'), isTrue);
      expect(AppImageWidget.isValidUrl(' https://example.com/avatar.jpg '), isTrue);
    });

    test('safeNetworkImageProvider returns null for invalid URLs', () {
      expect(AppImageWidget.safeNetworkImageProvider(null), isNull);
      expect(AppImageWidget.safeNetworkImageProvider(''), isNull);
      expect(AppImageWidget.safeNetworkImageProvider('  '), isNull);
      expect(AppImageWidget.safeNetworkImageProvider('invalid-uri'), isNull);

      final provider = AppImageWidget.safeNetworkImageProvider('https://example.com/test.png');
      expect(provider, isNotNull);
    });

    testWidgets('AppCircleAvatar renders initials without throwing when imageUrl is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCircleAvatar(
              imageUrl: '',
              name: 'John Doe',
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('AppCircleAvatar renders fallback question mark when name and url are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCircleAvatar(
              imageUrl: '',
              name: '',
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('AppImageWidget renders fallback icon when imageUrl is invalid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppImageWidget(
              imageUrl: '',
              width: 100,
              height: 100,
              fallbackIcon: Icons.campaign_outlined,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);
    });
  });
}

