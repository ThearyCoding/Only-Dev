import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/utils/time_utils.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';

class PostDetailsScreen extends ConsumerWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found'));
          }

          final title = post.title;
          final contentSections = post.contentSections;
          final timeformat = TimeUtils.formatTimestamp(post.createdAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(timeformat),
                const SizedBox(height: 16),
                ...contentSections.map((section) {
                  if (section['type'] == 'text') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        section['content'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  } else if (section['type'] == 'image') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AppImageWidget(
                        imageUrl: section['url'],
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
