import 'package:flutter/foundation.dart';
import 'package:only_dev_app/model/user_model.dart';

class AdminProvider extends ChangeNotifier {
  List<UserModel> admins = [];
  bool isLoading = false;
  UserModel? _admin;
  UserModel? get admin => _admin;

  AdminProvider() {
    fetchAdmins();
  }

  void addAdmin(UserModel user) {
    if (!admins.any((a) => a.uid == user.uid)) {
      admins.add(user);
      notifyListeners();
    }
  }

  Future<void> fetchAdminById(String adminId) async {
    _admin = admins.firstWhere(
      (a) => a.uid == adminId,
      orElse: () => UserModel.empty(),
    );
    notifyListeners();
  }

  void fetchAdmins() {
    isLoading = false;
    notifyListeners();
  }
}
