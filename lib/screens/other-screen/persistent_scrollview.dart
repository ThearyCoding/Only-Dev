import 'package:flutter/material.dart';

/// A widget that manages a `ScrollController` and provides it to a child widget.
/// It ensures the `ScrollController` persists across widget rebuilds (e.g., hot reloads)
/// and supports scroll listeners.
class PersistentScrollView extends StatefulWidget {
  final Widget Function(ScrollController scrollController) builder;
  final Function(ScrollController controller)? scrollListener;

  /// Creates a PersistentScrollView.
  /// 
  /// [builder]: A function that builds the widget tree using the provided `ScrollController`.
  /// [scrollListener]: Optional listener function to observe scroll events.
  const PersistentScrollView({
    Key? key,
    required this.builder,
    this.scrollListener,
  }) : super(key: key);

  @override
  _PersistentScrollViewState createState() => _PersistentScrollViewState();
}

class _PersistentScrollViewState extends State<PersistentScrollView> {
  // Make the ScrollController a shared/persistent variable
  static ScrollController? _persistentController;

  @override
  void initState() {
    super.initState();

    // Initialize the ScrollController only if it doesn't already exist
    _persistentController ??= ScrollController();

    // Attach the scroll listener if provided
    _persistentController!.addListener(() {
      widget.scrollListener?.call(_persistentController!);
    });
  }

  @override
  void dispose() {
    // Clean up only if this is the last widget using the controller
    _persistentController?.dispose();
    _persistentController = null; // Reset for potential recreation
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass the persistent ScrollController to the builder
    return widget.builder(_persistentController!);
  }
}
