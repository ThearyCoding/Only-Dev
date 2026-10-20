import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';

class DetailImageScreen extends ConsumerWidget {
  final String imageUrl;

  const DetailImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = AppImageWidget.safeNetworkImageProvider(imageUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          provider != null
              ? PhotoView(
                  imageProvider: provider,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                EasyLoading.show(
                    status: 'Please wait there are deletings in progress');
                await ref
                    .read(userProfileProvider.notifier)
                    .updateProfile(avatarUrl: '');
                EasyLoading.dismiss();
                if (!context.mounted) return;
                context.pop();
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Icon(
                  CupertinoIcons.delete,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
