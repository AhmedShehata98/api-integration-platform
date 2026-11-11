# Architecture

Test Point is a **modular monolith**: one Flutter app, split into independent
**modules** (business areas). Each module owns its layers in a flat folder
structure and exposes a single public API file.

```
App  ──►  Modules (projects, requests, ...)  ──►  Core (shared infra)
```

---

## 1. Folder Structure

```
lib/
├── main.dart                     # Entry point: ProviderScope + App
├── app/
│   ├── app.dart                  # MaterialApp, theme, router
│   ├── router/                   # Route table — composes module routes
│   └── di/                       # App-level provider overrides / wiring
│
├── core/                         # Shared, module-agnostic code
│   ├── error/                    # Failure types, error mapping
│   ├── network/                  # HTTP client, interceptors
│   ├── database/                 # Supabase client provider + error mapping
│   ├── utils/                    # Pure helpers
│   └── ui/
│       ├── theme/
│       └── widgets/              # Generic reusable widgets
│
└── modules/
    └── <module_name>/
        ├── <module_name>.dart    # PUBLIC API (the only file others import)
        ├── <module_name>_routes.dart
        ├── models/
        ├── repositories/
        ├── services/
        ├── providers/
        ├── screens/
        └── widgets/

test/                             # Mirrors lib/
└── modules/<module_name>/...

supabase/                         # Supabase CLI project (SQL, not Dart)
├── config.toml
├── schemas/                      # Declarative table definitions
├── migrations/                   # Versioned migrations
└── seed.sql                      # Initial / dev data
```

> **Not every folder is required.** Create only the folders a module actually
> needs — e.g. a UI-only module may have just `screens/` and `widgets/`, while a
> data-only module may have just `models/`, `repositories/` and `providers/`.
> An empty layer is noise.

---

## 2. Layers inside a Module

| Folder          | Responsibility                                           | May depend on                      |
| --------------- | -------------------------------------------------------- | ---------------------------------- |
| `models/`       | Immutable data classes (entities, DTOs)                  | nothing                            |
| `repositories/` | Abstract contract + implementation (DB / network access) | `models`, `core`                   |
| `services/`     | Business logic / use cases                               | `models`, repository **contracts** |
| `providers/`    | Riverpod providers & notifiers (state + DI)              | `services`, `repositories`         |
| `screens/`      | Route-level widgets                                      | `providers`, `widgets`, `core/ui`  |
| `widgets/`      | Module-specific UI pieces                                | `providers`, `core/ui`             |

**Dependency direction:** `screens/widgets → providers → services → repositories → models`

- UI never calls repositories directly.
- Services depend on repository **abstractions**, never on implementations.
- Only repository implementations use the Supabase client; no other layer
  touches the database directly.
- Infrastructure exceptions (e.g. `PostgrestException`) are caught in
  repositories and converted to `Failure` types from `core/error`.
- If a layer is skipped (e.g. no `services/` for simple CRUD), providers may
  call repository contracts directly — but never the other way around.

---

## 3. Module Rules

1. **Independent** — a module can be removed without breaking others' internals.
2. **Public API only** — other modules import `modules/<name>/<name>.dart` only.
   Never import another module's `repositories/`, `services/`, `screens/`, etc.
3. **Expose contracts, not implementations** — the public API exports abstract
   interfaces, models needed by consumers, providers, and routes.
4. **No cycles** — if two modules need each other, move the shared contract to
   `core/` or invert the dependency.
5. **Keep modules cohesive** — if a module grows too large, split it into two
   modules rather than nesting sub-folders inside it.

### Public API template — `modules/<module_name>/<module_name>.dart`

```dart
/// Public interface of the <module_name> module.
/// Other modules must import ONLY this file.
library;

export 'models/<model>.dart';
export 'repositories/<name>_repository.dart'; // abstract contract only
export 'providers/<name>_providers.dart';
export '<module_name>_routes.dart';
```

---

## 4. Module Template

Example: module `projects`.

```
modules/projects/
├── projects.dart                         # public API
├── projects_routes.dart
├── models/
│   ├── project.dart
│   └── project_draft.dart
├── repositories/
│   ├── project_repository.dart           # abstract
│   └── project_repository_impl.dart      # implementation
├── services/create_project_service.dart
├── providers/project_providers.dart
├── screens/create_project_screen.dart
└── widgets/project_form.dart
```

**Repository (contract + impl)**

```dart
abstract interface class ProjectRepository {
  Future<Result<Project>> create(ProjectDraft draft);
}

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<Result<Project>> create(ProjectDraft draft) async {
    try {
      final row = await _client
          .from('projects')
          .insert(draft.toJson())
          .select()
          .single();
      return Result.success(Project.fromJson(row));
    } on PostgrestException catch (e) {
      return Result.failure(StorageFailure(e.message)); // never leak infra errors
    }
  }
}
```

**Service**

```dart
class CreateProjectService {
  CreateProjectService(this._repository);
  final ProjectRepository _repository;

  Future<Result<Project>> call(ProjectDraft draft) {
    if (draft.name.trim().isEmpty) {
      return Future.value(Result.failure(const ValidationFailure('Name is required')));
    }
    return _repository.create(draft);
  }
}
```

**Providers**

```dart
final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final createProjectServiceProvider = Provider(
  (ref) => CreateProjectService(ref.watch(projectRepositoryProvider)),
);
```

**Screen** — reads providers, renders state, no business logic.

---

## 5. Cross-Module Communication

```dart
// ✅ requests module using projects module
import 'package:test_point/modules/projects/projects.dart';

final project = ref.watch(selectedProjectProvider);

// ❌ reaching into internals
import 'package:test_point/modules/projects/repositories/project_repository_impl.dart';
```

---

## 6. Adding a New Module — Checklist

- [ ] Create `modules/<module>/<module>.dart` public API file.
- [ ] Create only the layer folders the module needs
      (`models/`, `repositories/`, `services/`, `providers/`, `screens/`, `widgets/`).
- [ ] Define repository contract before implementation.
- [ ] Map infrastructure errors to `core/error` failures.
- [ ] Expose providers / routes through the public API.
- [ ] Register routes in `app/router/`.
- [ ] Add unit tests (services, repositories) and widget tests (key screens) under `test/` mirroring `lib/`.
- [ ] Run `flutter analyze` and `flutter test`.

---

## 7. Naming

| Item          | Convention             | Example                        |
| ------------- | ---------------------- | ------------------------------ |
| Files         | `snake_case.dart`      | `create_project_service.dart`  |
| Classes       | `PascalCase`           | `CreateProjectService`         |
| Providers     | `<name>Provider`       | `createProjectServiceProvider` |
| Repo contract | `<Name>Repository`     | `ProjectRepository`            |
| Repo impl     | `<Name>RepositoryImpl` | `ProjectRepositoryImpl`        |
| Screens       | `<Name>Screen`         | `CreateProjectScreen`          |
