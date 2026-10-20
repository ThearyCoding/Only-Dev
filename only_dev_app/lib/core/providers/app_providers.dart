import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/api/dio_client.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../di/dependency_injection.dart';
import '../../model/user_model.dart';
import '../../model/post_model.dart';
import '../../service/shared/shared_preferences_service.dart';
import '../../features/courses/provider/course_content_notifier.dart';
export '../../features/courses/provider/course_content_notifier.dart';

import '../../features/auth/provider/auth_provider.dart';
import '../../features/common/provider/internet_connection_provider.dart';
import '../../features/courses/provider/admin_provider.dart';
import '../../features/courses/provider/course_list_provider.dart';
import '../../features/courses/provider/banners_provider.dart';
import '../../features/courses/provider/categories_provider.dart';
import '../../features/courses/provider/course_provider.dart';
import '../../features/courses/provider/lecture_provider.dart';
import '../../features/enrollments/provider/enrollment_provider.dart';
import '../../features/enrollments/provider/registration_provider.dart';
import '../../features/notifications/provider/notification_provider.dart';
import '../../features/profile/provider/user_provider.dart';
import '../../features/quizzes/provider/quiz_provider.dart';
import '../../features/search/provider/search_engine_provider.dart';
import '../../features/settings/provider/language_provider.dart';
import '../../features/settings/provider/theme_provider.dart';

// ==========================================
// 1. Core Repository Providers
// ==========================================
final userRepositoryProvider =
    Provider<UserRepository>((ref) => locator<UserRepository>());

final storageRepositoryProvider =
    Provider<StorageRepository>((ref) => locator<StorageRepository>());

final courseRepositoryProvider =
    Provider<CourseRepository>((ref) => locator<CourseRepository>());

final enrollmentRepositoryProvider =
    Provider<EnrollmentRepository>((ref) => locator<EnrollmentRepository>());

final quizRepositoryProvider =
    Provider<QuizRepository>((ref) => locator<QuizRepository>());

final postRepositoryProvider =
    Provider<PostRepository>((ref) => locator<PostRepository>());

final postsListProvider =
    FutureProvider.autoDispose<List<PostModel>>((ref) {
  return ref.watch(postRepositoryProvider).getPosts();
});

final postDetailProvider =
    FutureProvider.autoDispose.family<PostModel?, String>((ref, id) {
  return ref.watch(postRepositoryProvider).getPostById(id);
});

// ==========================================
// 2. User Profile State & Notifier
// ==========================================
class UserProfileState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? avatarUrl;

  const UserProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.avatarUrl,
  });

  UserProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? avatarUrl,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserRepository _userRepo;
  final StorageRepository _storageRepo;

  UserProfileNotifier(this._userRepo, this._storageRepo)
      : super(const UserProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final token = locator<DioClient>().authInterceptor.token;
    final firebaseUser = locator<FirebaseAuth>().currentUser;
    if ((token == null || token.isEmpty) && firebaseUser == null) {
      state = state.copyWith(user: null, isLoading: false, error: null);
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _userRepo.getMyProfile();
      state = state.copyWith(
        user: profile,
        avatarUrl: profile.avatarUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? bio,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final computedFullName = fullName ??
          (firstName != null && lastName != null
              ? '$firstName $lastName'.trim()
              : firstName ?? lastName);

      final updated = await _userRepo.updateProfile(
        fullName: computedFullName,
        avatarUrl: avatarUrl ?? state.avatarUrl,
        headline: headline,
        bio: bio,
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(
        user: updated,
        avatarUrl: updated.avatarUrl,
        isLoading: false,
      );
      return updated;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<String> uploadAvatar(File file) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final url = await _storageRepo.uploadFile(file, folder: 'user_images');
      await updateProfile(avatarUrl: url);
      state = state.copyWith(avatarUrl: url, isLoading: false);
      return url;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(
    ref.watch(userRepositoryProvider),
    ref.watch(storageRepositoryProvider),
  );
});

// ==========================================
// 3. Complete Information Form State & Notifier
// ==========================================
class CompleteInfoState {
  final String firstName;
  final String lastName;
  final String? gender;
  final String? photoUrl;
  final DateTime? selectedDate;
  final bool isLoading;
  final bool isFormValid;

  const CompleteInfoState({
    this.firstName = '',
    this.lastName = '',
    this.gender,
    this.photoUrl,
    this.selectedDate,
    this.isLoading = false,
    this.isFormValid = false,
  });

  CompleteInfoState copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    String? photoUrl,
    DateTime? selectedDate,
    bool? isLoading,
    bool? isFormValid,
  }) {
    return CompleteInfoState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class CompleteInfoNotifier extends StateNotifier<CompleteInfoState> {
  final UserProfileNotifier _userProfileNotifier;

  CompleteInfoNotifier(this._userProfileNotifier, {String? initialPhotoUrl, DateTime? initialDate})
      : super(CompleteInfoState(photoUrl: initialPhotoUrl, selectedDate: initialDate ?? DateTime(2006, 1, 5)));

  void updateNames(String firstName, String lastName) {
    final valid = firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        state.gender != null;
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      isFormValid: valid,
    );
  }

  void setGender(String? gender) {
    final valid = state.firstName.trim().isNotEmpty &&
        state.lastName.trim().isNotEmpty &&
        gender != null;
    state = state.copyWith(gender: gender, isFormValid: valid);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setPhotoUrl(String? photoUrl) {
    state = state.copyWith(photoUrl: photoUrl);
  }

  Future<void> uploadAvatar(File imageFile) async {
    state = state.copyWith(isLoading: true);
    try {
      final downloadUrl = await _userProfileNotifier.uploadAvatar(imageFile);
      state = state.copyWith(photoUrl: downloadUrl, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> saveProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      await _userProfileNotifier.updateProfile(
        firstName: state.firstName,
        lastName: state.lastName,
        avatarUrl: state.photoUrl,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final completeInfoProvider =
    StateNotifierProvider.autoDispose<CompleteInfoNotifier, CompleteInfoState>(
        (ref) {
  final userProfileNotifier = ref.watch(userProfileProvider.notifier);
  final userProfileState = ref.watch(userProfileProvider);
  return CompleteInfoNotifier(
    userProfileNotifier,
    initialPhotoUrl: userProfileState.avatarUrl,
  );
});

// ==========================================
// 4. Post Editor State & Notifier
// ==========================================
class PostEditorSection {
  final String id;
  final String type; // 'text' or 'image'
  final String content; // for image, local file path

  const PostEditorSection({
    required this.id,
    required this.type,
    this.content = '',
  });

  PostEditorSection copyWith({
    String? id,
    String? type,
    String? content,
  }) {
    return PostEditorSection(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
    );
  }
}

class PostEditorState {
  final List<PostEditorSection> sections;
  final bool isSubmitting;
  final String? error;

  const PostEditorState({
    this.sections = const [],
    this.isSubmitting = false,
    this.error,
  });

  PostEditorState copyWith({
    List<PostEditorSection>? sections,
    bool? isSubmitting,
    String? error,
  }) {
    return PostEditorState(
      sections: sections ?? this.sections,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class PostEditorNotifier extends StateNotifier<PostEditorState> {
  final PostRepository _postRepo;
  final StorageRepository _storageRepo;
  final Ref _ref;

  PostEditorNotifier(this._postRepo, this._storageRepo, this._ref)
      : super(const PostEditorState());

  void addTextSection() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = state.copyWith(sections: [
      ...state.sections,
      PostEditorSection(id: id, type: 'text'),
    ]);
  }

  void addImageSection(String filePath) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = state.copyWith(sections: [
      ...state.sections,
      PostEditorSection(id: id, type: 'image', content: filePath),
    ]);
  }

  void removeSection(String id) {
    state = state.copyWith(
      sections: state.sections.where((s) => s.id != id).toList(),
    );
  }

  void clear() {
    state = const PostEditorState();
  }

  Future<PostModel> savePost({
    required String title,
    required Map<String, String> textContents,
  }) async {
    if (title.trim().isEmpty || state.sections.isEmpty) {
      throw Exception('Title and at least one content section are required!');
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final List<Map<String, dynamic>> contentList = [];
      String? contentPreview;

      for (var section in state.sections) {
        if (section.type == 'text') {
          final text = textContents[section.id] ?? '';
          contentList.add({
            'type': 'text',
            'content': text,
          });
          if (contentPreview == null && text.trim().isNotEmpty) {
            contentPreview = text.trim();
          }
        } else if (section.type == 'image') {
          final imageUrl = await _storageRepo.uploadFile(
            File(section.content),
            folder: 'posts',
          );
          contentList.add({
            'type': 'image',
            'url': imageUrl,
          });
        }
      }

      contentPreview ??= 'No content available';

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final newPost = PostModel(
        id: id,
        title: title.trim(),
        contentPreview: contentPreview,
        contentSections: contentList,
        createdAt: DateTime.now().toIso8601String(),
      );

      final result = await _postRepo.createPost(newPost);
      _ref.invalidate(postsListProvider);
      state = const PostEditorState();
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

final postEditorProvider =
    StateNotifierProvider.autoDispose<PostEditorNotifier, PostEditorState>((ref) {
  return PostEditorNotifier(
    ref.watch(postRepositoryProvider),
    ref.watch(storageRepositoryProvider),
    ref,
  );
});

// ==========================================
// 6. Course Content & Streaming Video Provider
// ==========================================

final courseContentNotifierProvider = StateNotifierProvider.autoDispose
    .family<CourseContentNotifier, CourseContentState, CourseContentParams>((ref, params) {
  return CourseContentNotifier(
    courseRepository: ref.watch(courseRepositoryProvider),
    enrollmentRepository: ref.watch(enrollmentRepositoryProvider),
    quizRepository: ref.watch(quizRepositoryProvider),
    sharedPreferencesService: locator<SharedPreferencesService>(),
    courseId: params.courseId,
    categoryId: params.categoryId,
  );
});

// ==========================================
// 7. Global Application Riverpod Providers
// ==========================================
final internetConnectionNotifierProvider =
    ChangeNotifierProvider<InternetConnectionProvider>((ref) {
  return InternetConnectionProvider();
});

final authNotifierProvider =
    ChangeNotifierProvider<AuthenticationProvider>((ref) {
  return AuthenticationProvider();
});

final userNotifierProvider = ChangeNotifierProvider<UserProvider>((ref) {
  return UserProvider(ref.watch(authNotifierProvider));
});

final themeNotifierProvider =
    ChangeNotifierProvider<CustomizeThemeProvider>((ref) {
  return CustomizeThemeProvider();
});

final languageNotifierProvider =
    ChangeNotifierProvider<LanguageProvider>((ref) {
  return LanguageProvider();
});

final registrationNotifierProvider =
    ChangeNotifierProvider<RegistrationProvider>((ref) {
  return RegistrationProvider();
});

final notificationNotifierProvider =
    ChangeNotifierProvider<NotificationProvider>((ref) {
  return NotificationProvider();
});

final courseNotifierProvider = ChangeNotifierProvider<CourseProvider>((ref) {
  return CourseProvider();
});

final categoriesNotifierProvider =
    ChangeNotifierProvider<CategoriesProvider>((ref) {
  return CategoriesProvider();
});

final bannersNotifierProvider = ChangeNotifierProvider<BannersProvider>((ref) {
  return BannersProvider();
});

final quizNotifierProvider = ChangeNotifierProvider<QuizProvider>((ref) {
  return QuizProvider();
});

final lectureNotifierProvider = ChangeNotifierProvider<LectureProvider>((ref) {
  return LectureProvider();
});

final adminNotifierProvider = ChangeNotifierProvider<AdminProvider>((ref) {
  return AdminProvider();
});

final enrollmentNotifierProvider =
    ChangeNotifierProvider<EnrollmentProvider>((ref) {
  return EnrollmentProvider();
});

final searchEngineNotifierProvider =
    ChangeNotifierProvider<SearchEngineProvider>((ref) {
  return SearchEngineProvider();
});

final courseListNotifierProvider =
    ChangeNotifierProvider<CourseListProvider>((ref) {
  return CourseListProvider();
});

