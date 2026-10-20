import 'dart:io';
import '../datasources/storage_remote_data_source.dart';
import '../models/storage_upload_model.dart';

abstract class StorageRepository {
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

class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource _remoteDataSource;

  StorageRepositoryImpl(this._remoteDataSource);

  @override
  Future<PresignedUploadResponse> getPresignedUrl({
    required String fileName,
    required String contentType,
    required String folder,
    int? fileSizeBytes,
  }) {
    return _remoteDataSource.getPresignedUrl(
      fileName: fileName,
      contentType: contentType,
      folder: folder,
      fileSizeBytes: fileSizeBytes,
    );
  }

  @override
  Future<String> uploadFile(
    File file, {
    String folder = 'avatars',
    void Function(double progress)? onProgress,
  }) {
    return _remoteDataSource.uploadFile(
      file,
      folder: folder,
      onProgress: onProgress,
    );
  }
}

