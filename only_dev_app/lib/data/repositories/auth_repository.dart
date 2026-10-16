import '../datasources/auth_remote_data_source.dart';
import '../models/models.dart';

abstract class AuthRepository {
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

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register(String email, String password, String fullName) {
    return _remoteDataSource.register(email, password, fullName);
  }

  @override
  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String idToken,
    required String email,
    required String fullName,
    String? avatarUrl,
  }) {
    return _remoteDataSource.socialAuth(
      provider: provider,
      idToken: idToken,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<UserModel> getMe() {
    return _remoteDataSource.getMe();
  }
}

