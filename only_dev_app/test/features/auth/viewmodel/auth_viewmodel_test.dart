import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/auth_repository.dart';
import 'package:only_dev_app/features/auth/viewmodel/auth_viewmodel.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldThrowLogin = false;
  bool shouldThrowGetMe = false;
  Map<String, dynamic> loginResponse = {
    'access_token': 'fake_jwt_token',
    'refresh_token': 'fake_refresh_token',
    'user': {'id': 'user_1', 'email': 'student@onlydev.com', 'full_name': 'Theary Chorn'},
  };

  UserModel userToReturn = UserModel(
    uid: 'user_1',
    firstName: 'Theary',
    lastName: 'Chorn',
    fullName: 'Theary Chorn',
    photoURL: '',
    email: 'student@onlydev.com',
    gender: 1,
    dob: '',
    bgColor: '',
    backgroundColor: '',
    role: 'STUDENT',
  );

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (shouldThrowLogin) {
      throw Exception('Invalid email or password');
    }
    return loginResponse;
  }

  @override
  Future<UserModel> getMe() async {
    if (shouldThrowGetMe) {
      throw Exception('Authentication required. Missing or invalid Bearer token.');
    }
    return userToReturn;
  }

  @override
  Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    return loginResponse;
  }

  @override
  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String idToken,
    required String email,
    required String fullName,
    String? avatarUrl,
  }) async {
    return loginResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthViewModel Unit Tests', () {
    late FakeAuthRepository fakeRepository;
    late AuthViewModel viewModel;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      viewModel = AuthViewModel(fakeRepository);
    });

    test('Initial state should not be authenticated', () {
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.state, equals(ViewState.idle));
    });

    test('login success sets currentUser and returns true', () async {
      final success = await viewModel.login('student@onlydev.com', 'password123');

      expect(success, isTrue);
      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.currentUser?.email, equals('student@onlydev.com'));
      expect(viewModel.currentUser?.fullName, equals('Theary Chorn'));
      expect(viewModel.state, equals(ViewState.success));
    });

    test('login failure when repository throws', () async {
      fakeRepository.shouldThrowLogin = true;

      final success = await viewModel.login('bad@onlydev.com', 'wrong');

      expect(success, isFalse);
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Invalid email or password'));
    });

    test('login failure when getMe throws token error', () async {
      fakeRepository.shouldThrowGetMe = true;

      final success = await viewModel.login('student@onlydev.com', 'password123');

      expect(success, isFalse);
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Missing or invalid Bearer token'));
    });
  });
}
