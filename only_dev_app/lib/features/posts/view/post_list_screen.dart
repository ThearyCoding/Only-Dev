import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/posts/view/display_post_screen.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';

class PostListScreen extends ConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Posts'),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts available'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final title = post.title;
              final contentSections = post.contentSections;

              const defaultImageUrl = 'https://via.placeholder.com/150';
              String? imageUrl;
              for (var section in contentSections) {
                if (section['type'] == 'image') {
                  imageUrl = section['url'];
                  break;
                }
              }
              imageUrl ??= defaultImageUrl;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PostDetailsScreen(postId: post.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppImageWidget(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          post.contentPreview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
