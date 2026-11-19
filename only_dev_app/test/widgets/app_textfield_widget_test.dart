import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/app_widgets/app_textfield_widget.dart';
import 'package:only_dev_app/widgets/textfield/ios_style_text_form_field.dart';

void main() {
  group('AppTextField Widget Tests', () {
    testWidgets('renders label and required asterisk when isRequired is true',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              labelText: 'First Name',
              isRequired: true,
              hintText: 'Enter your first name',
            ),
          ),
        ),
      );

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('Enter your first name'), findsOneWidget);
    });

    testWidgets('renders input text and triggers onChanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String changedValue = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              labelText: 'Email',
              onChanged: (val) => changedValue = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(IosStyleTextFormField), 'test@onlydev.com');
      await tester.pump();

      expect(controller.text, equals('test@onlydev.com'));
      expect(changedValue, equals('test@onlydev.com'));
    });

    testWidgets('toggles password visibility with built-in suffix icon',
        (tester) async {
      final controller = TextEditingController(text: 'secret123');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              labelText: 'Password',
              isPassword: true,
            ),
          ),
        ),
      );

      // Initially password is obscured
      final editableTextFinder = find.byType(EditableText);
      final editableText = tester.widget<EditableText>(editableTextFinder);
      expect(editableText.obscureText, isTrue);

      // Suffix button shows visibility_off icon when password is obscured
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      final updatedEditableText =
          tester.widget<EditableText>(editableTextFinder);
      expect(updatedEditableText.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('supports multi-line textarea with maxLength', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              labelText: 'Bio',
              hintText: 'Tell us about yourself...',
              maxLines: 4,
              maxLength: 100,
            ),
          ),
        ),
      );

      expect(find.text('Bio'), findsOneWidget);
      expect(find.text('Tell us about yourself...'), findsOneWidget);
      expect(find.text('0/100'), findsOneWidget);

      await tester.enterText(
          find.byType(IosStyleTextFormField), 'Hello world from Only Dev!');
      await tester.pump();

      expect(find.text('26/100'), findsOneWidget);
    });

    testWidgets('displays form validation error correctly', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                controller: controller,
                labelText: 'Username',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Username is required'), findsNothing);

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
    });

    testWidgets('supports borderless search style with prefix icon',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              hintText: 'Search courses...',
              prefixIcon: Icons.search,
              borderless: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search courses...'), findsOneWidget);
    });
  });
}
