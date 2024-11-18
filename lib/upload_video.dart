import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class UploadVideo extends StatefulWidget {
  const UploadVideo({super.key});

  @override
  UploadVideoState createState() => UploadVideoState();
}

class UploadVideoState extends State<UploadVideo> {
  String? _videoFile;
  String? _compressedVideoPath;
  double _videoDuration = 0.0;
  String? videoName;

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _videoFile = result.files.single.path;
          videoName = result.files.single.name;
          _compressedVideoPath = null; // Reset compressed path
        });

        // Get video duration after picking the video
        await _getVideoDuration(_videoFile!);
      }
    } catch (e) {
      log('Error picking video: $e');
    }
  }

  Future<void> _getVideoDuration(String videoPath) async {
    final probeSession = await FFprobeKit.getMediaInformation(videoPath);
    final mediaInfo = probeSession.getMediaInformation();
    if (mediaInfo != null) {
      final duration = double.tryParse(mediaInfo.getDuration() ?? "0") ?? 0.0;
      setState(() {
        _videoDuration = duration;
      });
      log("Video duration: $_videoDuration seconds");
    } else {
      log("Could not retrieve video duration.");
    }
  }



  double _combinedProgress = 0.0; // New combined progress variable

// Update the compression method to adjust combined progress.
Future<void> _compressVideo() async {
  if (_videoFile == null || _videoDuration == 0.0) return;

  String inputPath = _videoFile!;
   await Permission.storage.request();

  
  // Define output path
  final Directory downloadsDir = Directory('/storage/emulated/0/Download');
  if (!await downloadsDir.exists()) {
    await downloadsDir.create(recursive: true);
  }

  final originalFileName = path.basenameWithoutExtension(inputPath);
  final originalExtension = path.extension(inputPath);
  final String outputPath =
      '${downloadsDir.path}/${originalFileName}_compress$originalExtension';

  // FFmpeg command for compression
  String ffmpegCommand = '-i "$inputPath" '
      '-t 60 ' 
      '-vcodec libx264 '
      '-crf 28 '
      '-preset slower '
      '-acodec aac '
      '-b:a 48k '
      '-b:v 250k '
      '-vf scale=trunc(iw/2)*2:trunc(ih/2)*2 '
      '-movflags +faststart '
      '-y "$outputPath"';

  // Compression progress tracking
  FFmpegKitConfig.enableStatisticsCallback((statistics) {
    final double currentTime = statistics.getTime().toDouble() / 1000;
    final double compressionProgress = currentTime / _videoDuration * 0.5; // Compression is 50%
    setState(() {
      _combinedProgress = compressionProgress;
    });
    log("Combined Progress (Compression): ${(_combinedProgress * 100).toStringAsFixed(2)}%");
  });

  await FFmpegKit.executeAsync(
    ffmpegCommand,
    (session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode!.isValueSuccess()) {
        log("Compression completed successfully");
        setState(() {
          _combinedProgress = 0.5; // Compression complete, 50%
        });
        // Start upload after compression
        await _uploadToFirebase(outputPath);
      } else {
        log("Compression failed with return code $returnCode");
      }
    },
    (log) => debugPrint('FFmpeg log: ${log.getMessage()}'),
  );
}

Future<void> _uploadToFirebase(String filePath) async {
  try {
    final File file = File(filePath);
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("uploads/${path.basename(filePath)}");
    
    final UploadTask uploadTask = storageRef.putFile(file);
    
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final double uploadProgress =
          snapshot.bytesTransferred / snapshot.totalBytes * 0.5; // Upload 50%
      setState(() {
        _combinedProgress = 0.5 + uploadProgress; // Combine progress
      });
      log("Combined Progress (Upload): ${(_combinedProgress * 100).toStringAsFixed(2)}%");
    });

    await uploadTask.whenComplete(() => log("Upload completed successfully"));
  } catch (e) {
    log("Error uploading to Firebase: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Processing')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_compressedVideoPath != null)
                Text('Compressed Video: $_compressedVideoPath'),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _combinedProgress),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickVideo,
                child: const Text('Pick Video'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _compressVideo,
                child: const Text('Compress Video'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FFmpegKit.cancel();
                },
                child: const Text('Cancel Compress Video'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
