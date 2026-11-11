# AGENTS.md

## Project

**Test Point** is a Flutter app for API integration and testing.

Goal: make connecting, running, and validating API flows simple, fast, and reliable — with a focus on performance and a clean developer experience.

## Project Architecture

Full details: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── di/
│
├── core/
│   ├── error/
│   ├── network/
│   ├── database/                 # Supabase client provider + error mapping
│   ├── utils/
│   └── ui/
│       ├── theme/
│       └── widgets/
│
└── modules/
    └── <module_name>/
        ├── <module_name>.dart    # public API (the only file others import)
        ├── <module_name>_routes.dart
        ├── models/
        ├── repositories/
        ├── services/
        ├── providers/
        ├── screens/
        └── widgets/

test/                             # mirrors lib/

supabase/                         # Supabase CLI project (SQL, not Dart)
├── config.toml
├── schemas/                      # Declarative table definitions
├── migrations/                   # Versioned migrations
└── seed.sql                      # Initial / dev data
```

Not every module folder is required — create only the folders a module actually needs.

## Architecture Rules

- The application follows Modular Monolith architecture.
- Each module must be independent.
- Modules must not directly access another module's internal implementation.
- Communication between modules must happen only through the module's public API file (`modules/<name>/<name>.dart`).
- No circular dependencies between modules; move shared contracts to `core/` or invert the dependency.
- Dependency direction inside a module: `screens/widgets → providers → services → repositories → models`.
- UI never calls repositories directly.
- Only repository implementations use the Supabase client; no other layer talks to the database directly.
- Supabase exceptions (`PostgrestException`, `AuthException`, ...) are caught in repositories and converted to `Failure` types.
- Follow Dependency Inversion Principle: services depend on repository contracts, not implementations.
- Infrastructure implementations must not leak into the domain layer.
- Follow KISS, clean code, and SOLID

## Code style

- Match existing patterns before inventing new ones
- Prefer readability over cleverness
- No drive-by refactors or unrelated file edits

# Coding Standards

- Use Dart's null safety.
- Prefer composition over inheritance.
- Keep functions small and focused.
- Avoid unnecessary abstractions.
- Follow SOLID principles when appropriate.
- Use meaningful variable and function names.
- Avoid code duplication.

# Naming Conventions

- Files: snake_case.dart
- Classes: PascalCase
- Variables: camelCase
- Constants: lowerCamelCase
- Private members: prefix with underscore.

# State Management

- Use Riverpod for application state management.
- Keep UI widgets free from business logic.
- Providers should be scoped to their responsibilities.
- Avoid putting unrelated states in a single provider.

# Error Handling

- Never silently swallow exceptions.
- Handle expected failures explicitly.
- Do not expose infrastructure exceptions to the UI.
- Convert infrastructure errors into application-level failures.

# Testing

- Write unit tests for business logic.
- Write widget tests for important UI components.
- Test repository implementations when necessary.
- Mock external dependencies.
- Run relevant tests after modifying code.

# Development Workflow

Before implementing a feature:

1. Inspect the existing project structure.
2. Understand the related architecture.
3. Identify affected modules.
4. Follow existing patterns.
5. Avoid unrelated modifications.

After implementation:

1. Run relevant tests.
2. Run static analysis.
3. Fix introduced issues.
4. Summarize the changes.

# Restrictions

- Do not introduce new dependencies without justification.
- Do not modify unrelated files.
- Do not duplicate existing functionality.
- Do not bypass module boundaries.
- Do not introduce abstractions without a clear need.
- Do not refactor unrelated code during feature implementation.

## Core Stack

- Language: Dart (null safety)
- Framework: Flutter (stable channel), Material 3
- Platforms: desktop first (Windows, macOS, Linux)
- State management: Riverpod (`flutter_riverpod`)
- Navigation: `go_router`
- Networking: `dio`
- Database: Supabase (PostgreSQL) through `supabase_flutter`; schema in [docs/data_model.md](docs/data_model.md)
- Local settings: `shared_preferences`
- Serialization: `freezed` + `json_serializable`
- Validation: hand-written validators in `services/` that return `Failure` types from `core/error`

### Packages and why they are needed

The packages are chosen to support the MVP screens in [docs/design/stitch-mvp-progress.md](docs/design/stitch-mvp-progress.md). Add a package only when the module that needs it is built.

| Concern     | Package                                            | UI/UX reason                                                                                                     |
| ----------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| State       | `flutter_riverpod`                                 | Open request tabs, unsaved markers, active environment, theme mode                                               |
| Routing     | `go_router`                                        | Nav rail sections (Collections, Environments, Settings) as routes                                                |
| HTTP        | `dio`                                              | Send requests, cancel in-flight requests, proxy setting ("Proxy: Off"), timing and size for the response view    |
| Database    | `supabase_flutter`                                 | Workspaces, collections, requests and environments stored in Supabase; Supabase Auth for users and organizations |
| Models      | `freezed` + `json_serializable` (+ `build_runner`) | Immutable models; map Supabase rows (JSON) and Postman v2.1 import                                               |
| Code editor | `re_editor` + `re_highlight`                       | JSON body editor and response viewer with syntax highlighting; stays fast on large responses                     |
| Split panes | `multi_split_view`                                 | Resizable sidebar / request / response panes and the layout toggle                                               |
| Window      | `window_manager`                                   | Desktop minimum window size and title                                                                            |
| Import      | `file_picker`                                      | Choose a Postman v2.1 collection file in the Import dialog                                                       |
| Preferences | `shared_preferences`                               | Theme mode, layout and proxy settings                                                                            |
| Tests       | `mocktail` (dev)                                   | Mock repositories and services in unit tests                                                                     |

Use Flutter built-ins instead of packages for these:

- Keyboard shortcuts (`Ctrl+Enter` send, `Ctrl+K` filter, `Ctrl+F` search): `Shortcuts` / `Actions`
- Context menus, method menu and env dropdown: `MenuAnchor`
- Variable autocomplete (`{{var}}`): `RawAutocomplete` / `OverlayPortal`
- Copy actions: `Clipboard`
- cURL import: write a small parser in the import module, no package

### UI rules

- Theme lives in `lib/core/ui/theme/`: a `ColorScheme` seeded from teal `#0F9D8A`, plus a `ThemeExtension` for HTTP method colors and status colors (2xx green, 3xx blue, 4xx amber, 5xx red).
- Dark theme is the primary theme; light theme must also work.
- Fonts are bundled as assets (no runtime download): Google Sans Flex for headlines, Inter for UI text, JetBrains Mono for URLs and code.
- Keyboard hints always say `Ctrl`, never `⌘` or `^`.
- Labels, chips, tabs and status text stay on one line; use ellipsis instead of wrapping.
- Shared widgets (method pill, status chip, variable chip) go in `lib/core/ui/widgets/`.

### Supabase rules

- Schema changes go through `supabase/migrations/` only; never edit tables by hand in the dashboard.
- Every table has Row Level Security enabled with policies scoped to the user's organization.
- The app uses only the anon key; never put the service-role key in the app.
- Pass the Supabase URL and anon key with `--dart-define` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`); never hard-code them.

## Commands

- Install dependencies: `flutter pub get`
- Generate code (freezed, json_serializable): `dart run build_runner build --delete-conflicting-outputs`
- Run (desktop): `flutter run -d windows --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` (or `macos` / `linux`)
- Local Supabase: `supabase start` / `supabase stop`
- New migration: `supabase migration new <name>` (or `supabase db diff -f <name>` from `supabase/schemas/`)
- Apply migrations locally: `supabase db reset` (re-runs migrations + `seed.sql`)
- Push migrations to the remote project: `supabase db push`
- Static analysis: `flutter analyze`
- Tests: `flutter test`
- Integration tests (real repositories against local Supabase, skipped by default): `flutter test test/integration --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=<anon key from supabase status>`
- Build: `flutter build windows` (or `macos` / `linux`)
