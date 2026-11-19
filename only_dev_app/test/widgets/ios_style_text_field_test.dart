import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/textfield/app_text_loupe.dart';
import 'package:only_dev_app/widgets/textfield/ios_style_text_field.dart';
import 'package:only_dev_app/widgets/textfield/ios_style_text_form_field.dart';
import 'package:only_dev_app/widgets/textfield/ios_style_text_selection.dart';

/// Flutter tests run as Android by default, so these prove Android gets iOS
/// editing.
void main() {

  Future<TextEditingController> pumpField(WidgetTester tester) async {
    final controller = TextEditingController(text: 'Hello world');
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Center(
          child: SizedBox(
            width: 300,
            child: IosStyleTextField(controller: controller),
          ),
        ),
      ),
    ));
    return controller;
  }

  Offset charPosition(WidgetTester tester, int offset) {
    final EditableTextState state =
        tester.state<EditableTextState>(find.byType(EditableText));
    final Rect caret =
        state.renderEditable.getLocalRectForCaret(TextPosition(offset: offset));
    return state.renderEditable.localToGlobal(caret.center);
  }

  test('emulates iOS on Android only', () {
    expect(defaultTargetPlatform, TargetPlatform.android);
    expect(IosStyleTextSelectionGestureDetectorBuilder.emulatesIos, isTrue);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(IosStyleTextSelectionGestureDetectorBuilder.emulatesIos, isFalse);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
      'iOS look on Android: Cupertino handles, iOS cursor, AppTextLoupe',
      (tester) async {
    await pumpField(tester);
    final EditableText editable =
        tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.selectionControls,
        isA<CupertinoTextSelectionControls>());
    expect(editable.cursorOpacityAnimates, isTrue);
    expect(editable.paintCursorAboveText, isTrue);
    expect(editable.cursorRadius, const Radius.circular(2));
    final Widget? loupe = editable.magnifierConfiguration.magnifierBuilder(
      tester.element(find.byType(EditableText)),
      MagnifierController(),
      ValueNotifier(MagnifierInfo.empty),
    );
    expect(loupe, isA<AppTextLoupe>());
  });

  testWidgets('tap moves the caret to the word edge (iOS), not mid-word',
      (tester) async {
    final controller = await pumpField(tester);
    // Tap between "He" and "llo".
    await tester.tapAt(charPosition(tester, 2));
    await tester.pumpAndSettle();
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection.baseOffset, anyOf(0, 5));
  });

  testWidgets('long-press drag moves the caret with the loupe (iOS)',
      (tester) async {
    final controller = await pumpField(tester);
    await tester.tapAt(charPosition(tester, 11)); // focus, caret at end
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    final TestGesture gesture =
        await tester.startGesture(charPosition(tester, 2));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    // iOS: caret placed at the finger — Android would select "Hello".
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection.baseOffset, 2);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppTextLoupe), findsOneWidget);

    await gesture.moveTo(charPosition(tester, 8));
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection.baseOffset, 8);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(AppTextLoupe), findsNothing);
    expect(controller.selection, const TextSelection.collapsed(offset: 8));
  });

  testWidgets('IosStyleTextFormField validates like TextFormField',
      (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Form(
          key: key,
          child: IosStyleTextFormField(
            validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      ),
    ));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
    expect(find.byType(IosStyleTextField), findsOneWidget);
  });
}
