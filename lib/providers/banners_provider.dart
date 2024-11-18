import 'package:e_leaningapp/di/dependency_injection.dart';

import '../export/export.dart';

class BannersProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = locator<FirebaseService>();
  List<BannerModel> _banners = [];
  bool _isLoading = false;

  BannersProvider() {
    fetchBanners();
  }

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;

  void fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedBannersStream = _firebaseService.fetchBanners();
      fetchedBannersStream.listen((fetchedBanners) {
        _banners = fetchedBanners;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
