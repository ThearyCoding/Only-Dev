import 'dart:developer';
import 'dart:io';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../export/export.dart';
import '../../generated/l10n.dart';
import '../../providers/theme_provider.dart';
import '../../service/firebase/firebase_api_storage.dart';
import '../../utils/image_picker_utils.dart';
import '../../utils/show_dialog_sign_out_utils.dart';
export 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UserInformationScreen> createState() => UserInformationScreenState();
}

class UserInformationScreenState extends State<UserInformationScreen> {
  String photoURL = '';
  late UserProvider userProvider;
  late CustomizeThemeProvider themeProvider;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = locator<FirebaseAuth>().currentUser;
  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    themeProvider = Provider.of<CustomizeThemeProvider>(context, listen: false);
  }

  

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [_buildSwitcher(isdark)],
      ),
      body: Consumer<UserProvider>(
        builder: (context, value, child) {
          final user = userProvider.user;
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return user == null ? _buildErrorState() : _build(user);
          }
        },
      ),
    );
  }

  Widget _build(UserModel userModel) {
    String initials = _extractUserName(userModel);
    Color backgroundColor = Colors.white;
    backgroundColor = _getBackgroundColor(userModel, backgroundColor);
    final localization = S.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        double screenWidth = constraints.maxWidth;
        bool isSmallest = screenWidth < 320;
        bool isSmall = screenWidth >= 320 && screenWidth < 600;
        bool isMedium = screenWidth >= 600 && screenWidth < 900;
        double avatarSize = _avatarSize(isSmallest, isSmall, isMedium);
        double fontSizeName = _fontSizeName(isSmallest, isSmall, isMedium);
        double fontSizeEmail = _fontSizeEmail(isSmallest, isSmall, isMedium);
        double iconSize = _iconSize(isSmallest, isSmall);
        double padding = _padding(isSmallest, isSmall);
        double listTilePadding = _listTilePadding(isSmallest, isSmall);

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: userModel.photoURL.isNotEmpty
                          ? () => context.push(RoutesPath.detailImageScreen,
                                  extra: {
                                    'imageUrl': userModel.photoURL,
                                  })
                          : null,
                      child: Container(
                        width: avatarSize - 10,
                        height: avatarSize - 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundColor,
                        ),
                        child: CircleAvatar(
                          radius: (avatarSize - 10) / 2,
                          backgroundColor: Colors.transparent,
                          child: userModel.photoURL.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: userModel.photoURL,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    radius: (avatarSize - 10) / 2,
                                    backgroundImage: imageProvider,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: avatarSize * 0.4,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await _pickImage();
                    },
                    child: Container(
                      height: iconSize * 2,
                      width: iconSize * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.grey.shade500 : Colors.black,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: listTilePadding / 2),
            Text(
              '${userModel.firstName} ${userModel.lastName}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: fontSizeName,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: listTilePadding / 3),
            Text(
              userModel.email,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: fontSizeEmail,
              ),
            ),
            SizedBox(height: listTilePadding / 2),
            Container(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(
                userModel.bio?.isNotEmpty == true
                    ? userModel.bio!
                    : localization.noBioAvailable,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: fontSizeEmail,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),
            ),
            SizedBox(height: listTilePadding),
            Expanded(
              child: _listviewItem(
                  listTilePadding: listTilePadding,
                  localization: localization,
                  user: user,
                  userProvider: userProvider,
                  userModel: userModel),
            ),
          ],
        );
      },
    );
  }

  Color _getBackgroundColor(UserModel userModel, Color backgroundColor) {
    if (userModel.backgroundColor != null) {
      Color userColor =
          Color(int.parse(userModel.backgroundColor.replaceFirst('#', '0xff')));

      backgroundColor = userColor;
    }
    return backgroundColor;
  }

  String _extractUserName(UserModel userModel) {
    String initials = '';
    if (userModel.firstName.isNotEmpty) {
      initials += userModel.firstName[0];
    }
    if (userModel.lastName.isNotEmpty) {
      initials += userModel.lastName[0];
    }
    return initials;
  }

  double _listTilePadding(bool isSmallest, bool isSmall) {
    double listTilePadding = isSmallest
        ? 10
        : isSmall
            ? 15
            : 20;
    return listTilePadding;
  }

  double _padding(bool isSmallest, bool isSmall) {
    double padding = isSmallest
        ? 10
        : isSmall
            ? 20
            : 40;
    return padding;
  }

  double _iconSize(bool isSmallest, bool isSmall) {
    double iconSize = isSmallest
        ? 16
        : isSmall
            ? 18
            : 20;
    return iconSize;
  }

  double _fontSizeEmail(bool isSmallest, bool isSmall, bool isMedium) {
    double fontSizeEmail = isSmallest
        ? 12
        : isSmall
            ? 14
            : isMedium
                ? 16
                : 18;
    return fontSizeEmail;
  }

  double _fontSizeName(bool isSmallest, bool isSmall, bool isMedium) {
    double fontSizeName = isSmallest
        ? 14
        : isSmall
            ? 16
            : isMedium
                ? 18
                : 20;
    return fontSizeName;
  }

  double _avatarSize(bool isSmallest, bool isSmall, bool isMedium) {
    double avatarSize = isSmallest
        ? 80
        : isSmall
            ? 100
            : isMedium
                ? 120
                : 140;
    return avatarSize;
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        'Error loading user data. Please try again.',
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
        ),
      ),
    );
  }

  Future<void> _uploadImageAndSaveUrl(File imageFile) async {
    try {
      EasyLoading.show(status: 'Preparing to upload...');

      String? downloadURL = await FirebaseApiStorage().uploadImage(
          File(imageFile.path), 'user_images',
          oldPhotoUrl: photoURL);
      if (downloadURL != null) {
        await _saveImageUrlToFirestore(downloadURL);
      }

      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      if (user != null) {
        await firestore.collection('users').doc(user!.uid).update({
          'photoURL': imageUrl,
        });
        setState(() {
          photoURL = imageUrl;
        });
      }
    } catch (e) {
      log('Error saving image URL: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  File? _croppedFile;
  Future<void> _pickImage() async {
    File? croppedFile = await ImageUtils.pickImage();
    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
      _uploadImageAndSaveUrl(_croppedFile!);
    }
  }
  ThemeSwitcher _buildSwitcher(bool isdark) {
    return ThemeSwitcher(builder: (context) {
      return Consumer<CustomizeThemeProvider>(
        builder: (context, value, child) {
          return IconButton(
            splashRadius: 20,
            tooltip: 'Change Theme',
            onPressed: () {
              themeProvider.switchTheme(context);
            },
            icon: Icon(
              size: 16,
              color: isdark ? Colors.white : Colors.black,
              themeProvider.currentTheme == ThemeMode.dark
                  ? Icons.nightlight_outlined
                  : Icons.wb_sunny_outlined,
            ),
          );
        },
      );
    });
  }
}

// ignore: camel_case_types
class _listviewItem extends StatelessWidget {
  const _listviewItem(
      {required this.listTilePadding,
      required this.localization,
      required this.user,
      required this.userProvider,
      required this.userModel});

  final double listTilePadding;
  final S localization;
  final User? user;
  final UserProvider userProvider;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: listTilePadding),
      children: [
        Text(
          localization.yourAccount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: listTilePadding / 2),
        CustomListTile(
          leadingIcon: Icon(
            IconlyBold.profile,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          title: localization.editProfile,
          onTap: () {
            context.push(
              RoutesPath.editProfileInformation,
              extra: {
                'userModel': userModel,
                'auth': user!,
              },
            );
          },
        ),
        SizedBox(height: listTilePadding / 2),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localization.appSettings,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: listTilePadding / 2),
        CustomListTile(
          leadingIcon: const Icon(Icons.settings, size: 18),
          title: localization.settings,
          onTap: () {
            context.push(RoutesPath.settingscreen);
          },
        ),
        SizedBox(height: listTilePadding),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localization.notificationsTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: listTilePadding / 2),
        CustomListTile(
          leadingIcon: const Icon(Icons.notifications, size: 18),
          title: localization.notifications,
          onTap: () {
            context.push(RoutesPath.isEnableNotifications);
          },
        ),
        SizedBox(height: listTilePadding / 2),
        CustomListTile(
            leadingIcon: const Icon(Icons.video_collection, size: 18),
            title: localization.myCourses,
            onTap: () {
              context.push(RoutesPath.myCoursesScreen);
            }),
        SizedBox(
          height: listTilePadding,
        ),
        ElevatedButton(
          onPressed: () async {
            bool? confirmSignOut = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => LogOutDialog(
                message: localization.logout_message,
                title: localization.logout_title,
                icon: Icons.logout,
              ),
            );
            if (confirmSignOut!) {
              EasyLoading.show(
                status: 'Logout User',
              );
              String userId = locator<FirebaseAuth>().currentUser!.uid;

              if (userId != null && userId.isNotEmpty) {
                await locator<FirebaseFirestore>()
                    .collection('users')
                    .doc(userId)
                    .update({
                  'fcmToken': FieldValue.delete(),
                });
              }
              userProvider.handleUserLogout();
              EasyLoading.dismiss();
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(
                vertical: listTilePadding, horizontal: listTilePadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            localization.logOut,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
}
