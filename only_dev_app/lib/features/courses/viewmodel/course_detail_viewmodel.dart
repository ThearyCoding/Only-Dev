import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:only_dev_app/core/viewmodel/base_viewmodel.dart';
import 'package:only_dev_app/data/models/models.dart';
import 'package:only_dev_app/data/repositories/course_repository.dart';
import 'package:only_dev_app/data/repositories/enrollment_repository.dart';
import 'package:only_dev_app/service/api/api_error_interceptor.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/widgets/app_widgets/app_image_widget.dart';

class CourseDetailViewModel extends BaseViewModel {
  final CourseRepository _courseRepository;
  final EnrollmentRepository _enrollmentRepository;

  CourseModel? _course;
  CourseModel? get course => _course;
  List<Section> get sections => _course?.sections ?? [];

  bool _isEnrolled = false;
  bool get isEnrolled => _isEnrolled;

  Color _dominantColor = Colors.blueGrey;
  Color get dominantColor => _dominantColor;

  bool _isBottomSheetVisible = true;
  bool get isBottomSheetVisible => _isBottomSheetVisible;

  bool _showTitleInAppBar = false;
  bool get showTitleInAppBar => _showTitleInAppBar;

  String? _firstVideoUrl;
  String? get firstVideoUrl => _firstVideoUrl;

  int _totalLectures = 0;
  int get totalLectures => _totalLectures;

  final int _totalQuizQuestions = 0;
  int get totalQuizQuestions => _totalQuizQuestions;

  CourseDetailViewModel(this._courseRepository, this._enrollmentRepository);

  Future<void> init(String courseId, {CourseModel? initialCourse}) async {
    if (initialCourse != null) {
      _course = initialCourse;
      _isEnrolled = initialCourse.isEnrolled;
      _extractDominantColor(initialCourse.imageUrl);
    }

    setBusy(true);
    try {
      _course = await _courseRepository.getCourseById(courseId);

      bool isEnrolled = _course?.isEnrolled ?? false;
      if (!isEnrolled) {
        try {
          isEnrolled = await _enrollmentRepository.checkEnrollment(courseId);
        } catch (_) {
          isEnrolled = false;
        }
      }
      _isEnrolled = isEnrolled;

      if (_course != null) {
        _totalLectures = _course!.totalLessons ?? 0;
        _extractDominantColor(_course!.imageUrl);
        if (_course!.sections != null && _course!.sections!.isNotEmpty) {
          for (final sec in _course!.sections!) {
            final firstWithVid = sec.lectures.where((l) => l.videoUrl.isNotEmpty).firstOrNull;
            if (firstWithVid != null) {
              _firstVideoUrl = firstWithVid.videoUrl;
              break;
            }
          }
        }
      }
      setViewState(ViewState.success);
    } catch (e) {
      setError(ApiErrorInterceptor.extractErrorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  void setBottomSheetVisible(bool visible) {
    if (_isBottomSheetVisible == visible || isDisposed) return;
    _isBottomSheetVisible = visible;
    notifyListeners();
  }

  void setShowTitleInAppBar(bool show) {
    if (_showTitleInAppBar == show || isDisposed) return;
    _showTitleInAppBar = show;
    notifyListeners();
  }

  Future<void> _extractDominantColor(String imageUrl) async {
    final imageProvider = AppImageWidget.safeNetworkImageProvider(imageUrl);
    if (imageProvider == null) return;
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );
      if (!isDisposed) {
        _dominantColor = paletteGenerator.dominantColor?.color ?? Colors.blueGrey;
        notifyListeners();
      }
    } catch (_) {
      _dominantColor = Colors.blueGrey;
    }
  }

  Future<bool> enrollInCourse() async {
    if (_course == null) return false;

    setBusy(true);
    try {
      await _enrollmentRepository.enroll(_course!.id);
      _isEnrolled = true;
      AppToastUtils.success('Successfully enrolled in ${_course!.title}!');
      notifyListeners();
      return true;
    } catch (e) {
      setError(ApiErrorInterceptor.extractErrorMessage(e));
      return false;
    } finally {
      setBusy(false);
    }
  }
}

