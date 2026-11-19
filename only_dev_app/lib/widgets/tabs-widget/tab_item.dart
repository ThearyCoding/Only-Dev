import 'package:flutter/material.dart';

/// Segment label for the home tab bar: title + optional small count capsule.
///
/// Colors follow the enclosing [TabBar]'s `labelColor` /
/// `unselectedLabelColor` (read from [DefaultTextStyle]), so the count tints
/// together with the title as the selection moves. The content scales down
/// to fit equal-width segments, so long or localized titles never clip.
class TabItem extends StatelessWidget {
  final String title;
  final int count;

  const TabItem({super.key, required this.title, this.count = 0});

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color ?? Colors.grey;

    return Tab(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, maxLines: 1),
              if (count > 0) ...[
                const SizedBox(width: 5),
                // Sized by its content only (no alignment → no stretching).
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: TextStyle(
                            color: color,
                            fontSize: 10.5,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
