import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single destination in [LiquidGlassNavBar].
class LiquidGlassNavItem {
  const LiquidGlassNavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
    this.badgeCount = 0,
  }) : activeIcon = activeIcon ?? icon;

  /// Shown when not selected (usually the outline variant).
  final IconData icon;

  /// Shown when selected (usually the filled variant).
  final IconData activeIcon;
  final String label;
  final int badgeCount;
}

/// Floating capsule tab bar.
///
/// Tab-change animation:
/// - The new tab switches to its filled icon + accent color instantly.
/// - An accent-tinted pill slides to it with an ease-out (~300ms).
/// - The whole bar zooms up ~4% and settles back while the pill moves.
/// - A system click sound plays.
///
/// Everything runs only for the ~300ms after a tab change — nothing animates
/// while idle or scrolling. Dragging between tabs is intentionally not
/// supported. Turn pieces off with [animate], [playSound] and [blur].
class LiquidGlassNavBar extends StatelessWidget {
  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.trailingIcon,
    this.onTrailingTap,
    this.trailingTooltip,
    this.height = 64,
    this.blur = false,
    this.animate = true,
    this.playSound = true,
  }) : assert(items.length >= 2);

  final List<LiquidGlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Selected icon/label color and pill tint. Defaults to iOS system blue.
  final Color? activeColor;

  /// Unselected icon/label color. Defaults to iOS system grey.
  final Color? inactiveColor;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final String? trailingTooltip;
  final double height;

  /// Translucent blurred background instead of solid. Costs GPU while the
  /// content behind scrolls; off by default.
  final bool blur;

  /// Slide the pill and zoom the bar when the tab changes.
  final bool animate;

  /// Play the system click sound when switching to a different tab.
  /// (Android: needs "Touch sounds" on in system settings.)
  final bool playSound;

  static const Duration _duration = Duration(milliseconds: 300);

  void _handleTap(int index) {
    if (index != currentIndex && playSound) {
      SystemSound.play(SystemSoundType.click);
    }
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = activeColor ??
        (isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF));
    final inactive = inactiveColor ??
        (isDark ? const Color(0xFF98989D) : const Color(0xFF8E8E93));
    final inset = MediaQuery.paddingOf(context).bottom;
    final bottom = inset > 0 ? math.max(inset - 14, 8.0) : 12.0;
    final duration = animate ? _duration : Duration.zero;
    final count = items.length;
    const pad = 6.0;

    final tabs = _ZoomOnChange(
      trigger: currentIndex,
      duration: duration,
      child: _Capsule(
        isDark: isDark,
        blur: blur,
        child: Padding(
          padding: const EdgeInsets.all(pad),
          child: Stack(
            children: [
              // Accent-tinted pill slides to the selected tab.
              AnimatedAlign(
                duration: duration,
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  -1 + 2 * currentIndex.clamp(0, count - 1) / (count - 1),
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / count,
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: _NavItem(
                        item: items[i],
                        selected: i == currentIndex,
                        color: i == currentIndex ? accent : inactive,
                        onTap: () => _handleTap(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottom),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(child: tabs),
            if (trailingIcon != null) ...[
              const SizedBox(width: 12),
              Semantics(
                button: true,
                label: trailingTooltip,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTrailingTap,
                  child: SizedBox.square(
                    dimension: height,
                    child: _Capsule(
                      isDark: isDark,
                      blur: blur,
                      child: Center(
                        child: Icon(trailingIcon, size: 24, color: inactive),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Zooms its child up and back (1 → 1.04 → 1) whenever [trigger] changes.
/// Does nothing on first build, and holds no running ticker while idle.
class _ZoomOnChange extends StatefulWidget {
  const _ZoomOnChange({
    required this.trigger,
    required this.duration,
    required this.child,
  });

  final Object trigger;
  final Duration duration;
  final Widget child;

  @override
  State<_ZoomOnChange> createState() => _ZoomOnChangeState();
}

class _ZoomOnChangeState extends State<_ZoomOnChange>
    with SingleTickerProviderStateMixin {
  static const double _peak = 0.04;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(covariant _ZoomOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (oldWidget.trigger != widget.trigger &&
        widget.duration > Duration.zero) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // Ease-out so the zoom peaks early in the slide, like the reference.
        final t = Curves.easeOut.transform(_controller.value);
        return Transform.scale(
          scale: 1 + _peak * math.sin(math.pi * t),
          child: child,
        );
      },
    );
  }
}

/// Rounded capsule surface: solid (default) or translucent blurred glass.
class _Capsule extends StatelessWidget {
  const _Capsule({
    required this.isDark,
    required this.blur,
    required this.child,
  });

  final bool isDark;
  final bool blur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(999));

    final Color fill;
    if (isDark) {
      fill = blur
          ? const Color.fromRGBO(30, 30, 32, 0.6)
          : const Color(0xFF1C1C1E);
    } else {
      fill = blur ? const Color.fromRGBO(255, 255, 255, 0.7) : Colors.white;
    }

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
      ),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: blur
          ? ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: surface,
              ),
            )
          : surface,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final LiquidGlassNavItem item;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 24,
                  color: color,
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    right: -10,
                    top: -4,
                    child: _Badge(count: item.badgeCount),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style red badge: plain number, capped at 99+.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      decoration: const BoxDecoration(
        color: Color(0xFFFF3B30),
        borderRadius: BorderRadius.all(Radius.circular(8.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
