# Flutter Project Coding Rules & Architecture Guidelines

Follow these coding rules strictly for the Flutter project (`only_dev_app`):

## 1. Architecture & State Management (Riverpod)
Always use **Riverpod** for state management and follow the **MVVM (Model–View–ViewModel / Notifier)** architecture.
- Feature views inherit from `ConsumerWidget` or `ConsumerStatefulWidget`.
- Use `ref.watch()` to reactively listen to state changes and rebuild UI.
- Use `ref.read()` in event handlers to invoke actions or mutations.
- State is managed via Riverpod Notifiers (`Notifier`, `AsyncNotifier`, `StateNotifier`) or ViewModels decoupled from Flutter widgets.

## 2. HTTP Requests
Always use the **`dio`** package for all API calls. Centralized through `DioClient` with interceptors (`AuthInterceptor`, `ApiErrorInterceptor`).

## 3. UI Separation & No `setState` Rule
- **No `setState`**: **DO NOT USE `setState`**. All screen state, UI state, toggle flags, and asynchronous operations must be managed reactively through **Riverpod**.
- **No Direct Service or Repository in UI**: Never make API calls or invoke repository/service methods directly inside UI widgets. UI widgets must only display data and forward user actions to Riverpod notifiers/providers.

## 4. ViewModel / Notifier
Handle UI state and presentation logic, including loading, success, empty, and error states. Notifiers and ViewModels must never import UI rendering packages like `dart:ui`.

## 5. Repository
Use a repository layer between the ViewModel and API service / data sources to manage data access, caching, and domain transformations.

## 6. API Service
Put all endpoint methods in API service / remote data source classes and use the centralized Dio client (`locator<DioClient>()`).

## 7. Data Models
Use typed Dart models to parse API responses instead of using `dynamic` everywhere.
- **Dates & Timestamps as Strings**: Do not use `DateTime` in models. Let the backend format dates and return them as strings (`String` or `String?`). Models must store dates as strings rather than parsing to `DateTime`.
- Ensure safe parsing and null-safety.

## 8. Dependency Injection
Reuse existing dependency injection (`GetIt locator` in `lib/di/dependency_injection.dart`) and project conventions.

## 9. Code Quality
Write clean, reusable, maintainable, null-safe, and testable code.

## 10. Existing Project
Before changing anything, inspect the existing project structure and follow its current conventions. Do not rewrite unrelated code or introduce unnecessary packages.

## 11. Testing Strategy & Guidelines
- **ViewModel Unit Tests**: Test ViewModel states (`idle`, `busy`, `error`, `success`) and error handling using mock repositories. Never make real network calls in tests.
- **Repository Unit Tests**: Verify that repositories correctly map data models, cache when needed, and handle `DioException` errors gracefully.
- **Widget Tests**: Test UI widgets in isolation using `WidgetTester`, verifying proper UI reaction to ViewModel states without external network dependencies.
- **Test Directory Structure**: Mirror the `lib/` directory structure inside `test/` (e.g., `test/features/courses/viewmodel/courses_viewmodel_test.dart`).
- **Test Verification**: Run `flutter test` to ensure existing and new tests pass cleanly before completing tasks.

## 12. JSON Key Casing (`snake_case` Standard)
- All network serialization (API requests and responses) must strictly use **`snake_case`** keys (e.g., `user_id`, `course_id`, `video_url`, `created_at`, `thumbnail_url`).
- In Dart models:
  - Model properties use idiomatic Dart `camelCase` identifiers.
  - `fromMap` / `fromJson` constructors must parse `snake_case` keys (with fallback to `camelCase` for backward compatibility where applicable).
  - `toMap` / `toJson` methods must emit strictly `snake_case` keys only.
  - **Never emit duplicate keys**: Do NOT output both camelCase and snake_case keys in serialization (e.g., avoid `'full_name': name, 'fullName': name`). Only include the single `snake_case` key.

## 13. Screen-Aggregated API Pattern (Single Screen = Single Endpoint)
- **Do NOT call multiple API endpoints for the same screen**.
- Never make multiple scattered HTTP requests from a single screen or ViewModel (e.g., calling banners, categories, popular courses, and recent courses separately to populate the Home screen).
- The backend must provide a consolidated screen endpoint (e.g., `GET /home`) returning an aggregated payload (`banners`, `categories`, `courses`, `recent_courses`, `popular_courses`).
- The mobile app requests this single composite endpoint through its ViewModel/Repository via Dio, minimizing mobile network round trips, battery consumption, and complex fragmented loading states.

## 14. Feature-Scoped State & Riverpod Exclusivity
- **Complete Ban on `package:provider`**: The legacy `provider` package is completely removed. Do not import or reintroduce `package:provider`.
- **Feature-Scoped State First**: Place Notifiers, ViewModels, and State models directly inside `lib/features/<feature>/provider/`.
- **Lifecycle Management (`.autoDispose`)**: Feature-scoped state should utilize `.autoDispose` so memory is automatically reclaimed when navigating away.
- **Strictly Global State**: Only true app-wide singletons (Auth JWT session, ThemeMode, Locale) belong in `lib/core/providers/`.
- **ListenableBuilder Decoupling**: BaseView implementations use Flutter's native `ListenableBuilder` to remain independent of third-party state managers.

## 15. UI Media, Image & Refresh Infrastructure
- **Universal Image Pipeline**: All network images, avatars, banners, and thumbnails must use `AppImageWidget` and `AppCircleAvatar` (`lib/widgets/app_widgets/app_image_widget.dart`). Never call raw `Image.network` or `CachedNetworkImage` directly in screens.
- **Native Pull-To-Refresh**: Use Flutter's native `RefreshIndicator` and standard `ScrollController` listener for pagination. Never use third-party `pull_to_refresh` packages.
- **Patched Video Player**: Video streaming uses the local patched package `only_dev_app/packages/better_player` with defensive NaN guards in Cupertino progress bars.

---

## Required API Data Flow
```
UI (View) ──▶ ViewModel ──▶ Repository ──▶ API Service / RemoteDataSource ──▶ Dio Client ──▶ Backend API
```

---

## Verification & Execution Protocol
When receiving any new task:
- Follow these rules automatically.
- If existing code violates them, refactor it when relevant to the task while preserving existing functionality.
- Before finishing, verify that no API calls are made directly from UI widgets and that all API requests use Dio through the appropriate layers.

