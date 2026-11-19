import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:only_dev_app/widgets/textfield/ios_style_text_field.dart';

/// Drives a real caret drag on a simulator/device so the Flutter loupe can be
/// screen-recorded and compared with a native UITextField.
///   flutter test integration_test/app_text_loupe_drag_test.dart -d <device>
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('drag caret with AppTextLoupe', (tester) async {
    final controller = TextEditingController(text: 'Hello native loupe');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            child: IosStyleTextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));

    final field = tester.getRect(find.byType(TextField));
    final start = Offset(field.left + 40, field.center.dy);
    final gesture = await tester.startGesture(start,
        kind: PointerDeviceKind.touch, pointer: 42);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));

    // Sweep right (past the end of the text), then back left, ~60 Hz.
    Future<void> sweep(double dx, int steps) async {
      for (var i = 0; i < steps; i++) {
        await gesture.moveBy(Offset(dx / steps, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await sweep(field.width - 60, 90);
    await tester.pump(const Duration(milliseconds: 500));
    await sweep(-(field.width - 80), 90);
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
  });

  // iOS-style editing on Android: tap to focus an empty field (like the
  // Search screen), then long-press and drag. The caret should ride in the
  // loupe with the floating cursor instead of selecting a word.
  testWidgets('long-press drag caret in empty field', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 140, 16, 0),
            child: IosStyleTextField(
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));

    final Rect field = tester.getRect(find.byType(IosStyleTextField));
    await tester.tapAt(field.center);
    await tester.pump(const Duration(seconds: 1));

    final Offset start = Offset(field.left + 30, field.center.dy);
    final gesture = await tester.startGesture(start,
        kind: PointerDeviceKind.touch, pointer: 43);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));
    Future<void> sweep(double dx, int steps) async {
      for (var i = 0; i < steps; i++) {
        await gesture.moveBy(Offset(dx / steps, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await sweep(field.width - 80, 90);
    await tester.pump(const Duration(milliseconds: 500));
    await sweep(-(field.width - 120), 90);
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
  });
}
