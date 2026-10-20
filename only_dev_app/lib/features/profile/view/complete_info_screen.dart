import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:random_avatar/random_avatar.dart';

import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/auth/provider/auth_provider.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/date_picker_utils.dart';
import 'package:only_dev_app/utils/image_picker_utils.dart';
import 'package:only_dev_app/widgets/buttons/custom_btn_loading_widget.dart';
import 'package:only_dev_app/widgets/check-box-widget/custom_check_box_widget_02.dart';
import 'package:only_dev_app/widgets/other-widget/custom_date_picker_widget.dart';
import 'package:only_dev_app/widgets/textfield/custom_text_field_widget_02.dart';

class CompleteInformations extends ConsumerStatefulWidget {
  final User user;
  const CompleteInformations({super.key, required this.user});

  @override
  ConsumerState<CompleteInformations> createState() =>
      _CompleteInformationsState();
}

class _CompleteInformationsState extends ConsumerState<CompleteInformations> {
  final TextEditingController txtfirstname = TextEditingController();
  final TextEditingController txtlastname = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? displayName;
  String? email;
  String? firstName;
  String? lastName;
  bool signedInWithGoogle = false;
  String svg = '';

  @override
  void initState() {
    super.initState();
    txtfirstname.addListener(_onTextChanged);
    txtlastname.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentUserSignInStatus();
      _populateTextFields();
      final userProfile = ref.read(userProfileProvider);
      if (userProfile.avatarUrl != null && userProfile.avatarUrl!.isNotEmpty) {
        ref.read(completeInfoProvider.notifier).setPhotoUrl(userProfile.avatarUrl);
      }
    });
  }

  @override
  void dispose() {
    txtfirstname.dispose();
    txtlastname.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    ref
        .read(completeInfoProvider.notifier)
        .updateNames(txtfirstname.text, txtlastname.text);
  }

  void _checkCurrentUserSignInStatus() {
    final user = widget.user;
    final authProvider =
        legacy_provider.Provider.of<AuthenticationProvider>(context, listen: false);
    signedInWithGoogle = authProvider.isSignedInWithGoogle(user);

    if (signedInWithGoogle) {
      _populateGoogleUserDetails(user);
    } else {
      email = user.email;
    }
  }

  void _populateGoogleUserDetails(User user) {
    displayName = user.displayName;
    email = user.email;

    final displayNameParts = user.displayName?.split(' ') ?? [];
    if (displayNameParts.isNotEmpty) {
      lastName = displayNameParts.last;
      firstName = displayNameParts.first;
    }

    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      ref.read(completeInfoProvider.notifier).setPhotoUrl(user.photoURL);
    }
  }

  void _populateTextFields() {
    if (txtfirstname.text.isEmpty && firstName != null) {
      txtfirstname.text = firstName!;
    }
    if (txtlastname.text.isEmpty && lastName != null) {
      txtlastname.text = lastName!;
    }
    _onTextChanged();
  }

  void randomAvatar() {
    svg = RandomAvatarString(
      DateTime.now().toIso8601String(),
      trBackground: false,
    );
  }

  Future<void> _pickImage() async {
    final croppedFile = await ImageUtils.pickImage();
    if (croppedFile != null) {
      try {
        EasyLoading.show(status: 'Preparing to upload...');
        await ref.read(completeInfoProvider.notifier).uploadAvatar(croppedFile);
        EasyLoading.dismiss();
      } catch (e) {
        EasyLoading.dismiss();
        if (kDebugMode) {
          print('Error uploading image: $e');
        }
      }
    }
  }

  Future<void> onDateSelected(BuildContext context, DateTime currentDate) async {
    final DateTime? pickedDate = await selectDate(context, currentDate);
    if (pickedDate != null && pickedDate != currentDate) {
      ref.read(completeInfoProvider.notifier).setSelectedDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(completeInfoProvider);
    final isdark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = formState.selectedDate ?? DateTime(2006, 1, 5);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Complete Information',
          style: TextStyle(
            color: isdark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              context.go('/');
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (lastName != null)
                  Text(
                    "Hey $lastName!",
                    style: const TextStyle(fontSize: 16),
                  ),
                const Text(
                  "You're applying for Only Dev Platform",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AppImageWidget.circle(
                      imageUrl: formState.photoUrl,
                      size: 150,
                      fallbackWidget: svg.isNotEmpty
                          ? SvgPicture.string(
                              svg,
                              width: 150,
                              height: 150,
                              placeholderBuilder: (BuildContext context) =>
                                  const CircularProgressIndicator(),
                            )
                          : null,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: _pickImage,
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('First Name | *'),
                    ),
                    const SizedBox(height: 8),
                    CustomTextFieldWidget02(
                      labelText: 'First Name ',
                      hintText: 'E.g., Chorn',
                      controller: txtfirstname,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Last Name | *'),
                    ),
                    const SizedBox(height: 8),
                    CustomTextFieldWidget02(
                      labelText: 'Last Name ',
                      hintText: 'E.g., Chorn',
                      controller: txtlastname,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      'Select Gender',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomCheckBoxWidget02(
                      label: 'Male',
                      value: formState.gender == 'Male',
                      onChanged: (bool? value) {
                        ref
                            .read(completeInfoProvider.notifier)
                            .setGender(value == true ? 'Male' : null);
                      },
                    ),
                    const SizedBox(width: 20),
                    CustomCheckBoxWidget02(
                      label: 'Female',
                      value: formState.gender == 'Female',
                      onChanged: (bool? value) {
                        ref
                            .read(completeInfoProvider.notifier)
                            .setGender(value == true ? 'Female' : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomDatePicker(
                  selectedValue:
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  onPressed: () {
                    onDateSelected(context, selectedDate);
                  },
                ),
                const SizedBox(height: 15),
                AbsorbPointer(
                  absorbing: !formState.isFormValid,
                  child: CustomBtnLoadingWidget(
                    btnText: 'Save Changes',
                    backgroundColor: formState.isFormValid
                        ? const Color.fromARGB(255, 53, 205, 58)
                        : Colors.grey,
                    onTap: formState.isFormValid
                        ? (startLoading, stopLoading, btnState) async {
                            if (btnState == ButtonState.idle) {
                              startLoading();
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await ref
                                      .read(completeInfoProvider.notifier)
                                      .saveProfile();
                                  if (!context.mounted) return;
                                  legacy_provider.Provider.of<
                                          AuthenticationProvider>(context,
                                      listen: false)
                                    .saveUserLoginStatus(true);
                                  context.push(RoutesPath.home);
                                } catch (e) {
                                  if (kDebugMode) {
                                    print('Save profile error: $e');
                                  }
                                }
                              }
                              stopLoading();
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
