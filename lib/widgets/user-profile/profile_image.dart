import 'package:e_leaningapp/providers/user_provider.dart';
import 'package:e_leaningapp/utils/generate_color.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProfileImage extends StatefulWidget {
  final VoidCallback onTap;

  const ProfileImage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, value, child) {
        final photoURL = userProvider.user?.photoURL;
        final user = userProvider.user;

        if (user == null) {
          return const SizedBox.shrink();
        }

        // Extract initials from the user's name
        String initials = '';
        if (user.firstName.isNotEmpty) {
          initials += user.firstName[0];
        }
        if (user.lastName.isNotEmpty) {
          initials += user.lastName[0];
        }

        Color? userColor;
        if (user.backgroundColor != null) {
          userColor =
              Color(int.parse(user.backgroundColor.replaceFirst('#', '0xff')));
        } else {
          userColor = GenerateColor.generateRandomColor();
        }
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: photoURL == null || photoURL.isEmpty
                      ? userColor
                      : Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: photoURL != null && photoURL.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoURL,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
