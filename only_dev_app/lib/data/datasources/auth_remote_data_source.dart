import '../../service/api/api_endpoints.dart';
import '../../service/api/dio_client.dart';
import '../models/models.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String email, String password, String fullName);
  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String idToken,
    required String email,
    required String fullName,
    String? avatarUrl,
  });
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data != null && response.data['data'] != null) {
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();

      if (accessToken != null) {
        await _dioClient.authInterceptor.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return data;
    }
    throw Exception('Login failed');
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();

      if (accessToken != null) {
        await _dioClient.authInterceptor.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return data;
    }
    throw Exception('Registration failed');
  }

  @override
  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String idToken,
    required String email,
    required String fullName,
    String? avatarUrl,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.socialAuth,
      data: {
        'provider': provider,
        'idToken': idToken,
        'email': email,
        'fullName': fullName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();

      if (accessToken != null) {
        await _dioClient.authInterceptor.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return data;
    }
    throw Exception('Social authentication failed');
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dioClient.get(ApiEndpoints.me);
    if (response.data != null && response.data['data'] != null) {
      return UserModel.fromMap(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to get user profile');
  }
}

