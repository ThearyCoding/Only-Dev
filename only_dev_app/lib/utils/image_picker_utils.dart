import 'dart:developer';
import 'dart:io';
import 'package:only_dev_app/core/global_navigation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static bool _isFilePickerActive = false;
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    if (_isFilePickerActive) {
      return null;
    }
    _isFilePickerActive = true;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        final File? croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          return croppedFile;
        }
      }
    } catch (e) {
      log('Error picking image: $e');
    } finally {
      _isFilePickerActive = false;
    }
    return null;
  }

  static Future<File?> _cropImage(File pickedFile) async {
    final context = navigatorKey.currentState?.context;

    if (context != null) {
      const toolbarColor = Colors.black87;
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: toolbarColor,
            toolbarWidgetColor: Colors.white,
            cropStyle: CropStyle.circle,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    }
    return null;
  }
}
