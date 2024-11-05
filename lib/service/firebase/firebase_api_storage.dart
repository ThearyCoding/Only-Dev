import 'dart:developer';
import 'dart:io';

import 'package:e_leaningapp/di/dependency_injection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FirebaseApiStorage{

  final FirebaseStorage _storage = locator<FirebaseStorage>();

  Future<String?> uploadImage(File imageFile, String folderName,
      {String? oldPhotoUrl}) async {
    try {
      // Check if oldPhotoUrl is a Firebase Storage URL before attempting to delete it
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        try {
          Reference oldPhotoRef =
              _storage.refFromURL(oldPhotoUrl);
          await oldPhotoRef.delete();

          log('Old photo deleted successfully');
        } catch (e) {
          log('Error deleting old photo from Firebase Storage: $e');
        }
      }

      // Upload the new photo with progress tracking
      Reference storageRef = _storage
          .ref('$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));

      // Show upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        EasyLoading.showProgress(progress,
            status: 'Uploading... ${(progress * 100).toStringAsFixed(0)}%');
      });

      // Await task completion
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      log('Error uploading image : $e');
      return null;
    }
  }
}