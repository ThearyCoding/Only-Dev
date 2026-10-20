import 'dart:io';
import 'package:dio/dio.dart';
import '../../service/api/api_endpoints.dart';
import '../../service/api/dio_client.dart';
import '../models/storage_upload_model.dart';

abstract class StorageRemoteDataSource {
  Future<PresignedUploadResponse> getPresignedUrl({
    required String fileName,
    required String contentType,
    required String folder,
    int? fileSizeBytes,
  });

  Future<String> uploadFile(
    File file, {
    String folder = 'avatars',
    void Function(double progress)? onProgress,
  });
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final DioClient _dioClient;
  final Dio _rawDio;

  StorageRemoteDataSourceImpl(this._dioClient, [Dio? rawDio])
      : _rawDio = rawDio ?? Dio();

  String _determineContentType(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }

  String _mapFolder(String folder) {
    final lower = folder.toLowerCase();
    if (lower.contains('avatar') || lower.contains('user')) return 'avatars';
    if (lower.contains('post')) return 'posts';
    if (lower.contains('thumb')) return 'thumbnails';
    if (lower.contains('video')) return 'videos';
    if (lower.contains('attach')) return 'attachments';
    return 'resources';
  }

  @override
  Future<PresignedUploadResponse> getPresignedUrl({
    required String fileName,
    required String contentType,
    required String folder,
    int? fileSizeBytes,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.presign,
      data: {
        'fileName': fileName,
        'contentType': contentType,
        'folder': _mapFolder(folder),
        if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      return PresignedUploadResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }

    throw Exception('Failed to obtain presigned upload URL from backend');
  }

  @override
  Future<String> uploadFile(
    File file, {
    String folder = 'avatars',
    void Function(double progress)? onProgress,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final contentType = _determineContentType(file.path);
    final fileLength = await file.length();

    // 1. Get Presigned S3/R2 URL from backend
    final presignInfo = await getPresignedUrl(
      fileName: fileName,
      contentType: contentType,
      folder: folder,
      fileSizeBytes: fileLength,
    );

    // 2. Direct PUT binary payload to Cloudflare R2
    final fileBytes = await file.readAsBytes();
    await _rawDio.put(
      presignInfo.uploadUrl,
      data: Stream.fromIterable(fileBytes.map((e) => [e])),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: fileLength,
        },
      ),
      onSendProgress: (sent, total) {
        if (onProgress != null && total > 0) {
          onProgress(sent / total);
        }
      },
    );

    // 3. Return the public CDN URL
    return presignInfo.publicUrl;
  }
}

