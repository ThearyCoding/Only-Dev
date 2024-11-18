import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressImageUtils {
  static Future<File?> compressImage(File file) async {
    final String outputPath = '${file.path}_compressed.jpg';

    final XFile? compressedXFile =
        await FlutterImageCompress.compressAndGetFile(
            file.absolute.path, outputPath,
            quality: 70);

    return compressedXFile != null ? File(compressedXFile.path) : null;
  }
}
