import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:e_leaningapp/export/export.dart';
import 'package:e_leaningapp/utils/custom_validator.dart';
import 'package:e_leaningapp/utils/date_picker_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/buttons/custom_btn_loading_widget.dart';
import '../../widgets/other-widget/custom_date_picker_widget.dart';

class EditProfileInformation extends StatefulWidget {
  const EditProfileInformation({
    super.key,
  });

  @override
  State<EditProfileInformation> createState() => EditProfileInformationState();
}

class EditProfileInformationState extends State<EditProfileInformation> {
  String? email;
  String? photoURL;
  String? uid;
  final UserService userService = UserService();
  TextEditingController txtfirstname = TextEditingController();
  TextEditingController txtlastname = TextEditingController();
  TextEditingController txtbio = TextEditingController();
  final FirebaseFirestore firestore = locator<FirebaseFirestore>();
  final User? _auth = locator<FirebaseAuth>().currentUser;
  DateTime? selectedDate = DateTime(2006, 1, 5);
  String? _errorTextFirstName;
  String? _errorTextLastName;
  final formKey = GlobalKey<FormState>();

  // Add ValueNotifier to track unsaved changes
  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier<bool>(false);
  UserModel? userModel;
  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserProvider>(context, listen: false).userModel;
    if (userModel != null) {
      uid = _auth!.uid;
      photoURL = userModel!.photoURL;
      txtfirstname.text = userModel!.firstName;
      txtlastname.text = userModel!.lastName;
      txtbio.text = userModel!.bio ?? '';
      selectedDate = userModel!.dob;
    }

    // Add listeners to detect changes in text fields
    txtfirstname.addListener(_checkForUnsavedChanges);
    txtlastname.addListener(_checkForUnsavedChanges);
    txtbio.addListener(_checkForUnsavedChanges);
  }

  void handleInputChange(String value, bool isFirstName) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    String newValue = '';
    for (int i = 0; i < value.length; i++) {
      if (regex.hasMatch(value[i])) {
        newValue += value[i];
      }
    }

    if (isFirstName) {
      setState(() {
        txtfirstname.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
        _errorTextFirstName = regex.hasMatch(newValue)
            ? null
            : 'Only letters and numbers are allowed.';
      });
    } else {
      setState(() {
        txtlastname.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
        _errorTextLastName = regex.hasMatch(newValue)
            ? null
            : 'Only letters and numbers are allowed.';
      });
    }
  }

  void _checkForUnsavedChanges() {
    bool hasChanges = txtfirstname.text != userModel!.firstName ||
        txtlastname.text != userModel!.lastName ||
        txtbio.text != userModel!.bio ||
        selectedDate != userModel!.dob;

    _hasUnsavedChanges.value = hasChanges;
  }

  Future<void> onDateSelected(BuildContext context) async {
    final DateTime? pickedDate = await selectDate(context, selectedDate!);
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _checkForUnsavedChanges();
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges.value) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                  'You have unsaved changes. Do you really want to exit?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Updated'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your profile information has been successfully updated.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvoked: (didPop) {
        _onWillPop;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              splashRadius: 20,
              tooltip: 'Back',
              onPressed: () async {
                if (await _onWillPop()) {
                  if (!context.mounted) return;
                  context.pop();
                }
              },
              icon: Icon(
                size: 16,
                Icons.arrow_back_ios,
                color: isdark ? Colors.white : Colors.black,
              )),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Change Profiles',
            style: TextStyle(
              color: isdark ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'General Information',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFieldWidget02(
                          controller: txtfirstname,
                          labelText: 'First Name | ',
                          hintText: 'E.g., John',
                          errorText: _errorTextFirstName,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z0-9]+$'),
                            ),
                          ],
                          validator: (value) => customValidator(value),
                          onChanged: (value) => handleInputChange(value, true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextFieldWidget02(
                          controller: txtlastname,
                          labelText: 'Last Name | ',
                          hintText: 'E.g., Smith',
                          errorText: _errorTextLastName,
                          validator: (value) => customValidator(value),
                          onChanged: (value) => handleInputChange(value, false),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z0-9]+$'),
                            ),
                          ],
                        ),
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
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Additional Bio (Optional)')),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: txtbio,
                        hintText: 'Add a bio...',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: _hasUnsavedChanges,
                    builder: (context, hasChanges, child) {
                      return AbsorbPointer(
                        absorbing: hasChanges ? false : true,
                        
                        child: CustomBtnLoadingWidget(
                          btnText: 'Save Changes',
                          borderRadius: 10,
                          isInput: hasChanges,
                          backgroundColor: hasChanges
                              ?  Colors.blue
                              : Colors.transparent,
                          onTap: hasChanges
                              ? (startLoading, stopLoading, btnState) async {
                                  if (btnState == ButtonState.idle) {
                                    startLoading();
                                    if (formKey.currentState!.validate()) {
                                      await userService.updateUser(
                                        uid: uid,
                                        firstName: txtfirstname.text.trim(),
                                        lastName: txtlastname.text.trim(),
                                        displayName:
                                            '${txtfirstname.text.trim()} ${txtlastname.text.trim()}',
                                        bio: txtbio.text.trim(),
                                        dob: selectedDate,
                                      );
                                      await _showSuccessDialog();
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
      ),
    );
  }
}
