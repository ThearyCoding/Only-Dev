import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:iconly/iconly.dart';
import 'package:only_dev_app/widgets/buttons/custom_button_widget_02.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/profile/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_dev_app/model/user_model.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/widgets/list-widget/custom_list_tile_widget.dart';
import 'package:only_dev_app/generated/l10n.dart';
import 'package:only_dev_app/features/settings/provider/theme_provider.dart';
import 'package:only_dev_app/utils/image_picker_utils.dart';
import 'package:only_dev_app/utils/show_dialog_sign_out_utils.dart';
import 'package:only_dev_app/utils/compress_image_util.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({
    super.key,
  });

  @override
  ConsumerState<UserInformationScreen> createState() =>
      UserInformationScreenState();
}

class UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  late UserProvider userProvider;
  late CustomizeThemeProvider themeProvider;
  final User? user = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isScrolledNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    userProvider =
        legacy_provider.Provider.of<UserProvider>(context, listen: false);
    themeProvider = legacy_provider.Provider.of<CustomizeThemeProvider>(context,
        listen: false);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 10 && !_isScrolledNotifier.value) {
      _isScrolledNotifier.value = true;
    } else if (_scrollController.offset <= 10 && _isScrolledNotifier.value) {
      _isScrolledNotifier.value = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isScrolledNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            title: ValueListenableBuilder<bool>(
              valueListenable: _isScrolledNotifier,
              builder: (context, isScrolled, _) =>
                  isScrolled ? const Text('Profile Settings') : const SizedBox.shrink(),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double appBarHeight = constraints.biggest.height;
                double blurAmount = appBarHeight > kToolbarHeight ? 0 : 10;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: blurAmount,
                          sigmaY: blurAmount,
                        ),
                        child: Container(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(blurAmount > 0 ? 0.6 : 0),
                        ),
                      ),
                    ),
                    AppBar(
                      elevation: 0,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      actions: [_buildSwitcher(isDark)],
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final profileState = ref.watch(userProfileProvider);
                final currentUser = profileState.user ?? userProvider.user;
                if (profileState.isLoading || (currentUser == null && userProvider.isLoading)) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return currentUser == null
                      ? _buildErrorState()
                      : _build(currentUser);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _build(UserModel userModel) {
    Color backgroundColor = Colors.white;
    backgroundColor = _getBackgroundColor(userModel, backgroundColor);
    final localization = AppLocalizations.of(context);
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

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: userModel.photoURL.isNotEmpty
                            ? () => context
                                    .push(RoutesPath.detailImageScreen, extra: {
                                  'imageUrl': userModel.photoURL,
                                })
                            : null,
                        child: AppCircleAvatar(
                          imageUrl: userModel.photoURL,
                          name: userModel.fullName,
                          radius: (avatarSize - 10) / 2,
                          backgroundColor: backgroundColor,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: avatarSize * 0.4,
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
              _listviewItem(
                  listTilePadding: listTilePadding,
                  localization: localization,
                  user: user,
                  userProvider: userProvider,
                  userModel: userModel),
            ],
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(UserModel userModel, Color backgroundColor) {
    final rawColor = userModel.backgroundColor.trim();
    if (rawColor.isNotEmpty) {
      final hex = rawColor.startsWith('#')
          ? '0xff${rawColor.substring(1)}'
          : (rawColor.startsWith('0x') ? rawColor : '0xff$rawColor');
      final parsed = int.tryParse(hex);
      if (parsed != null) {
        return Color(parsed);
      }
    }
    return backgroundColor;
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
      await ref.read(userProfileProvider.notifier).uploadAvatar(imageFile);
      if (!mounted) return;
      final updatedUser = ref.read(userProfileProvider).user;
      if (updatedUser != null) {
        userProvider.setUserData(updatedUser);
      }
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final File? croppedFile = await ImageUtils.pickImage();
    if (croppedFile != null) {
      final File? image = await CompressImageUtils.compressImage(croppedFile);
      if (image != null) {
        await _uploadImageAndSaveUrl(image);
      }
    }
  }

  ThemeSwitcher _buildSwitcher(bool isdark) {
    return ThemeSwitcher(builder: (context) {
      return legacy_provider.Consumer<CustomizeThemeProvider>(
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
  final AppLocalizations localization;
  final User? user;
  final UserProvider userProvider;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: listTilePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              legacy_provider.Provider.of<UserProvider>(context, listen: false)
                  .setUserData(userModel);

              context.push(RoutesPath.editProfileInformation);
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
          ZoomTapAnimation(
            onTap: () async {
              await _onLogOuttap(context);
            },
            child: SizedBox(
                width: double.infinity,
                child: CustomElevatedButtonWidget02(
                  onPressed: () async {
                    await _onLogOuttap(context);
                  },
                  text: localization.logOut,
                  textColor: Colors.white,
                  backgroundColor: Colors.red,
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _onLogOuttap(BuildContext context) async {
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
      await userProvider.handleUserLogout();
      EasyLoading.dismiss();
    }
  }
}
