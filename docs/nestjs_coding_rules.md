# NestJS Backend Coding Rules & Architecture Guidelines

Follow these coding rules strictly for the NestJS API project (`only_dev_api`):

## 1. Architecture & Modular Design
Always follow the **Feature-First Modular Architecture** (`src/features/<feature>/`).
- Every feature must be encapsulated in its own module: `<feature>.module.ts`.
- Subfolders within each feature:
  - `controller/`: REST API endpoints and HTTP route definitions.
  - `service/`: Domain business logic and database/external service interactions.
  - `schemas/`: Mongoose schemas, indexes, and document definitions.
  - `dto/`: Request/response Data Transfer Objects with validation.

## 2. Layered Separation of Concerns
- **Controller Layer**: Handles HTTP requests, extracts parameters, validates input via DTOs, sets response status codes, and delegates immediately to services. **Never put business logic or direct database queries in controllers.**
- **Service Layer**: Houses all domain and business logic, transactions, third-party integrations (S3/R2, Redis), and database operations.
- **Common Layer**: Cross-cutting concerns (`common/guards/`, `common/interceptors/`, `common/filters/`, `common/decorators/`, `common/redis/`).

## 3. Data Transfer Objects (DTOs) & Validation
- Every incoming request payload (`@Body()`, `@Query()`, `@Param()`) must use a strongly typed DTO class.
- Decorate every DTO property with `class-validator` rules (`@IsString()`, `@IsNotEmpty()`, `@IsOptional()`, `@IsEnum()`, `@Min()`, `@Max()`, etc.) and `class-transformer` rules (`@Type()`).
- Never use `any` or untyped raw objects in controller signatures.

## 4. Mongoose Database Modeling
- Define schemas using `@Schema({ timestamps: true })` and `@Prop()`.
- Add compound indexes for high-frequency lookup queries (e.g., `{ userId: 1, courseId: 1 }`).
- For read-only operations that do not modify documents, use `.lean()` or `.exec()` for optimal memory performance.
- Avoid separate admin tables—use the unified User schema with `role` and `customPermissions`.

## 5. Authentication & Dynamic RBAC
- Routes are protected by default using `JwtAuthGuard`. Use the `@Public()` decorator only for deliberately open endpoints (login, register, public catalog).
- Extract the authenticated user via the `@CurrentUser()` custom parameter decorator.
- Use `@Roles(Role.ADMIN, ...)` and `@RequirePermissions(Permission.COURSE_CREATE, ...)` to enforce granular access through the dynamic `RolesGuard`.

## 6. Error Handling & HTTP Exceptions
- Always throw built-in NestJS HTTP exceptions (`NotFoundException`, `BadRequestException`, `ForbiddenException`, `ConflictException`, `UnauthorizedException`).
- Provide human-readable, descriptive error messages.
- Global exception formatting is handled centrally by `HttpExceptionFilter`. Never manually build JSON error response bodies inside try-catch blocks.

## 7. Response Consistency & Interceptors
- Return pure data objects or DTOs from controller actions.
- Let the global `TransformInterceptor` automatically wrap responses into the standard API envelope:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "data": { ... },
    "timestamp": "2026-10-16T17:15:00.000Z"
  }
  ```

## 8. Dependency Injection & Inversion of Control
- Use constructor-based dependency injection.
- Mark all services and repositories with `@Injectable()`.
- Properly export services in their feature module `exports` array when needed across module boundaries.

## 9. Environment Configuration & Secrets
- Never hardcode secrets, ports, keys, or connection URLs.
- Always retrieve environment configurations via `ConfigService` (`@nestjs/config`).

## 10. Code Quality & Strict Typing
- Maintain strict TypeScript typing: avoid `any`, `@ts-ignore`, or loose type assertions.
- Write clean, asynchronous code using `async/await` with proper Promise returns.
- Ensure the project builds cleanly at all times with `npm run build` (0 TypeScript errors).

## 11. Testing Strategy & Guidelines
- **Unit Testing (Services & Logic)**: Test service methods in isolation using Vitest (`*.spec.ts`). Mock Mongoose models (`getModelToken(...)`), Redis, and external S3/R2 services using mock factories. Test success paths, edge cases, and expected exceptions (`NotFoundException`, `ConflictException`).
- **Controller Unit Testing**: Test controller handlers (`*.controller.spec.ts`) to verify correct DTO parameter forwarding, status codes, and exception bubbling without real database connections.
- **E2E Testing (`test/*.e2e-spec.ts`)**: Use Supertest to test complete HTTP request-response flows, verifying JWT guards, dynamic RBAC permissions, interceptors, and filters end-to-end.
- **Test File Colocation**: Colocate unit tests alongside their implementation files (e.g. `src/features/courses/service/courses.service.spec.ts`).
- **Test Verification**: Verify with `npm run test` to guarantee test coverage passes before finalizing feature tasks.

## 12. JSON Key Casing (`snake_case` Standard)
- All external API request and response JSON payloads must adhere strictly to **`snake_case`** keys (e.g., `user_id`, `created_at`, `thumbnail_url`).
- In TypeScript / NestJS:
  - Internal class properties, DTOs, and Mongoose schema fields can be authored in idiomatic `camelCase`.
  - The centralized `TransformInterceptor` automatically transforms all outgoing response payload keys to `snake_case` recursively.
  - **Never emit duplicate keys**: Responses and error payloads must never contain duplicate keys (e.g., avoid providing both `status_code` and `statusCode`). Use only the single `snake_case` key.
  - Incoming request DTOs should accept `snake_case` properties (or use `@Expose({ name: 'snake_case' })` from `class-transformer` or bidirectional DTO mapping).

---

## Required API Request Flow
```
Client (Dio) ──▶ Controller ──▶ Guard (JWT / Roles / Permissions) ──▶ ValidationPipe (DTO) ──▶ Service ──▶ Mongoose / Redis / Storage (R2) ──▶ MongoDB
```

---

## Verification & Execution Protocol
When receiving any new backend task:
- Follow these rules automatically.
- Ensure all endpoints have corresponding DTO validations and RBAC decorators.
- Verify with `npm run build` to guarantee 0 compilation errors before completing.

