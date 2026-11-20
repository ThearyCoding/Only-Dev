import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Flutter-drawn text loupe, used on both iOS and Android, styled after the
/// iOS 17+/18 system loupe.
///
/// All constants were measured frame-by-frame from screen recordings of the
/// native Messages text field on an iPhone 16 Plus simulator (iOS 18.6):
///
/// * open: a caret-sized pill lifts and expands into the loupe (~230 ms),
///   tinted at first and clearing as it opens;
/// * follow: the loupe glides after the finger with an eased (exponential)
///   catch-up instead of jumping;
/// * close: the loupe shrinks back into the caret (~100 ms).
///
/// Plugs into [TextMagnifierConfiguration.magnifierBuilder] like
/// [CupertinoTextMagnifier]: it hands its in/out [AnimationController] to the
/// [MagnifierController], so `show()` / `hide()` play these animations.
class AppTextLoupe extends StatefulWidget {
  const AppTextLoupe({
    super.key,
    required this.controller,
    required this.magnifierInfo,
  });

  final MagnifierController controller;
  final ValueNotifier<MagnifierInfo> magnifierInfo;

  /// Loupe size, ring included. Measured 345x255 px on a 3x (1290 px wide)
  /// recording of the system loupe = 115x85 pt; cross-checked against the
  /// Messages recording (81x58 px on a 301 px = 430 pt wide screen).
  static const Size loupeSize = Size(115, 84);

  /// Gap between the loupe's bottom edge and the top of the caret.
  static const double gapAboveCaret = 10;

  /// Width of the lifted caret pill the loupe grows out of; its height is
  /// the caret height scaled by [liftHeightFactor].
  static const double liftWidth = 24;
  static const double liftHeightFactor = 1.25;

  /// Caret measured 22 px in the field vs. 27 px inside the loupe.
  static const double magnification = 1.25;
  static const double borderWidth = 2;
  static const double edgePadding = 10;

  /// Max tint alpha at the very start of open / end of close.
  static const double maxTint = 0.35;

  static const Duration openDuration = Duration(milliseconds: 230);
  static const Duration closeDuration = Duration(milliseconds: 100);

  /// Time constant of the follow glide; ~95% caught up after 150 ms.
  static const double followTimeConstantSeconds = 0.05;

  /// Hide when the finger is dragged this far below the current line
  /// (same rule as UIKit / CupertinoTextMagnifier).
  static const double hideBelowThreshold = 48;

  /// Use [AppTextLoupe] on every platform (it is drawn by Flutter, not the
  /// OS), so iOS and Android share the same loupe look and animations.
  static final TextMagnifierConfiguration configuration =
      TextMagnifierConfiguration(
    magnifierBuilder: (
      BuildContext context,
      MagnifierController controller,
      ValueNotifier<MagnifierInfo> magnifierInfo,
    ) =>
        AppTextLoupe(controller: controller, magnifierInfo: magnifierInfo),
  );

  /// Whether the loupe should close because the finger left the line.
  ///
  /// iOS rule, applied on every platform: AppTextField gives Android iOS-style
  /// gestures (no teardrop handle hanging below the text), so the finger is
  /// on the line while moving the caret, as on iOS.
  @visibleForTesting
  static bool shouldHideFor(MagnifierInfo info) {
    final double belowLine =
        info.globalGesturePosition.dy - info.caretRect.center.dy;
    return belowLine > hideBelowThreshold;
  }

  /// The point being magnified: follows the finger horizontally (clamped to
  /// the field, like UITextView — not to the end of the text), vertically
  /// centred on the caret's line.
  @visibleForTesting
  static Offset focalPointFor(MagnifierInfo info) {
    final Rect field = info.fieldBounds;
    final double gestureX = info.globalGesturePosition.dx;
    final double x =
        field.width > 0 ? gestureX.clamp(field.left, field.right) : gestureX;
    final double y = info.caretRect.height > 0
        ? info.caretRect.center.dy
        : info.globalGesturePosition.dy;
    return Offset(x, y);
  }

  /// Fully-open loupe rect for a focal point on a line of [caretHeight],
  /// kept inside the screen's horizontal padding.
  @visibleForTesting
  static Rect openRectFor(Offset focal, double caretHeight, Size screen) {
    final double caretTop = focal.dy - caretHeight / 2;
    final Rect raw = Rect.fromLTWH(
      focal.dx - loupeSize.width / 2,
      caretTop - gapAboveCaret - loupeSize.height,
      loupeSize.width,
      loupeSize.height,
    );
    const double minLeft = edgePadding;
    final double maxLeft = screen.width - edgePadding - loupeSize.width;
    if (maxLeft < minLeft) return raw;
    return raw.shift(Offset(raw.left.clamp(minLeft, maxLeft) - raw.left, 0));
  }

  /// The caret-sized pill the loupe opens from and closes into.
  @visibleForTesting
  static Rect liftRectFor(Offset focal, double caretHeight) => Rect.fromCenter(
        center: focal,
        width: liftWidth,
        height: caretHeight * liftHeightFactor,
      );

  @override
  State<AppTextLoupe> createState() => _AppTextLoupeState();
}

class _AppTextLoupeState extends State<AppTextLoupe>
    with TickerProviderStateMixin {
  late final AnimationController _io;
  late final CurvedAnimation _ioCurve;
  late final Ticker _followTicker;

  /// Where the loupe is heading (latest gesture) vs. where it is drawn.
  final ValueNotifier<Offset?> _target = ValueNotifier<Offset?>(null);
  final ValueNotifier<Offset?> _focal = ValueNotifier<Offset?>(null);
  double _caretHeight = 20;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _io = AnimationController(
      vsync: this,
      value: 0,
      duration: AppTextLoupe.openDuration,
      reverseDuration: AppTextLoupe.closeDuration,
    );
    _ioCurve = CurvedAnimation(
      parent: _io,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    widget.controller.animationController = _io;
    _followTicker = createTicker(_onFollowTick);
    widget.magnifierInfo.addListener(_onInfoChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onInfoChanged();
  }

  @override
  void didUpdateWidget(AppTextLoupe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.magnifierInfo != widget.magnifierInfo) {
      oldWidget.magnifierInfo.removeListener(_onInfoChanged);
      widget.magnifierInfo.addListener(_onInfoChanged);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.animationController = null;
      widget.controller.animationController = _io;
    }
  }

  void _onInfoChanged() {
    final MagnifierInfo info = widget.magnifierInfo.value;
    if (info == MagnifierInfo.empty) return;

    // Dragged too far below the line: close (but keep the overlay so it can
    // reopen if the finger comes back), like the system loupe.
    if (AppTextLoupe.shouldHideFor(info)) {
      if (widget.controller.shown) {
        widget.controller.hide(removeFromOverlay: false);
      }
      return;
    }
    if (!widget.controller.shown) {
      _io.forward();
    }

    if (info.caretRect.height > 0) _caretHeight = info.caretRect.height;
    _target.value = AppTextLoupe.focalPointFor(info);

    if (_focal.value == null) {
      // First position: appear exactly at the caret, no glide in.
      _focal.value = _target.value;
    } else if (!_followTicker.isActive) {
      _lastTick = Duration.zero;
      _followTicker.start();
    }
  }

  void _onFollowTick(Duration elapsed) {
    final Offset? target = _target.value;
    final Offset? current = _focal.value;
    if (target == null || current == null) {
      _followTicker.stop();
      return;
    }
    final double dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;

    final double k = 1 - math.exp(-dt / AppTextLoupe.followTimeConstantSeconds);
    final Offset next = current + (target - current) * k;
    if ((target - next).distance < 0.25) {
      _focal.value = target;
      _followTicker.stop();
    } else {
      _focal.value = next;
    }
  }

  @override
  void dispose() {
    widget.magnifierInfo.removeListener(_onInfoChanged);
    if (widget.controller.animationController == _io) {
      widget.controller.animationController = null;
    }
    _followTicker.dispose();
    _ioCurve.dispose();
    _io.dispose();
    _focal.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color tint = CupertinoTheme.of(context).primaryColor;
    final Size screen = MediaQuery.sizeOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[_ioCurve, _focal]),
      builder: (BuildContext context, Widget? _) {
        final Offset? focal = _focal.value;
        if (focal == null || _io.value == 0) {
          return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
        }
        final double t = _ioCurve.value;
        final Rect rect = Rect.lerp(
          AppTextLoupe.liftRectFor(focal, _caretHeight),
          AppTextLoupe.openRectFor(focal, _caretHeight, screen),
          t,
        )!;

        return Positioned.fromRect(
          rect: rect,
          child: IgnorePointer(
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                RawMagnifier(
                  size: rect.size,
                  magnificationScale:
                      lerpDouble(1.0, AppTextLoupe.magnification, t)!,
                  // Content under `focal` is drawn at the loupe's centre.
                  focalPointOffset: focal - rect.center,
                  // No `shadows` here: RawMagnifier's shadow leaks into the
                  // lens (~12% black), turning the field behind it grey.
                  // The shadow is painted outside the lens below instead.
                  decoration: MagnifierDecoration(
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: tint,
                        width: AppTextLoupe.borderWidth,
                      ),
                    ),
                  ),
                  child: ColoredBox(
                    color:
                        tint.withValues(alpha: AppTextLoupe.maxTint * (1 - t)),
                  ),
                ),
                // Painted after the magnifier, so its backdrop never sees it.
                Positioned.fill(
                  child: CustomPaint(
                    painter: LoupeOuterShadowPainter(opacity: t),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Soft drop shadow drawn only *outside* the loupe's stadium shape.
///
/// Replaces [MagnifierDecoration.shadows], whose shadow also darkens the
/// inside of the lens. The clip here is a bounded ring (outer rect minus
/// stadium), so the lens interior is never touched.
@visibleForTesting
class LoupeOuterShadowPainter extends CustomPainter {
  LoupeOuterShadowPainter({required this.opacity});

  /// 0..1, follows the open/close animation.
  final double opacity;

  static const double blurRadius = 14;
  static const Offset offset = Offset(0, 3);
  static const double alpha = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final RRect lens =
        RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide / 2));
    final Path outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect.inflate(blurRadius * 3 + offset.distance)),
      Path()..addRRect(lens),
    );
    canvas
      ..save()
      ..clipPath(outside)
      ..drawRRect(
        lens.shift(offset),
        Paint()
          ..color = Colors.black.withValues(alpha: alpha * opacity)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            Shadow.convertRadiusToSigma(blurRadius),
          ),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(LoupeOuterShadowPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
