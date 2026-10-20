import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/features/home/model/home_screen_data.dart';
import 'package:only_dev_app/features/home/repository/home_repository.dart';
import 'package:only_dev_app/model/banner_model.dart';
import 'package:only_dev_app/model/category_model.dart';
import 'package:only_dev_app/model/courses_model.dart';

class HomeViewModel extends BaseViewModel {
  final HomeRepository _homeRepository;

  HomeScreenData? _homeData;
  HomeScreenData? get homeData => _homeData;

  List<BannerModel> get banners => _homeData?.banners ?? [];
  List<CategoryModel> get categories => _homeData?.categories ?? [];
  List<CourseModel> get courses => _homeData?.courses ?? [];
  List<CourseModel> get recentCourses => _homeData?.recentCourses ?? [];
  List<CourseModel> get popularCourses => _homeData?.popularCourses ?? [];

  HomeViewModel(this._homeRepository);

  /// Fetches the entire Home Screen data in a single network call.
  /// Eliminates scattered individual HTTP calls for banners, categories, and courses.
  Future<void> fetchHomeData({bool refresh = false}) async {
    if (_homeData != null && !refresh) return;

    setBusy(true);

    try {
      final data = await _homeRepository.getHomeScreenData();
      _homeData = data;
      setViewState(ViewState.success);
    } catch (e) {
      setError(e.toString());
      setViewState(ViewState.error);
    } finally {
      setBusy(false);
    }
  }
}

