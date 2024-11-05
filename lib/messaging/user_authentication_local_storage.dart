

// import '../export/export.dart';

// class LocalStorageSharedPreferences extends GetxController {
//   final RxBool isLoggedIn = false.obs;

//   Future<void> saveUserLoginStatus(bool isLoggedIn) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', isLoggedIn);
//     this.isLoggedIn.value = isLoggedIn; // Update the reactive variable
//   }

//   Future<void> loadUserLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
//     isLoggedIn.value = loggedIn; // Update the reactive variable
//   }
//  Future<void> logoutUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('isLoggedIn'); // Remove the saved login status
//     isLoggedIn.value = false; // Update the reactive variable to false
//   }
//   @override
//   void onInit() {
//     super.onInit();
//     loadUserLoginStatus(); // Load user login status when the controller initializes
//   }
// }
