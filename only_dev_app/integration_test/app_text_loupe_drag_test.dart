import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:only_dev_app/widgets/textfield/app_text_loupe.dart';

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
            child: TextField(
              controller: controller,
              autofocus: true,
              magnifierConfiguration: AppTextLoupe.configuration,
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
}
