import '../../../di/dependency_injection.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/user-screens/user_information_screen.dart';
import '../../../widgets/check-box-widget/custom_check_box_widget_02.dart';
import '../../core/colors.dart';
import '../../export/export.dart';
import '../../service/firebase/firebase_api_storage.dart';
import '../../utils/date_picker_utils.dart';
import '../../utils/image_picker_utils.dart';
import '../../widgets/buttons/custom_btn_loading_widget.dart';
import '../../widgets/other-widget/custom_date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:loading_btn/loading_btn.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';

class CompleteInformations extends StatefulWidget {
  final User user;
  const CompleteInformations({Key? key, required this.user}) : super(key: key);

  @override
  State<CompleteInformations> createState() => _CompleteInformationsState();
}

class _CompleteInformationsState extends State<CompleteInformations> {
  final AuthServiceGoogle authServiceGoogle = locator<AuthServiceGoogle>();
  final AuthServiceFacebook authServiceFacebook =
      locator<AuthServiceFacebook>();
  final User? user = locator<FirebaseAuth>().currentUser;
  final UserService _userService = locator<UserService>();
  String? lastName;
  String? firstName;
  final DateTime _selectedDate = DateTime(2006, 1, 5);
  TextEditingController txtfirstname = TextEditingController();
  TextEditingController txtlastname = TextEditingController();
  String? selectedGender;
  DateTime? selectedDate = DateTime(2006, 1, 5);
  late AuthenticationProvider authenticationProvider;
  File? _croppedFile;
  final _formKey = GlobalKey<FormState>();
  String? displayName;
  String? email;
  String? photoURL;
  bool signedInWithGoogle = false;
  bool signedInWithFacebook = false;
  final ValueNotifier<bool> _isSaveButtonEnabled = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    // Initialize your controllers and set up listeners
    txtfirstname.addListener(_checkFormValidity);
    txtlastname.addListener(_checkFormValidity);
    // Deferring context-dependent operations until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authenticationProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      _checkCurrentUserSignInStatus();
      _populateTextFields();
      fetchUserPhotoUrl();
    });
  }

  void _checkFormValidity() {
    // This function checks if all fields are filled out correctly
    final isFormValid = txtfirstname.text.isNotEmpty &&
        txtlastname.text.isNotEmpty &&
        selectedGender != null;
    setState(() {
      _isSaveButtonEnabled.value = isFormValid;
    });
  }

  Future<void> fetchUserPhotoUrl() async {
    if (user != null) {
      String uid = user!.uid;
      String? photoURL = await _userService.getPhotoUrlFromFirestore(uid);

      if (photoURL != null) {
        setState(() {
          this.photoURL = photoURL;
        });
      } else {
        log('No photoURL found for user with UID: $uid');
      }
    } else {
      log('User is not logged in.');
    }
  }

  String svg = '';
  void randomAvatar() {
    svg = RandomAvatarString(
      DateTime.now().toIso8601String(),
      trBackground: false,
    );
  }

  void _checkCurrentUserSignInStatus() {
    User? user = widget.user;

    if (user != null) {
      signedInWithGoogle = authServiceGoogle.isSignedInWithGoogle(user);
      signedInWithFacebook = authServiceFacebook.isSignedInWithFacebook(user);

      if (signedInWithGoogle) {
        _populateGoogleUserDetails(user);
      } else if (signedInWithFacebook) {
        _populateFacebookUserDetails(user);
      } else {
        email = user.email;
        // randomAvatar();
      }
    } else {
      throw Exception("User not authenticated");
    }
  }

  Future<void> _populateFacebookUserDetails(User user) async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${accessToken.token}'));
      if (graphResponse.statusCode == 200) {
        final profileData = jsonDecode(graphResponse.body);

        setState(() {
          displayName = profileData['name'];
          email = profileData['email'];
          photoURL = profileData['picture']['data']['url'];

          final displayNameParts = displayName?.split(' ') ?? [];
          if (displayNameParts.isNotEmpty) {
            lastName = displayNameParts.last;
          }
          if (displayNameParts.isNotEmpty) {
            firstName = displayNameParts.first;
          }
          _populateTextFields();
        });
      } else {
        log('Failed to fetch profile data from Facebook Graph API.');
      }
    } else {
      log('Facebook access token is null.');
    }
  }

  Future<void> _pickImage() async {
    File? croppedFile = await ImageUtils.pickImage();
    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
      _uploadImageAndSaveUrl(_croppedFile!);
    }
  }

  Future<void> _uploadImageAndSaveUrl(File imageFile) async {
    try {
      EasyLoading.show(status: 'Preparing to upload...');

      String? downloadURL = await FirebaseApiStorage().uploadImage(
          File(imageFile.path), 'user_images',
          oldPhotoUrl: photoURL);
      if (downloadURL != null) {
        photoURL = await _userService.updatePhotoUser(downloadURL);
        setState(() {});
      }

      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> onDateSelected(BuildContext context) async {
    final DateTime? pickedDate = await selectDate(context, selectedDate!);
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = isdark ? highlightColorDark : highlightColorLight;
    final baseColor = isdark ? baseColorDark : baseColorLight;
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
              icon: const Icon(Icons.exit_to_app))
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
                lastName != null
                    ? Text(
                        "Hey $lastName!",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      )
                    : Container(),
                const Text(
                  "You're applying for E-Learning Platform",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: photoURL != null
                          ? CachedNetworkImage(
                              imageUrl: photoURL!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: baseColor,
                                highlightColor: highlightColor,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : (svg.isNotEmpty
                              ? SvgPicture.string(
                                  svg,
                                  width: 150,
                                  height: 150,
                                  placeholderBuilder: (BuildContext context) =>
                                      const CircularProgressIndicator(),
                                )
                              : null),
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
                            onTap: () async {
                              await _pickImage();
                            },
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
                        child: Text('First Name | *')),
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
                        child: Text('Last Name | *')),
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
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomCheckBoxWidget02(
                      label: 'Male',
                      value: selectedGender == 'Male',
                      onChanged: (bool? value) {
                        _onGenderChanged(value == true ? 'Male' : null);
                      },
                    ),
                    const SizedBox(width: 20),
                    CustomCheckBoxWidget02(
                      label: 'Female',
                      value: selectedGender == 'Female',
                      onChanged: (bool? value) {
                        _onGenderChanged(value == true ? 'Female' : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomDatePicker(
                  selectedValue: selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : '',
                  onPressed: () {
                    onDateSelected(context);
                  },
                ),
                const SizedBox(height: 15),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSaveButtonEnabled,
                  builder: (context, hasChanges, child) {
                    return AbsorbPointer(
                      absorbing: hasChanges ? false : true,
                      child: CustomBtnLoadingWidget(
                        btnText: 'Save Changes',
                        backgroundColor: hasChanges
                            ? const Color.fromARGB(255, 53, 205, 58)
                            : Colors.grey,
                        onTap: hasChanges
                            ? (startLoading, stopLoading, btnState) async {
                                final int gender =
                                    selectedGender == 'Female' ? 0 : 1;
                                if (btnState == ButtonState.idle) {
                                  startLoading();
                                  if (_formKey.currentState!.validate()) {
                                    await _userService.userRegistration(
                                      widget.user.uid,
                                      email,
                                      photoURL,
                                      txtfirstname.text,
                                      txtlastname.text,
                                      gender,
                                      _selectedDate,
                                    );
                                    authenticationProvider
                                        .saveUserLoginStatus(true);
                                    // ignore: use_build_context_synchronously
                                    context.push(RoutesPath.home);
                                  }
                                  stopLoading();
                                }
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _populateTextFields() {
    if (txtfirstname.text.isEmpty) {
      txtfirstname.text = firstName ?? '';
    }

    if (txtlastname.text.isEmpty) {
      txtlastname.text = lastName ?? '';
    }
  }

  void _populateGoogleUserDetails(User user) {
    displayName = user.displayName;
    email = user.email;
    photoURL = user.photoURL;

    final displayNameParts = user.displayName?.split(' ') ?? [];
    if (displayNameParts.isNotEmpty) {
      lastName = displayNameParts.last;
    }
    if (displayNameParts.isNotEmpty) {
      firstName = displayNameParts.first;
    }
  }

  void _onGenderChanged(String? gender) {
    setState(() {
      selectedGender = gender;
    });
    _checkFormValidity();
  }
}
