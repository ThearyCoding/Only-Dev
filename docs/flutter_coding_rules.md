# Flutter Coding Rules & Architecture Guidelines

Follow these coding rules strictly for the Flutter project (`only_dev_app`):

## 1. Architecture
Always use the **MVVM (Model–View–ViewModel)** architecture.
- Feature views inherit from `BaseView<T>` (or use `Consumer<T>`).
- ViewModels inherit from `BaseViewModel` (or `ChangeNotifier`) to manage reactive states (`ViewState.idle`, `busy`, `error`, `success`).

## 2. HTTP Requests
Always use the **`dio`** package for all API calls. Centralized through `DioClient` with interceptors (`AuthInterceptor`, `ApiErrorInterceptor`).

## 3. UI Separation
Never make API calls directly inside UI widgets. UI widgets must only display data and forward user actions to the ViewModel.

## 4. ViewModel
Handle UI state and presentation logic, including loading, success, empty, and error states.

## 5. Repository
Use a repository layer between the ViewModel and API service / data sources to manage data access, caching, and domain transformations.

## 6. API Service
Put all endpoint methods in API service / remote data source classes and use the centralized Dio client (`locator<DioClient>()`).

## 7. Data Models
Use typed Dart models to parse API responses instead of using `dynamic` everywhere. Ensure safe parsing and null-safety.

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

