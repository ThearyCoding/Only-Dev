# Only-Dev Migration & Implementation Progress Tracker

This document tracks all completed milestones, current architectural implementations, and pending tasks across the **`only_dev_api`** backend and **`only_dev_app`** Flutter mobile client.

---

## 📊 High-Level Summary Status

| Component | Target Stack | Status | Verification |
| :--- | :--- | :---: | :--- |
| **Flutter Stability & Fixes** | Flutter 3.24+, Dart | ✅ Completed | 0 analyze errors, iOS Simulator verified |
| **Monorepo Architecture** | Monorepo (`api` + `app`) | ✅ Completed | Both build independently from root |
| **NestJS Backend Core** | NestJS, TypeScript, Node.js | ✅ Completed | `npm run build` passes with 0 errors |
| **Dynamic RBAC Engine** | MongoDB, Redis, Guards | ✅ Completed | Dynamic roles, runtime custom permissions |
| **Unified User Schema** | Mongoose (single table) | ✅ Completed | No separate admin table; user-level overrides |
| **Enrollments & Progress** | MongoDB Compound Index | ✅ Completed | Replaces legacy `registrations` |
| **Cloudflare R2 Storage** | AWS S3 SDK, Presigned URLs | ✅ Completed | Zero-egress upload flow configured |
| **Flutter Dio Client** | Dio, Interceptors, ToastUtils | ✅ Completed | `DioClient`, `AuthInterceptor`, `ApiErrorInterceptor` |
| **Flutter Model Decoupling** | Pure Dart, JSON serialization | ✅ Completed | Decoupled `CourseModel`, `UserModel`, `EnrollmentModel` |
| **Enrollment Provider** | Provider, Dio REST calls | ✅ Completed | Replaces `RegistrationProvider`, registered in DI |
| **Feature-First MVVM Migration** | BaseView, ViewModels, Feature Views | ✅ Completed | Courses, Enrollments, Auth Views migrated |
| **Barrel Export Elimination** | Direct Explicit Package Imports | ✅ Completed | `lib/export` completely removed, 0 cyclic imports |
| **Screens & Providers to Features** | Domain Feature Packaging | ✅ Completed | `lib/screens` & `lib/providers` deleted; all moved to `features/` |
| **Model Cleanup** | Active Models Preservation | ✅ Completed | Removed dead models (`course_admin_model`, `quiz_question`) |
| **AdminModel Elimination** | Unified `UserModel` & RBAC | ✅ Completed | `admin_model.dart` deleted, all UI uses `UserModel` |
| **Automated Testing Suite** | Flutter Tests & Vitest Units | ✅ Completed | 9 Flutter unit/widget tests, 12 NestJS tests passing |
| **`snake_case` API Key Standard** | TransformInterceptor & Dart Models | ✅ Completed | Response keys & model maps fully snake_cased |
| **Screen-Aggregated API Pattern** | BFF Endpoint (`GET /home`) | ✅ Completed | 1 call aggregates banners, categories, courses |
| **Complete Firestore Elimination** | Zero Firestore, Pure REST/Local | ✅ Completed | `cloud_firestore` removed, 0 imports in app |
| **Riverpod Migration & No-setState Rule** | `flutter_riverpod` 2.6.1 | ✅ Completed | Zero `setState`, zero direct repo calls in UI |
| **Database Seeder & Real Videos** | Mongoose, Verified MP4 & HLS | ✅ Completed | 5 courses, 18 lessons, real videos, quizzes, enrollments |
| **End-to-End API Integration** | Mobile $\leftrightarrow$ NestJS REST API | ⏳ In Progress | Phase 6 |

---

## ✅ Phase 1: Flutter Bug Fixes & Code Cleanup (Completed)

- [x] **Invisible Toast Text Fix**:
  - Resolved dark mode contrast collision in [`only_dev_app/lib/utils/app_toast_utils.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/utils/app_toast_utils.dart) by forcing `#1E293B` dark text on white/pastel toast card containers.
- [x] **Route `_TypeError` on `User` Cast**:
  - Guarded type casting in [`only_dev_app/lib/routes/app_routes.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/routes/app_routes.dart) with fallback to `FirebaseAuth.instance.currentUser` and route parameter safety.
- [x] **Firebase Messaging iOS Simulator Crash**:
  - Wrapped `getToken()` and APNs initialization in guarded try-catches in `firebase_api_user.dart` and `firebase_messaging_service.dart`.
- [x] **`AssetManifest.json` Missing Error**:
  - Upgraded `google_fonts` to `^6.3.3` to support Flutter's new `AssetManifest.bin` binary loader.
- [x] **`setState() called after dispose()` Memory Leaks**:
  - Added `if (!mounted) return;` across all asynchronous callbacks and detached scroll listeners in [`detail_course_screen.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/screens/course-screen/detail_course_screen.dart).
- [x] **Toast Utilities Cleanup**:
  - Safely removed obsolete `show_error_utils.dart` and `toast_utils.dart`, standardizing on `AppToastUtils`.

---

## ✅ Phase 2: Monorepo Organization & Restructuring (Completed)

- [x] **Monorepo Directory Layout**:
  - Created root `only_dev` structure separating backend and mobile:
    - [`only_dev_api/`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api) (NestJS API)
    - [`only_dev_app/`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app) (Flutter App)
    - [`docs/`](file:///Users/theary.chorn/Documents/Only-Dev/docs) (Technical documentation)
- [x] **Package Renaming**:
  - Updated backend `package.json` name to `"only_dev_api"`.
  - Updated Flutter `pubspec.yaml` name to `"only_dev_app"`.
- [x] **Import Path Refactor**:
  - Migrated all 78 import references across `lib/` and `test/` from `package:e_leaningapp` to `package:only_dev_app`.
- [x] **Compilation Verification**:
  - `only_dev_app`: `flutter pub get` and `flutter build ios --simulator --no-codesign` succeeded in 302s.
  - `only_dev_api`: `npm run build` succeeded with 0 errors.

---

## ✅ Phase 3: NestJS Backend Core & Dynamic RBAC (Completed)

### 3.1 Dynamic Customizable RBAC
- [x] **Dynamic Role Model**:
  - Created [`only_dev_api/src/features/roles/schemas/role.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/roles/schemas/role.schema.ts).
  - Seeded default roles on startup: `SUPER_ADMIN` (wildcard `*`), `ADMIN`, `INSTRUCTOR`, `ASSISTANT`, `STUDENT`.
  - Allowed dynamic creation and modification of custom roles at runtime via API.
- [x] **Dynamic RBAC Guard**:
  - Implemented [`only_dev_api/src/common/guards/roles.guard.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/common/guards/roles.guard.ts) supporting `@Roles(...)`, `@RequirePermissions(...)`, and Redis permission caching.
- [x] **Role Controller Endpoints**:
  - `GET /api/v1/roles` (List all active roles)
  - `POST /api/v1/roles` (Create new custom role)
  - `PUT /api/v1/roles/:id` (Update permissions of a role)
  - `GET /api/v1/roles/permissions/available` (Available platform permissions catalog)

### 3.2 Unified User Schema (No Separate Admin Table)
- [x] **Single User Table**:
  - Created [`only_dev_api/src/features/users/schemas/user.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/users/schemas/user.schema.ts).
  - Controlled administrative access via `role` property and `customPermissions` overrides.
- [x] **User Management Endpoints**:
  - `GET /api/v1/users/me` (Profile)
  - `PATCH /api/v1/users/me` (Update profile)
  - `GET /api/v1/users` (List users with search & role filters)
  - `PATCH /api/v1/users/:id/role` (Assign role to user)
  - `PATCH /api/v1/users/:id/permissions` (Set individual permission overrides)

### 3.3 Auth Feature Module
- [x] **Authentication Engine**:
  - Implemented [`only_dev_api/src/features/auth/service/auth.service.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/auth/service/auth.service.ts) with `bcryptjs` password hashing and Passport JWT strategy.
  - Endpoints:
    - `POST /api/v1/auth/register`
    - `POST /api/v1/auth/login`
    - `POST /api/v1/auth/social` (Google / Apple tokens)
    - `POST /api/v1/auth/refresh`
    - `GET /api/v1/auth/me`

### 3.4 Courses & Polymorphic Curriculum
- [x] **Course & Section Schemas**:
  - Created [`course.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/courses/schemas/course.schema.ts) and [`section.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/courses/schemas/section.schema.ts).
  - Supports video (Cloudflare R2 + HLS), markdown articles, downloadable resources, and quizzes.
- [x] **Course Endpoints**:
  - `GET /api/v1/courses` (Cached in Redis, filtered by category/level)
  - `GET /api/v1/courses/:id` (Course details with curriculum)
  - `POST /api/v1/courses` (Instructor create)
  - `PUT /api/v1/courses/:id` (Instructor/Admin update)
  - `POST /api/v1/courses/:id/sections` (Curriculum structure)

### 3.5 Course Enrollments & Progress
- [x] **Domain Renamed to `enrollments`**:
  - Legacy `registrations` retired.
  - Implemented [`enrollment.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/enrollments/schemas/enrollment.schema.ts) with compound unique index `{ userId: 1, courseId: 1 }`.
  - Implemented [`progress.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/enrollments/schemas/progress.schema.ts) tracking completion percentage ($0-100\%$) and playback resume points.
- [x] **Enrollment Endpoints**:
  - `POST /api/v1/enrollments` (Enroll in course)
  - `GET /api/v1/enrollments/my-courses` (User enrolled courses with progress)
  - `GET /api/v1/enrollments/check/:courseId` (Enrollment check)
  - `POST /api/v1/enrollments/progress/:courseId` (Update playback position & completed lessons)

### 3.6 Cloudflare R2 Storage Service
- [x] **Direct S3 Upload Presigner**:
  - Implemented [`storage.service.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/storage/service/storage.service.ts) using `@aws-sdk/client-s3` and `@aws-sdk/s3-request-presigner`.
  - Endpoint: `POST /api/v1/storage/presign` (Generates zero-egress signed upload URLs).

### 3.7 Assessment & Dynamic Quizzes
- [x] **Quiz Engine**:
  - Created [`quiz.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/quizzes/schemas/quiz.schema.ts) and [`quiz-submission.schema.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/quizzes/schemas/quiz-submission.schema.ts).
  - Cheat-proof student masking (hides correct answers in HTTP response).
  - Automated grading and attempt limits.

---

## ✅ Phase 4: Flutter Dio Client & Model Decoupling (Completed)

- [x] **Create `DioClient` Architecture in `only_dev_app/lib/service/api/`**:
  - Implemented [`dio_client.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/service/api/dio_client.dart) with platform-aware base URL resolution, 15s timeouts, and direct Cloudflare R2 streaming upload support.
  - Implemented [`auth_interceptor.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/service/api/auth_interceptor.dart) to automatically attach JWT Bearer tokens from `SharedPreferences`.
  - Implemented [`api_error_interceptor.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/service/api/api_error_interceptor.dart) with automatic error toast notifications via `AppToastUtils.error(message)`.
  - Implemented [`api_endpoints.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/service/api/api_endpoints.dart) defining all backend API endpoints.
  - Registered `DioClient` singleton in GetIt service locator ([`dependency_injection.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/di/dependency_injection.dart)).

- [x] **Decouple Flutter Data Models**:
  - Refactored [`courses_model.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/model/courses_model.dart): Eliminated `cloud_firestore` dependency, added safe `_parseDateTime` handler, supported MongoDB `_id`, Cloudflare R2 `thumbnailUrl`, `enrollmentCounts`, and modern LMS analytics fields.
  - Refactored [`user_model.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/model/user_model.dart): Added unified dynamic `role`, `customPermissions`, headline, bio, and safe date parser.
  - Created [`enrollment_model.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/model/enrollment_model.dart): Implemented modern enrollment record with payment tracking, completion percentage, and backward-compatible getters for existing UI widgets.
  - Refactored [`registration_model.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/model/registration_model.dart) to safely bridge to `EnrollmentModel`.

- [x] **Implement `EnrollmentProvider`**:
  - Created [`enrollment_provider.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/providers/enrollment_provider.dart) with `fetchMyEnrollments()`, `enrollCourse()`, `checkEnrollment()`, and `updateLessonProgress()`.
  - Exported in [`provider_export.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/export/provider_export.dart) and registered in [`provider_setup.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/providers/provider_setup.dart).
  - Maintained backward-compatible aliases so existing registration cards and course buttons continue functioning seamlessly.

---

## ✅ Phase 5: Feature-First MVVM Architecture & Screen Migration (Completed)

- [x] **MVVM Core Foundation**:
  - Implemented [`base_viewmodel.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/core/viewmodel/base_viewmodel.dart) with reactive `ViewState` (`idle`, `busy`, `error`, `success`), error dispatching, and safe disposed checks.
  - Implemented [`base_view.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/core/viewmodel/base_view.dart) integrating `Consumer<T>` and automatic lifecycle binding with `GetIt` and `dispose()`.
- [x] **DataSources & Repositories**:
  - Implemented `AuthRemoteDataSource` & `AuthRepository`.
  - Implemented `CourseRemoteDataSource` & `CourseRepository`.
  - Implemented `EnrollmentRemoteDataSource` & `EnrollmentRepository`.
- [x] **Feature ViewModels**:
  - Implemented [`detail_course_viewmodel.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/viewmodel/detail_course_viewmodel.dart) (course details, dominant color generation, enrollment state, app bar title sync).
  - Implemented [`courses_viewmodel.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/viewmodel/courses_viewmodel.dart) (catalog, category filtering, pagination, infinite scroll).
  - Implemented [`enrollments_viewmodel.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/enrollments/viewmodel/enrollments_viewmodel.dart) (ongoing vs completed enrollments, playback progress updates).
  - Implemented [`auth_viewmodel.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/auth/viewmodel/auth_viewmodel.dart) (login, register, token management, me profile).
- [x] **Feature Views Migration**:
  - Created [`detail_course_view.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/view/detail_course_view.dart) using `BaseView<DetailCourseViewModel>`.
  - Created [`courses_view.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/view/courses_view.dart) using `BaseView<CoursesViewModel>` with pull-to-refresh & pagination.
  - Created [`my_courses_view.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/enrollments/view/my_courses_view.dart) using `BaseView<EnrollmentsViewModel>` with ongoing, downloaded, and completed tabs.
  - Created [`login_view.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/auth/view/login_view.dart) & [`register_view.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/auth/view/register_view.dart).
  - Maintained zero-breaking changes with typedef aliases in [`detail_course_screen.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/screens/course-screen/detail_course_screen.dart), [`courses_screent.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/screens/course-screen/courses_screent.dart), and [`my_courses_screen.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/screens/course-screen/my_courses_screen.dart).
- [x] **Barrel Export Directory Elimination (`lib/export/`)**:
  - Removed all circular barrel export files: `export.dart`, `app_routes_export.dart`, `curriculum_export.dart`, `provider_export.dart`, `topic_export.dart`, `video_service_export.dart`, `detail_export.dart`, and `mvvm_export.dart`.
  - Refactored all 55+ dependent files across `di/`, `providers/`, `screens/`, `widgets/`, `routes/`, and `service/` to use explicit, direct package and file imports.
  - Safely deleted directory `/Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/export`.
  - Verified `dart analyze lib/ --no-fatal-warnings` passes with **0 errors** and **0 warnings**.
- [x] **Feature-First Screens & Providers Reorganization**:
  - Moved all 34 screens from legacy `lib/screens/` into domain-specific feature views under `lib/features/<feature>/view/` (`auth`, `courses`, `enrollments`, `quizzes`, `profile`, `notifications`, `search`, `settings`, `cart`, `posts`, `home`, `common`).
  - Moved all 17 state providers from `lib/providers/` into domain-specific feature provider directories under `lib/features/<feature>/provider/`.
  - Relocated root `provider_setup.dart` to `lib/features/provider_setup.dart`.
  - Safely deleted legacy directories `lib/screens/` and `lib/providers/`.
- [x] **Root Models Cleanup (`lib/model/`)**:
  - Identified and safely removed unused models: `course_admin_model.dart` and `quiz_question.dart`.
  - Updated `lib/data/models/models.dart` to omit deleted models.
  - Retained all 11 actively utilized domain models.
- [x] **Automated Testing Suites**:
  - Implemented NestJS unit tests with Vitest:
    - [`only_dev_api/src/app.controller.spec.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/app.controller.spec.ts) (health endpoint verification).
    - [`only_dev_api/src/features/roles/service/roles.service.spec.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/features/roles/service/roles.service.spec.ts) (Mongoose model mocking, Redis caching, RBAC role query tests).
    - Verified `npm run test` executes with **8/8 tests passing**.
  - Implemented Flutter unit & widget tests:
    - [`only_dev_app/test/features/courses/viewmodel/courses_viewmodel_test.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/test/features/courses/viewmodel/courses_viewmodel_test.dart) (`BaseViewModel` state transitions: `idle`, `busy`, `success`, `error`, pagination).
    - [`only_dev_app/test/widget_test.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/test/widget_test.dart) (`ErrorScreen` widget rendering test).
    - Verified `flutter test` executes with **5/5 tests passing**.
- [x] **`snake_case` Serialization & Standard Enforcement**:
  - NestJS API: Implemented recursive `keysToSnakeCase` in [`only_dev_api/src/common/interceptors/transform.interceptor.ts`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_api/src/common/interceptors/transform.interceptor.ts) so every HTTP JSON response payload automatically emits single `snake_case` keys (including `status_code` in response envelopes and error filters).
  - Flutter Models: Updated all active domain models in `lib/model/` (`CourseModel`, `UserModel`, `EnrollmentModel`, `Lecture`, `Section`, `NotificationModel`, `RegistrationModel`, `CategoryModel`, `BannerModel`, `PostModel`, `AdminModel`) to emit **strictly single `snake_case` keys** in `toMap()` and `toJson()`, completely eliminating duplicate camelCase keys.
  - Persisted Rule 11 (Testing Strategy) and Rule 12 (`snake_case` Standard & No Duplicate Keys) across `.agents/rules/` and `docs/`.
- [x] **String Date Formatting & Audit Fields (`createdAt`, `updatedAt`, `createdBy`, `updatedBy`)**:
  - **No `DateTime` in Models**: Removed all `DateTime` and Firestore `Timestamp` types from client data models; backend formats dates to ISO strings (`obj.toISOString()`).
  - **Removed `timestamp` Completely**: Removed `timestamp` from constructors, stored fields, map serialization payloads, and getters across all models; updated all UI widgets and providers to consume `createdAt` directly.
  - **Client Utility Verification**: Updated `time_utils.dart`, `notification_provider.dart`, `registration_provider.dart`, `course_content_screen.dart`, `build_course_card_widget_ui_v1.dart`, `build_course_card_widget_ui_v2.dart`, and profile screens to consume string timestamps safely.
  - **Verified Quality**: Both `flutter test` and `npm run test` pass, and `npm run build` compiles with 0 errors.
- [x] **Zero `AdminModel` / Unified RBAC `UserModel` Migration**:
  - **Deleted `admin_model.dart`**: Fully removed `admin_model.dart` and its export from `models.dart`.
  - **Equipped `UserModel`**: Added compatibility aliases (`id`, `name`, `imageUrl`, and `empty()` factory) to [`only_dev_app/lib/model/user_model.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/model/user_model.dart).
  - **Refactored UI & Providers**: Updated all course cards, search screens, course views, `AdminProvider`, `CourseProvider`, and `AllCoursesProvider` to utilize `UserModel` directly with 0 errors.
- [x] **Screen-Aggregated API Pattern (Single Screen = Single Endpoint)**:
  - **Enforced Architectural Rule 13**: Updated `.agents/rules/flutter_mvvm_rules.md`, `.agents/rules/nestjs_backend_rules.md`, and `docs/flutter_coding_rules.md`. Prohibits making multiple scattered API calls for a single screen.
  - **NestJS `HomeModule` & `HomeController`**: Exposes composite `GET /home` (and alias `GET /home/get-home`) returning aggregated `{ banners, categories, courses, recent_courses, popular_courses }` with Redis caching (`screen:home`, 300s TTL).
  - **Flutter `HomeScreenData` & `HomeViewModel`**: Implemented `HomeScreenData`, `HomeRemoteDataSource` (Dio-based), `HomeRepository`, and `HomeViewModel` to load the entire screen dataset in one request.
  - **Testing**: Added Vitest tests for `HomeService` (12/12 API tests passing) and Flutter tests for `HomeViewModel` (9/9 Flutter tests passing).

- [x] **Firebase Storage Elimination & Cloudflare R2 Cutover**:
  - **Removed Dependency**: Completely removed `firebase_storage` package from [`only_dev_app/pubspec.yaml`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/pubspec.yaml) and removed `FirebaseStorage` singleton from `dependency_injection.dart`.
  - **Presigned Upload Flow**: Built [`StorageRemoteDataSource`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/data/datasources/storage_remote_data_source.dart) and [`StorageRepository`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/data/repositories/storage_repository.dart) to request presigned upload URLs from NestJS (`POST /storage/presign`) and stream binary files directly to Cloudflare R2 via Dio.
  - **Upload Handlers Updated**: Converted [`FirebaseApiStorage`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/service/firebase/firebase_api_storage.dart), profile screens, and [`post_editor_screen.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/posts/view/post_editor_screen.dart) to use Cloudflare R2 with `EasyLoading` progress tracking.
  - **Dead Code Removed**: Safely removed dead file `upload_video.dart`.
- [x] **Home Screen Cutover to REST API**:
  - **Banners & Categories**: Rewrote [`BannersProvider`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/provider/banners_provider.dart) and [`CategoriesProvider`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/provider/categories_provider.dart) to load from `HomeRepository` (`GET /home`), eliminating Firestore streams.
  - **Courses**: Updated [`CourseProvider`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/features/courses/provider/course_provider.dart) to load catalog, recent, and popular courses from `HomeRepository` and category courses from `CourseRepository` (`GET /courses`).
- [x] **Complete Firestore Elimination & Legacy Service Purge**:
  - **Purged Files**: Deleted `firebase_api_notifications.dart`, `firebase_api_user.dart`, `firebase_api_storage.dart`, `local_storage_service.dart`, `category_preferences.dart`.
  - **Removed Dependency**: Completely removed `cloud_firestore: ^5.0.0` from `only_dev_app/pubspec.yaml`.
  - **Zero Firestore References**: Verified 0 `cloud_firestore` and 0 `firebase_storage` imports remain in the Flutter client.
  - **Local Persistence & Repository**: Created [`PostRepository`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/data/repositories/post_repository.dart) and rewrote `NotificationProvider` using decoupled SharedPreferences persistence.
- [x] **Riverpod State Management & Architectural Rules Enforcement**:
  - **Added `flutter_riverpod: ^2.6.1`**: Root wrapped in `ProviderScope` in `main.dart`.
  - **Centralized Riverpod Providers**: Built [`app_providers.dart`](file:///Users/theary.chorn/Documents/Only-Dev/only_dev_app/lib/core/providers/app_providers.dart) with `userProfileProvider`, `completeInfoProvider`, `postsListProvider`, `postDetailProvider`, and `postEditorProvider`.
  - **UI Views Decoupled**: Converted `CompleteInformations`, `UpdateProfileScreen`, `UserInformationScreen`, `PostEditorScreen`, `PostListScreen`, and `DisplayPostScreen` to Riverpod `ConsumerStatefulWidget` and `ConsumerWidget`.
  - **Strict Rules Followed**:
    - Zero `setState` across converted UI screens; state is managed reactively via Riverpod Notifiers.
    - Zero direct calls to `locator<Repository>()` or `locator<Service>()` in UI views; all data flows through Riverpod.

---

## ⏳ Phase 6: End-to-End Mobile Integration & Testing (Next)

- [x] Connect Home Screen to `GET /api/v1/home` composite endpoint.
- [x] Replace Firebase Storage with Cloudflare R2 presigned uploads.
- [x] Connect Course Detail Screen to `GET /api/v1/courses/get-detail/:id` with Bearer token enrollment checking.
- [x] Connect Enrollment button to `POST /api/v1/enrollments`.
- [ ] Connect Course Catalog Screen to `GET /api/v1/courses`.
- [ ] Connect BetterPlayer video resume to `POST /api/v1/enrollments/progress/:courseId`.

