import 'package:better_player/better_player.dart';
import 'package:better_player/src/controls/better_player_cupertino_progress_bar.dart';
import 'package:better_player/src/controls/better_player_material_progress_bar.dart';
import 'package:better_player/src/core/better_player_with_controls.dart';
import 'package:better_player/src/video_player/video_player_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'better_player_mock_controller.dart';
import 'mock_video_player_controller.dart';

void main() {
  late BetterPlayerMockController _mockController;
  late MockVideoPlayerController _mockVideoPlayerController;

  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  setUp(() {
    _mockController =
        BetterPlayerMockController(const BetterPlayerConfiguration());
    _mockVideoPlayerController = MockVideoPlayerController();
  });

  testWidgets(
    "One of children is BetterPlayerWithControls",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWidget(
          BetterPlayer(
            controller: _mockController,
          ),
        ),
      );
      expect(
          find.byWidgetPredicate(
              (widget) => widget is BetterPlayerWithControls),
          findsOneWidget);
    },
  );

  testWidgets(
    "Cupertino progress bar renders without RRect NaN error on zero duration or uninitialized state",
    (WidgetTester tester) async {
      _mockVideoPlayerController.value = VideoPlayerValue.uninitialized();

      await tester.pumpWidget(
        _wrapWidget(
          SizedBox(
            width: 300,
            height: 40,
            child: BetterPlayerCupertinoVideoProgressBar(
              _mockVideoPlayerController,
              _mockController,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // Now set initialized with zero duration (triggers potential 0 / 0 NaN)
      _mockVideoPlayerController.value = VideoPlayerValue(
        duration: Duration.zero,
        position: Duration.zero,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "Material progress bar renders without RRect NaN error on zero duration or uninitialized state",
    (WidgetTester tester) async {
      _mockVideoPlayerController.value = VideoPlayerValue.uninitialized();

      await tester.pumpWidget(
        _wrapWidget(
          SizedBox(
            width: 300,
            height: 40,
            child: BetterPlayerMaterialVideoProgressBar(
              _mockVideoPlayerController,
              _mockController,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // Now set initialized with zero duration (triggers potential 0 / 0 NaN)
      _mockVideoPlayerController.value = VideoPlayerValue(
        duration: Duration.zero,
        position: Duration.zero,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}

///Wrap widget with material app to handle all features like navigation and
///localization properly.
Widget _wrapWidget(Widget widget) {
  return MaterialApp(home: widget);
}
