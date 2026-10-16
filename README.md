# Only-Dev

Monorepo containing the **Only-Dev API** backend and the **Only-Dev Mobile Application**.

---

## Repository Structure

```
Only-Dev/
├── docs/                # Architecture blueprints & migration documentation
│   └── migration_plan_backend_dio.md
│
├── only_dev_api/        # NestJS (TypeScript) Backend REST API
│   ├── src/
│   │   ├── common/      # Dynamic RBAC guards, decorators, filters, Redis service
│   │   └── features/    # Modular features: roles, users, auth, courses, enrollments, quizzes, storage
│   ├── .env.example
│   └── package.json
│
└── only_dev_app/        # Flutter Mobile Application
    ├── lib/             # Screens, widgets, providers, services, models
    ├── assets/
    └── pubspec.yaml
```

> **Architecture Blueprint & Migration Plan**: Read [`docs/migration_plan_backend_dio.md`](docs/migration_plan_backend_dio.md) for full database schemas, dynamic RBAC specifications, and Dio client integration guides.
> 
> **Progress Tracker**: Track real-time progress, milestones, and completed features in [`docs/migration_progress_tracker.md`](docs/migration_progress_tracker.md).

---

## 1. Backend (`only_dev_api`)

Enterprise **NestJS** REST API with **MongoDB**, **Redis**, **Cloudflare R2** storage, and a **Dynamic Custom RBAC Engine**.

### Quick Start:
```bash
cd only_dev_api
cp .env.example .env
npm install
npm run start:dev
```
API runs at: `http://localhost:4000/api/v1`

---

## 2. Mobile App (`only_dev_app`)

Cross-platform **Flutter** client.

### Quick Start:
```bash
cd only_dev_app
flutter pub get
flutter run
```
