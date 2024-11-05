import 'dart:developer';
import 'dart:io';
import 'package:e_leaningapp/core/global_navigation.dart';
import 'package:e_leaningapp/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';

class ImageUtils {
  static bool _isFilePickerActive = false;
  static Future<File?> pickImage() async {
    if (_isFilePickerActive) {
      return null;
    }
    _isFilePickerActive = true;
    final context = navigatorKey.currentState?.context;

    try {
      if (context != null) {
        final theme =
            InstaAssetPicker.themeData(Theme.of(context).primaryColor);

        final result = await InstaAssetPicker.pickAssets(
          context,
          maxAssets: 1,
          requestType: RequestType.image,
          pickerConfig: InstaAssetPickerConfig(
            title: S.current.selectAssetsTitle,
            textDelegate: assetPickerTextDelegateFromLocale(
                Localizations.localeOf(context)),
            cropDelegate: const InstaAssetCropDelegate(
              preferredSize: 1080,
              cropRatios: [1.0, 4.0 / 5.0],
            ),
            closeOnComplete: true,
            pickerTheme: theme.copyWith(
              
              canvasColor: Colors.black, // body background color
              splashColor: Colors.grey, // ontap splash color
              colorScheme: theme.colorScheme.copyWith(
                surface: Colors.black87, // albums list background color
              ),
              appBarTheme: theme.appBarTheme.copyWith(
                backgroundColor: Colors.black, // app bar background color
                titleTextStyle: Theme.of(context)
                    .appBarTheme
                    .titleTextStyle
                    ?.copyWith(
                      fontSize: 10,
                        color: Colors
                            .white), // change app bar title text style to be like app theme
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  disabledForegroundColor: Colors.red,
                ),
              ),
            ),
          ),
          onCompleted: (Stream<InstaAssetsExportDetails> exportDetails) {},
        );

        if (result != null) {
          final File? imageFile = await result.first.file;
          if (imageFile != null) {
            final File? croppedFile = await _cropImage(imageFile);
            if (croppedFile != null) {
              return croppedFile;
            }
          }
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

  static Future<File?> pickAndCropImage(BuildContext context) async {
    if (_isFilePickerActive) return null;
    _isFilePickerActive = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        File pickedFile = File(result.files.single.path!);
        return await _cropImage(pickedFile);
      }
    } catch (e) {
      log('Error picking file: $e');
    } finally {
      _isFilePickerActive = false;
    }
    return null;
  }
}
