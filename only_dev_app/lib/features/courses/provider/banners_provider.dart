import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:only_dev_app/di/dependency_injection.dart';
import 'package:only_dev_app/features/home/repository/home_repository.dart';
import 'package:only_dev_app/model/banner_model.dart';

class BannersProvider extends ChangeNotifier {
  final HomeRepository _homeRepository = locator<HomeRepository>();
  List<BannerModel> _banners = [];
  bool _isLoading = false;

  BannersProvider() {
    fetchBanners();
  }

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;

  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final homeData = await _homeRepository.getHomeScreenData();
      _banners = homeData.banners;
    } catch (e) {
      log('Error fetching banners from HomeRepository: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
