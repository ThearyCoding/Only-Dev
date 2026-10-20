class PresignedUploadResponse {
  final String uploadUrl;
  final String publicUrl;
  final String r2Key;
  final int expiresInSeconds;

  PresignedUploadResponse({
    required this.uploadUrl,
    required this.publicUrl,
    required this.r2Key,
    required this.expiresInSeconds,
  });

  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUploadResponse(
      uploadUrl: (json['upload_url'] ?? json['uploadUrl'] ?? '').toString(),
      publicUrl: (json['public_url'] ?? json['publicUrl'] ?? '').toString(),
      r2Key: (json['r2_key'] ?? json['r2Key'] ?? '').toString(),
      expiresInSeconds: (json['expires_in_seconds'] ?? json['expiresInSeconds'] ?? 900) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upload_url': uploadUrl,
      'public_url': publicUrl,
      'r2_key': r2Key,
      'expires_in_seconds': expiresInSeconds,
    };
  }
}

