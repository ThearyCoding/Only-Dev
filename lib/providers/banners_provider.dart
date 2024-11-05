import '../export/export.dart';

class BannersProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<BannerModel> _banners = [];
  bool _isLoading = false;

  BannersProvider() {
    fetchBanners();
  }

  // Getters for the banners and loading state
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
        notifyListeners(); // Notify listeners about the state change
      });
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
