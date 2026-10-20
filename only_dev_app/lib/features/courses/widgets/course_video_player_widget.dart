import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';

class CourseVideoPlayerWidget extends ConsumerWidget {
  final CourseContentParams params;

  const CourseVideoPlayerWidget({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseContentNotifierProvider(params));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _buildBody(context, ref, state, isDark),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CourseContentState state,
    bool isDark,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (state.errorMessage != null && state.currentLecture == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(courseContentNotifierProvider(params).notifier)
                      .initialize();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.betterPlayerController != null) {
      return BetterPlayer(
        key: ValueKey(state.selectedLectureId),
        controller: state.betterPlayerController!,
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, color: Colors.white54, size: 48),
          SizedBox(height: 8),
          Text(
            'Select a lecture to start playing',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
