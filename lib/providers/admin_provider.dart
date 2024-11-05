import 'dart:developer';
import 'dart:io';
import '../export/export.dart';
import '../utils/show_error_utils.dart';

class AdminProvider extends ChangeNotifier {
  List<AdminModel> admins = [];
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AdminModel? _admin;
  AdminModel? get admin => _admin;

  AdminProvider() {
    fetchAdmins();
  }

  // Method to fetch admin by ID
  Future<void> fetchAdminById(String adminId) async {
    try {
      // Fetch the admin document from Firestore
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(adminId).get();

      // If the document exists, update the admin variable
      if (doc.exists) {
        _admin = AdminModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        _admin = null; // No admin found
      }
      notifyListeners();
    } catch (e) {
      log('Error fetching admin by ID: $e');
      _admin = null; // Handle error
      notifyListeners();
    }
  }

  void fetchAdmins() {
    try {
      isLoading = true;
      notifyListeners();
      _firestore.collection('admins').snapshots().listen(
        (adminQuery) {
          admins = adminQuery.docs
              .map((doc) => AdminModel.fromJson(doc.data()))
              .toList();
          isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          log('Error fetching admins: $error');
          isLoading = false;
          showSnackbar('An unexpected error occurred. Please try again.');
          notifyListeners();
        },
      ).onError((error) {
        if (error is SocketException) {
          log('No internet connection: $error');
          showSnackbar('No internet connection. Please check your network.');
        } else if (error is TimeoutException) {
          log('Connection timed out: $error');
          showSnackbar('Connection timed out. Please try again.');
        } else {
          log('Unknown error: $error');
          showSnackbar('An unknown error occurred. Please try again.');
        }
        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      log('Error fetching admins: $e');
      showSnackbar('An unexpected error occurred. Please try again.');
      isLoading = false;
      notifyListeners();
    }
  }
}
