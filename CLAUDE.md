# Only Dev — Monorepo Architecture & Claude Agent Instructions (`CLAUDE.md`)

This guide outlines architecture, infrastructure, commands, and coding conventions for AI agents and developers working on the **Only Dev** monorepo (`only_dev_app` + `only_dev_api`).

---

## 1. Quick Reference & Commands

### Backend (`only_dev_api`)
```bash
cd only_dev_api

# Install dependencies
npm install

# Start local persistent MongoDB (port 27017, stored in .mongodb_data)
npm run db:local

# Seed database with courses, real streaming videos, quizzes, categories, banners & users
npm run seed

# Run backend development server (port 4000)
npm run start:dev

# Run Vitest test suite
npm test

# Build production bundle
npm run build
```

### Mobile App (`only_dev_app`)
```bash
cd only_dev_app

# Install dependencies
flutter pub get

# Run test suite
flutter test

# Run static analysis
flutter analyze lib/

# Run app on simulator / device
flutter run
```

---

## 2. Infrastructure & Endpoints

- **NestJS REST API**: `http://localhost:4000/api/v1`
- **MongoDB Local Database**: `mongodb://127.0.0.1:27017/only_dev`
- **Cloudflare R2**: Direct binary streaming upload via presigned PUT URLs (`/api/v1/storage/presigned-url`).
- **Redis Cache**: Port 6379 for fast catalog and home caching.
- **Seeded Accounts** (Password: `password123`):
  - Student: `student@onlydev.com`
  - Admin: `admin@onlydev.com`
  - Instructors: `john.doe@onlydev.com`, `sarah.connor@onlydev.com`, `alex.chen@onlydev.com`
- **Verified Streaming Videos (HTTP 200)**:
  - VideoJS Oceans 1080p MP4: `https://vjs.zencdn.net/v/oceans.mp4`
  - W3C Sintel HD Trailer MP4: `https://media.w3.org/2010/05/sintel/trailer.mp4`
  - Plyr Surf Film 720p HD MP4: `https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-720p.mp4`
  - Plyr Surf Film 576p MP4: `https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-576p.mp4`
  - Mux Adaptive HLS Stream: `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`

---

## 3. Strict Flutter Coding Rules (`only_dev_app`)

1. **State Management & Zero `setState`**:
   - Always use **Riverpod** or clean **MVVM (`BaseViewModel` / `BaseView`)**.
   - **DO NOT USE `setState`**. All screen state, UI state, toggle flags, and async flows must be managed reactively via Riverpod notifiers or ViewModels.
2. **Layered Separation of Concerns**:
   - **Never call services or repositories directly in UI widgets**. UI widgets only display state and forward user events to Riverpod notifiers or ViewModels.
3. **HTTP Client (`DioClient`)**:
   - All network calls must use `locator<DioClient>()`.
   - `AuthInterceptor` automatically attaches `Authorization: Bearer <jwt_access_token>`.
   - Tokens stored in `SharedPreferences`:
     - `jwt_access_token`
     - `jwt_refresh_token`
4. **Data Models & JSON Keys (`snake_case`)**:
   - Dart properties use `camelCase`.
   - `fromMap` constructors must parse `snake_case` with fallback to `camelCase`:
     ```dart
     final accessToken = (data['access_token'] ?? data['accessToken'])?.toString();
     final refreshToken = (data['refresh_token'] ?? data['refreshToken'])?.toString();
     ```
   - `toMap` methods emit strictly `snake_case`. Never emit duplicate keys.
   - Timestamps and dates are stored as `String?`. Do not parse to `DateTime` in models.
5. **Defensive Parsing**:
   - Never use raw `int.parse()` on API color strings or dynamic values.
   - Always use `int.tryParse()` with a fallback to `GenerateColor.generateRandomColor()`.
6. **Application Title**:
   - App title is **Only Dev** across all platforms (iOS `CFBundleDisplayName`, Android `android:label`, macOS `PRODUCT_NAME`, Web title, `MaterialApp.title: 'Only Dev'`).

---

## 4. Strict NestJS Backend Rules (`only_dev_api`)

1. **Feature-First Architecture**:
   - Features live in `src/features/<feature>/` (`controller/`, `service/`, `schemas/`, `dto/`).
2. **API Envelope & Response Transformation**:
   - `TransformInterceptor` wraps all responses in:
     ```json
     {
       "success": true,
       "status_code": 200,
       "data": { ... },
       "timestamp": "2026-10-19T07:39:29.616Z"
     }
     ```
   - Automatically converts all response keys to `snake_case`.
3. **Authentication & Dynamic RBAC**:
   - Protected by default using `JwtAuthGuard`.
   - Mark public routes with `@Public()`.
   - Enforce granular access using `@Roles(Role.ADMIN, ...)` and `@RequirePermissions(...)`.
4. **DTO Validation**:
   - Every endpoint must use a strongly typed DTO validated with `class-validator` and `class-transformer`.
5. **Screen Aggregation Pattern**:
   - Consolidate screen data into single endpoints (e.g. `GET /api/v1/home`). Never force mobile screens to make multiple scattered API requests.

---

## 5. Pre-Commit Checklist & Test Verification

Before finishing any task, run and verify:
1. `cd only_dev_api && npm test` (all Vitest tests pass).
2. `cd ../only_dev_app && flutter test` (all Flutter tests pass).
3. `flutter analyze lib/` (0 compilation errors, 0 warnings).

