import '../datasources/user_remote_data_source.dart';
import '../models/models.dart';

abstract class UserRepository {
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

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel> getMyProfile() {
    return _remoteDataSource.getMyProfile();
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? bio,
    String? phoneNumber,
  }) {
    return _remoteDataSource.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
      headline: headline,
      bio: bio,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<UserModel> getUserById(String id) {
    return _remoteDataSource.getUserById(id);
  }
}
