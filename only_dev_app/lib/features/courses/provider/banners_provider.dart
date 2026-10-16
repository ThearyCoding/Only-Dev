import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/model/banner_model.dart';
import 'package:only_dev_app/service/firebase/firebase_service.dart';
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
      log('Error fetching banners: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
