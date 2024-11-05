import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:video_compress_v2/video_compress_v2.dart';

class VideoCompressor extends StatefulWidget {
  const VideoCompressor({super.key});

  @override
  VideoCompressorState createState() => VideoCompressorState();
}

class VideoCompressorState extends State<VideoCompressor> {
  File? _selectedVideoFile;
  bool _isCompressing = false;
  double _progress = 0.0;
  late Subscription _progressSubscription;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _selectedVideoFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _compressVideo() async {
    if (_selectedVideoFile == null) {
      log('Please select a video file.');
      return;
    }

    var status = await Permission.storage.request();
    if (!status.isDenied) {
      log('Storage permission denied.');
      return;
    }

    // Get the public directory (e.g., Downloads)
    final publicDir = Directory('/storage/emulated/0/Download');
    if (!await publicDir.exists()) {
      publicDir.create(recursive: true);
    }

    setState(() {
      _isCompressing = true;
      _progress = 0.0;
    });

    // Subscribe to compression progress
    _progressSubscription =
        VideoCompressV2.compressProgress$.subscribe((progress) {
      setState(() {
        _progress = progress / 100.0;
      });
    });

    // Use VideoCompress to compress the video
    final MediaInfo? mediaInfo = await VideoCompressV2.compressVideo(
      _selectedVideoFile!.path,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    // Stop listening to progress updates
    _progressSubscription.unsubscribe();

    if (mediaInfo != null) {
      log('Video compressed successfully! Output file: ${mediaInfo.toJson()}');
      
      setState(() {
        _isCompressing = false;
        _progress = 1.0;
      });
    } else {
      log('Failed to compress video.');
      final error =
          await VideoCompressV2.getMediaInfo(_selectedVideoFile!.path);
      log('Error details: $error');

      setState(() {
        _isCompressing = false;
      });
    }
  }

  @override
  void dispose() {
    _progressSubscription.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Compressor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedVideoFile != null)
              Text(
                  'Selected Video: ${path.basename(_selectedVideoFile!.path)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text('Select Video'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCompressing ? null : _compressVideo,
              child: const Text('Compress Video'),
            ),
            const SizedBox(height: 20),
            if (_isCompressing) ...[
              CircularProgressIndicator(value: _progress),
              const SizedBox(height: 10),
              Text('${(_progress * 100).toStringAsFixed(2)}%'),
              ElevatedButton(
                  onPressed: () async {
                    await VideoCompressV2.cancelCompression();
                  },
                  child: const Text("Cancel Compress"))
            ],
          ],
        ),
      ),
    );
  }

 

}
