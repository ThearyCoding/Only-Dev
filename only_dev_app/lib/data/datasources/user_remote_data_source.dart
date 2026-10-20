import '../../service/api/api_endpoints.dart';
import '../../service/api/dio_client.dart';
import '../models/models.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getMyProfile();
  Future<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? bio,
    String? phoneNumber,
  });
  Future<UserModel> getUserById(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient _dioClient;

  UserRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> getMyProfile() async {
    final response = await _dioClient.get(ApiEndpoints.userProfile);
    if (response.data != null && response.data['data'] != null) {
      return UserModel.fromMap(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch user profile');
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? bio,
    String? phoneNumber,
  }) async {
    final response = await _dioClient.patch(
      ApiEndpoints.userProfile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (headline != null) 'headline': headline,
        if (bio != null) 'bio': bio,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      return UserModel.fromMap(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update user profile');
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response = await _dioClient.get('${ApiEndpoints.users}/$id');
    if (response.data != null && response.data['data'] != null) {
      return UserModel.fromMap(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch user by id');
  }
}
