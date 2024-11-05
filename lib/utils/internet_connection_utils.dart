import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionUtils {
  static void listenToInternetConnectionStatus(void Function(bool isConnected) onStatusChange) {
    InternetConnectionCheckerPlus().onStatusChange.listen((event) {
      switch (event) {
        case InternetConnectionStatus.connected:
          onStatusChange(true);
          break;
        case InternetConnectionStatus.disconnected:
          onStatusChange(false);
          break;
      }
    });
  }

  static Future<bool> checkInternetConnection() async {
    return await InternetConnectionCheckerPlus().hasConnection;
  }
}
