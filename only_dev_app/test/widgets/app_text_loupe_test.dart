import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/textfield/app_text_loupe.dart';

MagnifierInfo info(Offset gesture, {double caretX = 60}) => MagnifierInfo(
      globalGesturePosition: gesture,
      currentLineBoundaries: const Rect.fromLTRB(20, 300, 150, 320),
      caretRect: Rect.fromLTWH(caretX, 300, 2, 20),
      fieldBounds: const Rect.fromLTRB(16, 290, 374, 330),
    );

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('geometry', () {
    test('focal point follows finger past end of text, clamped to field', () {
      expect(AppTextLoupe.focalPointFor(info(const Offset(250, 305))),
          const Offset(250, 310));
      expect(AppTextLoupe.focalPointFor(info(const Offset(999, 305))),
          const Offset(374, 310));
    });

    test('open loupe sits 8pt above the caret, centred on the finger', () {
      final Rect r = AppTextLoupe.openRectFor(
          const Offset(200, 310), 20, const Size(400, 800));
      expect(r.size, AppTextLoupe.loupeSize);
      expect(r.center.dx, 200);
      expect(r.bottom, 300 - AppTextLoupe.gapAboveCaret);
    });

    test('open loupe stays inside the screen edge padding', () {
      final Rect r = AppTextLoupe.openRectFor(
          const Offset(2, 310), 20, const Size(400, 800));
      expect(r.left, AppTextLoupe.edgePadding);
    });
  });

  group('animation', () {
    late MagnifierController controller;
    late ValueNotifier<MagnifierInfo> notifier;

    Future<void> pumpLoupe(WidgetTester tester) async {
      controller = MagnifierController();
      notifier = ValueNotifier<MagnifierInfo>(info(const Offset(100, 305)));
      late BuildContext appContext;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          appContext = context;
          return const SizedBox.expand();
        }),
      ));
      // Same path as TextSelectionOverlay.showMagnifier.
      controller.show(
        context: appContext,
        builder: (_) =>
            AppTextLoupe(controller: controller, magnifierInfo: notifier),
      );
      await tester.pump();
    }

    Rect loupeRect(WidgetTester tester) =>
        tester.getRect(find.byType(RawMagnifier));

    testWidgets('opens from a caret pill into the full loupe in ~230ms',
        (tester) async {
      await pumpLoupe(tester);
      await tester.pump(const Duration(milliseconds: 1));
      final Rect start = loupeRect(tester);
      expect(start.width, closeTo(AppTextLoupe.liftWidth, 2));
      expect(start.center.dx, closeTo(100, 0.5));

      await tester.pump(AppTextLoupe.openDuration);
      final Rect open = loupeRect(tester);
      expect(open.size, AppTextLoupe.loupeSize);
      expect(open.bottom, 300 - AppTextLoupe.gapAboveCaret);
    });

    testWidgets('glides after the finger instead of jumping', (tester) async {
      await pumpLoupe(tester);
      await tester.pumpAndSettle();
      expect(loupeRect(tester).center.dx, closeTo(100, 0.5));

      notifier.value = info(const Offset(200, 305));
      await tester.pump(); // ticker starts
      await tester.pump(const Duration(milliseconds: 16));
      final double afterOneFrame = loupeRect(tester).center.dx;
      expect(afterOneFrame, greaterThan(100));
      expect(afterOneFrame, lessThan(150)); // eased, not a jump

      await tester.pumpAndSettle();
      expect(loupeRect(tester).center.dx, closeTo(200, 0.5));
    });

    testWidgets('hide shrinks back into the caret in ~100ms', (tester) async {
      await pumpLoupe(tester);
      await tester.pumpAndSettle();

      final Future<void> hidden = controller.hide(removeFromOverlay: false);
      await tester.pump(); // reverse starts on the next frame
      await tester.pump(const Duration(milliseconds: 50));
      final Rect mid = loupeRect(tester);
      expect(mid.width, lessThan(AppTextLoupe.loupeSize.width));
      expect(mid.width, greaterThan(AppTextLoupe.liftWidth));

      await tester.pump(AppTextLoupe.closeDuration);
      await hidden;
      expect(find.byType(RawMagnifier), findsNothing);
    });
  });

  testWidgets('configuration: AppTextLoupe on both iOS and Android',
      (tester) async {
    for (final TargetPlatform platform in <TargetPlatform>[
      TargetPlatform.iOS,
      TargetPlatform.android,
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      late Widget? built;
      await tester.pumpWidget(Builder(builder: (context) {
        built = AppTextLoupe.configuration.magnifierBuilder(
          context,
          MagnifierController(),
          ValueNotifier(MagnifierInfo.empty),
        );
        return const SizedBox();
      }));
      expect(built, isA<AppTextLoupe>(), reason: '$platform');
    }
    debugDefaultTargetPlatformOverride = null;
  });

  test('closes when the finger is dragged far below the line (iOS rule)', () {
    // 40pt below the line: still moving the caret.
    expect(AppTextLoupe.shouldHideFor(info(const Offset(100, 350))), isFalse);
    // 90pt below the line: close.
    expect(AppTextLoupe.shouldHideFor(info(const Offset(100, 400))), isTrue);
  });
}
