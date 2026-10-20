# Only Dev — Monorepo Architecture & AI Agent Instructions (`GEMINI.md`)

This document defines the system architecture, infrastructure, coding rules, and development guidelines for **Only Dev** (`only_dev_app` + `only_dev_api`). All AI assistants (including Google Antigravity and Gemini) must strictly follow these instructions.

---

## 1. Monorepo Overview & Project Identity

- **Application Name**: **Only Dev**
- **Repository Structure**:
  ```text
  Only-Dev/
  ├── docs/                  # Architectural blueprints & migration progress
  ├── .agents/rules/         # Specific agent rules for Flutter & NestJS
  ├── only_dev_api/          # NestJS (TypeScript) Backend REST API
  │   ├── src/
  │   │   ├── common/        # Guards (JWT, RBAC), interceptors, decorators, Redis
  │   │   ├── features/      # Modular domains: auth, users, courses, enrollments, quizzes, roles, storage, home
  │   │   └── seed/          # DB seeder with verified video streams & test data
  │   ├── scripts/           # Local persistent MongoDB runner
  │   └── package.json
  └── only_dev_app/          # Flutter (Dart) Mobile & Multiplatform Client
      ├── lib/
      │   ├── core/          # BaseViewModel, BaseView (ListenableBuilder), Global navigation
      │   ├── data/          # Models, Remote Data Sources, Repositories
      │   ├── features/      # Modular Feature-first domains (local states, views, widgets)
      │   │   ├── auth/      # Auth screens, ViewModel, state
      │   │   ├── courses/   # Course catalog, detail, curriculum, video player
      │   │   ├── profile/   # Redesigned Profile UI, atomic widgets, state
      │   │   └── ...
      │   ├── service/       # DioClient, AuthInterceptor, Firebase Messaging
      │   └── widgets/       # Atomic, reusable UI components (AppImageWidget)
      ├── packages/
      │   └── better_player/ # Local patched video streaming player
      └── pubspec.yaml
  ```

---

## 2. Infrastructure & Local Services

### 2.1 Services & Ports
| Service | Environment / Runtime | Address / Port | Description |
| :--- | :--- | :--- | :--- |
| **NestJS API** | Node.js (TypeScript) | `http://localhost:4000/api/v1` | Core REST API backend |
| **Local MongoDB** | `mongodb-memory-server` (Disk-backed) | `mongodb://127.0.0.1:27017/only_dev` | Persistent local database stored in `only_dev_api/.mongodb_data` |
| **Cloudflare R2** | AWS S3 SDK Compatible | Cloudflare Presigned PUT URLs | Direct binary video/avatar streaming upload |
| **Redis** | Optional In-Memory Cache | `localhost:6379` | Fast caching for `/home` and course listings |

### 2.2 Local Database Management
- Start local persistent MongoDB:
  ```bash
  cd only_dev_api
  npm run db:local
  ```
  *(Data persists on disk across restarts in `only_dev_api/.mongodb_data`)*.
- Seed database with full courses, real streaming videos, quizzes, categories, banners, and sample accounts:
  ```bash
  cd only_dev_api
  npm run seed
  ```

### 2.3 Seed Accounts & Test Credentials
All test accounts are seeded with password: `password123`
- **Student**: `student@onlydev.com` (password: `password123`)
- **Admin**: `admin@onlydev.com` (password: `password123`)
- **Instructors**:
  - `john.doe@onlydev.com` (password: `password123`)
  - `sarah.connor@onlydev.com` (password: `password123`)
  - `alex.chen@onlydev.com` (password: `password123`)

### 2.4 Verified Real Streaming Video Sources (HTTP 200 OK)
The seeder loads verified streaming URLs for video player testing:
- **VideoJS Oceans 1080p MP4**: `https://vjs.zencdn.net/v/oceans.mp4`
- **W3C Sintel HD Trailer MP4**: `https://media.w3.org/2010/05/sintel/trailer.mp4`
- **Plyr Surf Film 720p HD MP4**: `https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-720p.mp4`
- **Plyr Surf Film 576p MP4**: `https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-576p.mp4`
- **Mux Adaptive HLS Stream**: `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`

### 2.5 Video Player & Media Infrastructure
- **Video Player Engine**: Local patched package `only_dev_app/packages/better_player` supporting adaptive HLS (`.m3u8`) and multi-resolution MP4.
- **NaN Assertion Guard**: Cupertino progress bars (`better_player_cupertino_progress_bar.dart`) clamp `playedDate` and progress bounds defensively, preventing `RRect argument contained a NaN value` rendering crashes.
- **Universal Image & Avatar Pipeline**: All network images, user avatars, course banners, and thumbnails must use `AppImageWidget` and `AppCircleAvatar` (`lib/widgets/app_widgets/app_image_widget.dart`). Never invoke raw `Image.network` or `CachedNetworkImage` directly in UI screens.
- **Native Refresh & Infinite Scroll**: Do NOT use `pull_to_refresh` or third-party wrappers. Use native Flutter `RefreshIndicator` and `ScrollController` threshold pagination.

---

## 3. Backend Rules & Standards (`only_dev_api`)

1. **Feature-First Architecture**:
   - Every domain lives under `src/features/<feature>/` containing `controller/`, `service/`, `schemas/`, and `dto/`.
2. **Standard API Response Envelope**:
   - `TransformInterceptor` automatically wraps responses into:
     ```json
     {
       "success": true,
       "status_code": 200,
       "data": { ... },
       "timestamp": "2026-10-19T07:39:29.616Z"
     }
     ```
3. **Wire Format Strict `snake_case`**:
   - All response JSON keys are automatically converted to `snake_case` by `TransformInterceptor` (`access_token`, `refresh_token`, `full_name`, `avatar_url`, `created_at`).
4. **Authentication & RBAC**:
   - All routes are protected by default via `JwtAuthGuard`.
   - Open routes must be explicitly marked with `@Public()`.
   - Dynamic role-based & permission-based access is enforced via `@Roles(...)` and `@RequirePermissions(...)`.
5. **Screen-Aggregated Endpoint Pattern**:
   - Do NOT force mobile clients to execute multiple scattered HTTP requests for a single screen. Provide aggregated endpoints (e.g., `GET /api/v1/home` returning banners, categories, popular courses, and recent courses).

---

## 4. Flutter Mobile App Rules (`only_dev_app`)

1. **Unified State Management — Riverpod ONLY**:
   - `package:provider` is **completely banned and removed**. Never import `package:provider`.
   - The entire app is wrapped with `ProviderScope` in `main.dart`.
   - Use `flutter_riverpod` exclusively (`ConsumerWidget`, `ConsumerStatefulWidget`, or Riverpod's `Consumer`).
2. **Feature-Scoped State over Monolithic Global State**:
   - **Feature-First Co-location**: State classes and Notifiers belonging to a specific domain (Profile, Quizzes, Courses, Cart) must live inside `lib/features/<feature>/provider/`.
   - **Lifecycle Management via `.autoDispose`**: Feature-scoped providers must use `.autoDispose` so state is discarded and memory is reclaimed when the screen is popped.
   - **Strictly Global State**: Only truly app-wide, session-long singletons live in `lib/core/providers/` (Auth session/JWT tokens, App Theme, App Language/Locale).
3. **Decoupled MVVM Architecture (`BaseViewModel` / `BaseView`)**:
   - `BaseView<T extends BaseViewModel>` utilizes Flutter's native `ListenableBuilder`. It does NOT depend on any third-party provider package.
   - **STRICT RULE: NO `setState`**: Never use `setState` in UI widgets. Manage all state, toggle flags, and async flows reactively via Riverpod Notifiers or ViewModels.
   - **NO Direct Service or Repository in UI**: Widgets must NEVER invoke `DioClient`, services, or repositories directly. UI triggers ViewModel/Notifier methods.
4. **Networking (`DioClient`)**:
   - All network calls must pass through `DioClient` (`locator<DioClient>()`).
   - `AuthInterceptor` attaches `Authorization: Bearer <jwt_access_token>`.
   - Tokens are persisted in `SharedPreferences` under:
     - `jwt_access_token`
     - `jwt_refresh_token`
5. **Data Model Serialization**:
   - Dart properties use idiomatic `camelCase`.
   - `fromMap` constructors must parse `snake_case` (with fallback to `camelCase`):
     ```dart
     final accessToken = (data['access_token'] ?? data['accessToken'])?.toString();
     final refreshToken = (data['refresh_token'] ?? data['refreshToken'])?.toString();
     ```
   - `toMap` methods must emit strictly `snake_case`. Never emit duplicate keys.
   - **Dates/Timestamps**: Models store timestamps as strings (`String?`), avoiding premature `DateTime` parsing.
6. **Defensive Parsing (No Unhandled `int.parse`)**:
   - Never use `int.parse()` on API color strings or dynamic values without validation.
   - Always use `int.tryParse()` with a sensible fallback (e.g., `_resolveUserColor()`).
7. **Native UI Standards**:
   - **No Legacy Refresh Packages**: Always use Flutter's built-in `RefreshIndicator` and standard `ScrollController` listener for pagination.
   - **Universal Image Pipeline**: Always use `AppImageWidget` and `AppCircleAvatar` (`lib/widgets/app_widgets/app_image_widget.dart`).
8. **App Name Consistency**:
   - App title is **Only Dev** across:
     - iOS: `CFBundleDisplayName` & `CFBundleName` in `Info.plist`
     - Android: `android:label` in `AndroidManifest.xml`
     - macOS: `PRODUCT_NAME` in `AppInfo.xcconfig`
     - Web: `<title>` in `index.html` & `name`/`short_name` in `manifest.json`
     - Desktop: Window titles in `windows/runner/main.cpp` & `linux/my_application.cc`
     - Flutter: `MaterialApp.router(title: 'Only Dev')` & `AppLocalizations.appTitle`

---

## 5. Google Sign-In & OAuth Troubleshooting

- If Google OAuth displays `Error 401: deleted_client`:
  - The OAuth 2.0 client ID configured in `GoogleService-Info.plist` was deleted or regenerated in the Google Cloud / Firebase Console.
  - Solution: Re-register the iOS app (`com.example.eLeaningapp`) in Firebase Console, download the new `GoogleService-Info.plist`, and update `GIDClientID` and `CFBundleURLSchemes` in [`ios/Runner/Info.plist`](only_dev_app/ios/Runner/Info.plist).
- Meanwhile, the app fully supports native email/password authentication using the seeded backend accounts (`student@onlydev.com` / `password123`).

---

## 6. Verification & Testing Commands

Before completing any task or pull request, run the test suites to ensure zero regressions:

```bash
# 1. NestJS Backend Tests
cd only_dev_api
npm test

# 2. Flutter Unit & Widget Tests
cd ../only_dev_app
flutter test

# 3. Flutter Static Analysis
flutter analyze lib/
```

