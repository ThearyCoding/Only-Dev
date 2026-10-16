import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/auth_repository.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  AuthViewModel(this._authRepository);

  Future<bool> login(String email, String password) async {
    setBusy(true);
    try {
      await _authRepository.login(email.trim(), password);
      _currentUser = await _authRepository.getMe();
      AppToastUtils.success('Welcome back, ${_currentUser?.fullName}!');
      setViewState(ViewState.success);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    setBusy(true);
    try {
      await _authRepository.register(email.trim(), password, fullName.trim());
      _currentUser = await _authRepository.getMe();
      AppToastUtils.success('Account created successfully!');
      setViewState(ViewState.success);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      _currentUser = await _authRepository.getMe();
      notifyListeners();
    } catch (_) {
      _currentUser = null;
    }
  }
}

