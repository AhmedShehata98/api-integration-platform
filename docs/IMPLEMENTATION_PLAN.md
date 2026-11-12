# Test Point — Implementation Plan (MVP)

_Status: Draft · Last updated: 2026-11-12_

Related docs:
- Product scope: [PRD.md](PRD.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Data model: [data_model.md](data_model.md)
- Design progress (Stitch): [design/stitch-mvp-progress.md](design/stitch-mvp-progress.md)
- Agent / coding rules and Core Stack: [../agents.md](../agents.md)

---

## 1. Current State

| Area | Today |
| --- | --- |
| Code | `lib/main.dart` is still the Flutter counter template |
| Folders | `lib/common/` (empty), `lib/modules/projects/` (empty), `lib/modules/requests/` (empty) |
| Dependencies | Only `cupertino_icons`; dev: `flutter_test`, `flutter_lints` |
| Tests | Template `test/widget_test.dart` |
| Backend | No `supabase/` project yet |
| Tooling | Flutter 3.47.9 (stable) |
| Design | 12 dark MVP screens in Stitch; screens #5–#9 still to verify; light variants and token handoff not done |

---

## 2. Decisions

| # | Decision | Notes |
| --- | --- | --- |
| D1 | **App starts with Supabase anonymous auth; the user avatar opens an Account dialog with one action: Continue with GitHub** | Users can work right away as a guest and connect a GitHub account when they want. GitHub OAuth is the only sign-in method (no email / password). Resolves PRD Q1. |
| D2 | **`modules/projects` is renamed to `modules/workspaces`** | Matches the `workspaces` table. |
| D3 | **`lib/common/` is renamed to `lib/core/`** | Matches `agents.md` and `ARCHITECTURE.md`. Resolves PRD Q4. |
| D4 | First sign-in creates a personal organization and a default workspace | Done by a Postgres trigger on `auth.users`, so RLS always has an organization to scope to. |
| D5 | Secret variables are stored in Supabase (RLS-protected) and masked in the UI | Default for the MVP; revisit PRD Q3 later. |
| D6 | Online-only for the MVP | No local cache; revisit PRD Q2 later. |
| D7 | **Continue with GitHub first links the identity to the guest user in place** | `auth.linkIdentity(OAuthProvider.github)` adds GitHub to the same anonymous user, so the user id, organization, workspace and data are kept. Needs manual identity linking enabled in Supabase. |
| D8 | **If that GitHub account already exists, warn, then sign in and discard the guest data** | Linking fails with `identity_already_exists`. If the guest has any collections, requests or environments, a confirm dialog says they will not be carried over; on confirm, `auth.signInWithOAuth(OAuthProvider.github)` loads that account's workspace. Merging is post-MVP. |
| D9 | **Desktop OAuth returns through a custom URL scheme** | The browser opens GitHub's consent page and redirects to `testpoint://auth-callback`, which the app registers on Windows, macOS and Linux. The redirect URL is added to Supabase's allowed redirect list. |

---

## 3. Module Map

All cross-module calls go through each module's public API file
(`modules/<name>/<name>.dart`). Arrows mean "depends on".

| Module | Owns | Depends on |
| --- | --- | --- |
| `auth` | Session (guest or signed in), current user, Account dialogs, Continue with GitHub / sign out, avatar widget | — |
| `workspaces` | Current workspace, organization bootstrap check | `auth` |
| `collections` | Collections, sidebar tree, filter, overview | `workspaces` |
| `environments` | Environments, variables, active environment, `{{var}}` resolver | `workspaces` |
| `settings` | Theme mode, timeout, follow redirects, proxy (stored on device) | — |
| `requests` | Request builder, send / cancel, response viewer, open tabs, saved requests | `collections`, `environments`, `settings` |
| `import` | cURL parser, Postman v2.1 importer, import dialog | `collections`, `requests` |

The workspace shell (nav rail, top bar, status bar, Welcome screen) lives in
`lib/app/` and `lib/core/ui/`, and composes module widgets through their public APIs
(for example, the nav rail shows the avatar exported by `auth`).

```
auth ◄── workspaces ◄── collections ◄──┐
              ▲                        ├── requests ◄── import
              └──── environments ◄─────┤
                        settings ◄─────┘
```

---

## 4. Schema Changes

`docs/data_model.md` is the starting point. The MVP needs these changes, all
written as Supabase migrations in `supabase/migrations/`. Update
`data_model.md` in the same phase.

| Table | Change | Why |
| --- | --- | --- |
| `users` | `id` references `auth.users(id)`; `email` becomes nullable | Anonymous users have no email; a GitHub account may hide its email |
| all tables | Add `created_at`, `updated_at` | Sorting, sync checks |
| `collections`, `requests` | Add `position int` | Order in the sidebar tree |
| `requests` | Add `params jsonb`, `auth jsonb`, `body_type varchar` | Params, Auth and Body tabs |
| `environments` | Define `variables` shape: `[{key, value, secret, enabled}]` | Secret flag and enable toggle |
| all tables | Enable RLS; policies allow access only to members of the row's organization | Security (PRD §7) |
| `auth.users` | Trigger `on_auth_user_created`: insert `users`, a personal `organizations` row, `organization_members` (role `owner`) and a default `workspaces` row | D4 |
| `auth.users` | Trigger `on_auth_user_updated`: copy the new email into `users.email` when a guest connects GitHub | D7 |

Auth settings in `supabase/config.toml` (and the same in the hosted project):
- `[auth] enable_anonymous_sign_ins = true`
- `[auth] enable_manual_linking = true` (lets a guest link GitHub, D7)
- `[auth.external.github] enabled = true`, with `client_id` and `secret` read
  from environment variables (`SUPABASE_AUTH_EXTERNAL_GITHUB_CLIENT_ID`,
  `SUPABASE_AUTH_EXTERNAL_GITHUB_SECRET`); never commit the secret. The GitHub OAuth app's callback URL is the
  Supabase `/auth/v1/callback` URL.
- `[auth] additional_redirect_urls` includes `testpoint://auth-callback` (D9).
- Email / password sign-in is not used by the app; the local dev account in
  `seed.sql` is only for tests and manual checks.

---

## 5. Phases

Each phase ends with the checks in §9. Phases follow the PRD milestones (M1–M6),
with a Phase 0 added for housekeeping.

### Phase 0 — Housekeeping

**Tasks**
- Rename `lib/common/` → `lib/core/` and `lib/modules/projects/` → `lib/modules/workspaces/`.
- Replace the counter template in `lib/main.dart` with `ProviderScope` + `App`.
- Create `lib/app/app.dart`, `lib/app/router/`, `lib/app/di/`.
- Add first dependencies: `flutter_riverpod`, `go_router`, `freezed_annotation`,
  `json_annotation`; dev: `build_runner`, `freezed`, `json_serializable`, `mocktail`.
- Tighten lints in `analysis_options.yaml` (e.g. `prefer_final_locals`,
  `always_declare_return_types`, `avoid_print`).
- Replace the template widget test with an app smoke test.

**Done when** `flutter analyze` and `flutter test` pass and the app opens an empty window.

### Phase 1 — Foundation (M1)

**Tasks**
- `core/error/`: `Failure` types (`NetworkFailure`, `StorageFailure`,
  `ValidationFailure`, `AuthFailure`, `UnexpectedFailure`) and a `Result<T>` type.
- `core/ui/theme/`:
  - `ColorScheme` seeded from `#0F9D8A`, dark (primary) and light, using the
    tokens in the design doc.
  - `ThemeExtension` for HTTP method colors and status colors.
  - Bundled fonts: Google Sans Flex, Inter, JetBrains Mono (`pubspec.yaml` assets).
  - Shape and spacing constants (radius 6/12/16/28; spacing 4/8/12/16/24/32).
- `core/ui/widgets/`: `MethodPill` (fixed 52 px), `StatusChip`, `VariableChip`.
- Shell layout in `lib/app/`: 72 px nav rail, 44 px top bar, 280 px sidebar,
  28 px status bar; resizable panes with `multi_split_view`.
- `window_manager`: title and minimum window size.
- `go_router` routes for Collections, Environments, Settings.
- Supabase setup:
  - `supabase init`; base migrations from §4; `seed.sql` with sample data.
  - `supabase_flutter` initialized in `main.dart` from `--dart-define`
    (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
  - `core/database/`: `supabaseClientProvider` and mapping of Supabase
    exceptions to `Failure`.
- `modules/auth`: sign in anonymously on start if there is no session; expose
  the current session state and a guest avatar shown at the bottom of the nav rail.
- `modules/workspaces`: load the current workspace for the signed-in user.
- Welcome (empty workspace) screen.

**Tests** `Result`/`Failure` mapping; auth repository with mocked client;
widget test for the shell and the Welcome screen in both themes.

**Done when** the app starts, signs in anonymously, loads the default
workspace and shows the Welcome screen in dark and light themes.

### Phase 2 — Request Loop (M2)

**Tasks**
- `core/network/`: Dio client provider; error interceptor that maps
  `DioException` to `NetworkFailure` (timeout, DNS / connection, invalid URL).
- `modules/requests`:
  - Models: `HttpRequestDraft`, `KeyValue`, `RequestAuth`, `RequestBody`, `HttpResponseResult`.
  - Method menu (`MenuAnchor`) and URL field.
  - Params / Headers tables (key, value, enabled); Params stay in sync with the URL query.
  - Auth tab: None, Bearer, Basic, API key.
  - Body tab: none, JSON (`re_editor` + `re_highlight`), form-data,
    x-www-form-urlencoded, raw.
  - `SendRequestService`: build the Dio request, measure time and size, support cancel.
  - Shortcuts: `Ctrl+Enter` send.
  - Response viewer: status chip, time, size; Body (pretty / raw) and Headers
    tabs; `Ctrl+F` search; copy body; loading and error states.
  - Pretty-print large JSON in a background isolate (`Isolate.run` / `compute`).
- Requests in this phase live only in memory (not saved yet).

**Tests** request building (params, headers, auth, body); response mapping;
error mapping; widget tests for the builder and the response viewer.

**Done when** a user can send GET/POST requests to a public API, cancel them,
and read the response, including a 5 MB JSON response, without the UI freezing.

### Phase 3 — Collections (M3)

**Tasks**
- `modules/collections`: repository (Supabase), service, providers.
- Sidebar: header with count and "Import", filter field (`Ctrl+K`),
  "+ New" split button, collection tree with method pills, footer request count.
- Context menu: rename, duplicate, delete (with confirm dialog).
- Collection overview screen.
- `modules/requests`: save / update / delete requests in a collection
  (repository + service); open request tabs with unsaved dot and close button;
  "+" new-tab button.

**Tests** collections and requests repositories (mocked client); services
(rename validation, duplicate naming); widget test for the sidebar tree and filter.

**Done when** collections and requests persist in Supabase across app restarts
and the tree, filter, tabs and context menu work.

### Phase 4 — Environments (M4)

**Tasks**
- `modules/environments`: repository, service, providers.
- Environments manager screen: list, create, rename, delete; variable table
  (key, value, secret, enabled) with masked secret values.
- Active environment dropdown in the top bar; name and base URL in the status bar.
- `VariableResolver` exposed in the public API; `requests` uses it for URL,
  params, headers, auth and body before sending.
- `{{var}}` autocomplete in the URL field (`RawAutocomplete` / `OverlayPortal`);
  unresolved variables shown as amber chips.

**Tests** resolver (nested, missing, disabled and secret variables); repository;
widget test for the variable table and autocomplete.

**Done when** switching environment changes the resolved URL and the sent request.

### Phase 5 — Import & Settings (M5)

**Tasks**
- `modules/import`:
  - cURL parser (method, URL, `-H`, `-d` / `--data-*`, `-u`, `-X`), no package.
  - Postman v2.1 importer: collections, folders flattened, requests, headers,
    body, basic/bearer auth; unsupported items listed as skipped.
  - Import dialog: paste cURL or choose a file (`file_picker`); summary of
    imported and skipped items.
- `modules/settings`: settings screen (theme: dark / light / system; timeout;
  follow redirects; proxy off / URL) saved with `shared_preferences`; applied
  to the theme and the Dio client.

**Tests** cURL parser and Postman importer with fixture files under
`test/fixtures/`; settings repository; widget test for the Import dialog.

**Done when** sample cURL commands and Postman v2.1 collections import
correctly, and settings changes take effect without a restart.

### Phase 6 — Account & Polish (M6)

Part A is the GitHub OAuth account flow and its UI/UX (Stitch screen #13); Part B
is the polish pass. Build Part A first so Part B can cover its screens.

#### Part A — Account: Continue with GitHub

_Moved here from the former Phase 5b. Method changed from email / password to GitHub OAuth (D1, D7–D9). Design: Stitch screen #13 (Account dialogs)._

**Flow**
- Clicking the avatar opens an **Account dialog** over the workspace (no route change).
- **Guest** user: dialog with one **Continue with GitHub** button and the helper
  "Signing in with GitHub keeps your guest workspace." No tabs, no email or password fields.
  1. **Link** (D7): `auth.linkIdentity(OAuthProvider.github, redirectTo: 'testpoint://auth-callback')`
     opens the browser; the dialog shows a **Waiting for GitHub** state with Cancel.
     When the redirect returns, the guest user now has a GitHub identity.
     Same user id, so all data is kept.
  2. **Existing account** (D8): if linking fails with `identity_already_exists`
     and the guest has any data, show a confirm dialog ("Your guest workspace
     will not be carried over"); on confirm, `auth.signInWithOAuth(OAuthProvider.github, ...)`
     and load that account's workspace. With no guest data, skip the warning.
- **Signed-in** user: a smaller dialog shows the GitHub name or email and a
  **Sign out** button. Sign out starts a fresh guest session; the account's data
  stays in the account.
- The avatar shows a guest icon for anonymous users and the user's initial (GitHub name, else email) when signed in.

**Tasks**
- `modules/auth`: `AuthRepository` (anonymous sign-in, `linkGitHub`,
  `signInWithGitHub`, sign out, session stream); providers for session state.
  The OAuth redirect is received through the registered URL scheme (D9) and
  handled by `supabase_flutter`'s deep-link support (`app_links` is already a
  transitive dependency, so no new package). The email / password code and
  `AuthService` were removed; providers call the repository contract directly.
- `widgets/account_dialog.dart` (guest: Continue with GitHub and Waiting for
  GitHub states), `widgets/signed_in_dialog.dart` (account + Sign out) and
  `widgets/guest_data_warning_dialog.dart`, opened with `showDialog` from
  the avatar; dialogs use the 28px dialog shape. No route in `app/router/`.
- Register the `testpoint://` URL scheme in the desktop runners:
  - **Windows (done):** `windows/runner/main.cpp` forwards the link to the
    running instance (`SendAppLinkToInstance`); `windows/register_url_scheme.ps1`
    writes the per-user registry keys for development builds (an installer must
    do the same for releases).
  - **macOS (done):** `CFBundleURLTypes` in `macos/Runner/Info.plist`. Not built or tested yet.
  - **Linux (written, unbuilt):** `linux/testpoint.desktop` registers
    `x-scheme-handler/testpoint`, and `linux/runner/my_application.cc` is now a
    unique `GApplication` that handles the command line (raises the running
    window on a second launch). Not built or tested yet; forwarding the link to
    Dart on a running instance still needs checking on Linux.
- Map Supabase `AuthException` cases (`identity_already_exists`, provider
  disabled, user cancelled / access denied, network) to `AuthFailure` with clear messages.
- When the session user changes, reload the current workspace and clear open
  request tabs (`workspaces` and `requests` listen to the `auth` session provider).

**Tests** auth repository error mapping with a mocked client; session notifier
(link keeps the user id, existing account switches user, cancel leaves the guest
untouched, sign out starts a fresh guest); widget tests for the account dialogs,
the guest-data warning dialog and the avatar states, with a fake `AuthRepository`.

**Part A done when** a guest can continue with GitHub and keep their data, sign in
with the same GitHub account on a second machine and see the same collections,
and sign out back to a fresh guest session.

#### Part B — Polish

**Tasks**
- Light theme pass against the Stitch light variants (including the Account dialogs).
- Keyboard audit: every main action reachable; all hints say `Ctrl`.
- No-wrap audit: labels, chips, tabs and status text use ellipsis.
- Performance pass against PRD §7: cold start under 2 s, 60 fps scrolling,
  5 MB JSON response.
- Accessibility: WCAG AA contrast in both themes, focus order, tooltips.
- Widget tests for remaining key screens.
- Release builds for Windows, macOS and Linux.

**Part B status**
- Done: no-wrap audit test; contrast audit test (WCAG AA, both themes, with colour
  fixes: dark `onPrimary`, darker light HTTP colours, stronger input borders);
  tooltips on all icon buttons; large response bodies split into lines off the main
  isolate; Windows release build; cold start measured at about 1.2 s to window shown
  (release build, Windows, local Supabase).
- Open: light-theme comparison with the Stitch light variants (no light Account
  screen yet); Linux runner for `testpoint://`; macOS and Linux builds; keyboard
  control for the split-pane divider; demo of US-1 to US-10 on all three platforms.

**Part B done when** all PRD MVP stories (US-1 to US-10) can be demonstrated on all
three desktop platforms.

### Phase 7 — Design Fidelity Audit

Every screen was built while the Stitch designs were still changing (lost edits,
screens #6–#9 never got the shell pass). This phase compares each built screen
with its Stitch screen and fixes missing or wrong UI parts in Flutter. Stitch is
not edited in this phase.

**Source of truth when they disagree:** PRD scope + the shell standard in
[design/stitch-mvp-progress.md](design/stitch-mvp-progress.md) → Stitch HTML →
Stitch screenshot (can be stale). Out-of-scope items Stitch adds (Tests/Scripts
tabs, Share, Run collection, Sync, Console/Zoom/UTF-8, `⌘` hints, version
badges, breadcrumbs) are ignored.

**Tasks**
1. **Collect references:** download each screen's HTML and screenshot from
   Stitch into `docs/design/stitch-export/<nn>-<slug>.html|png`.
2. **Capture the app:** `test/app/design_audit/screen_captures_test.dart`
   (tag `design-audit`) renders each screen at 1280×800 in dark and light themes
   with the Stitch sample data (Petstore API, "Development" environment) and
   writes golden PNGs.
3. **Audit one screen at a time** and record findings
   (`Missing / Wrong / Extra / Nit`, file, status) in `docs/design/ui-audit.md`.
   Check: layout sizes (rail 72, top bar 44, sidebar 280, status bar 28, method
   pill 52), spacing and radii tokens, theme-only colors, fonts, copy and
   tooltips, `Ctrl` hints, states (hover, focus, selected, disabled, empty,
   loading, error), no wrapping, light theme.
4. **Fix** in this order: shell → shared widgets in `core/ui/widgets/` →
   screens #1–#13 → light theme. One commit per screen. A fix that needs new
   behavior goes through the module's provider/service with a unit test. An
   unclear or conflicting design part is marked `Decision needed` and skipped.

| # | Stitch screen | Main Flutter files |
| --- | --- | --- |
| S | Shell standard (from #1) | `app/shell/` (nav rail, top bar, status bar, sidebar), `core/ui/widgets/app_logo.dart`, auth `user_avatar.dart` |
| 1–3 | Request — Params, Body, Headers & Auth | `modules/requests/screens/request_screen.dart`, `request_bar.dart`, `url_field.dart`, `key_value_table.dart`, `body_tab.dart`, `auth_tab.dart` |
| 4–5 | Response — Success, Error & Loading | `response_viewer.dart`, `core/ui/widgets/status_chip.dart` |
| 6 | URL autocomplete & method menu | `url_field.dart`, `method_menu.dart`, `variable_chip.dart` |
| 7 | Collections — Context menu & Overview | `core/ui/widgets/context_menu.dart`, `app/screens/collection_overview_screen.dart` |
| 8 | Welcome | `app/screens/welcome_screen.dart` |
| 9 | Environments manager | `modules/environments/screens/environments_screen.dart`, `variable_table.dart`, `environment_dropdown.dart` |
| 10 | Import dialog | `modules/import/widgets/import_dialog.dart` |
| 11 | Settings | `modules/settings/screens/settings_screen.dart` |
| 12 | Dialogs & feedback | `core/ui/widgets/` dialogs and snackbar, `save_request_dialog.dart` |
| 13 | Account dialogs | `modules/auth/widgets/` dialogs |
| L1 | Response Success (Light) | `core/ui/theme/app_theme.dart`, `http_colors.dart` |

**Tests** golden captures for every screen in both themes; extend
`test/app/no_wrap_audit_test.dart` for screens it does not cover yet;
`test/core/ui/theme/contrast_test.dart` still passes.

**Status (2026-11-12):** harness, audit and most fixes are done (see
`ui-audit.md`). Open: five items marked `Decision needed` (layout toggle and
overflow menu, Bulk Edit, uppercase title and count, inline variable chips,
breadcrumb row). Only the screenshots were exported from Stitch, not the HTML.

**Done when** every screen has an audit section in `ui-audit.md` with all items
fixed (or a recorded decision), goldens exist for each screen in both themes,
and `flutter analyze` and `flutter test` pass. This also closes the Part B
"light-theme comparison" item.

---

## 6. Dependencies on Design Work

From the "Next steps" in [design/stitch-mvp-progress.md](design/stitch-mvp-progress.md):

| Design task | Needed before |
| --- | --- |
| Token handoff (`ColorScheme` + `ThemeExtension` values) | Phase 1 |
| Verify screens #5–#9 (Error & Loading, autocomplete, Collections, Welcome, Environments) | Phases 1–4 |
| Nit fixes on #1, #4, #11 | Phases 2 and 5 |
| Avatar at the bottom of the nav rail (shell standard update) | Phase 1 |
| New screen #13 "Account — Continue with GitHub" (being updated in Stitch from the email / password version) | Phase 6, Part A |
| Light variants | Phase 6, Part B |

The token values already in the design doc are enough to start Phase 1; the
other design tasks can run in parallel with development.

---

## 7. Testing Strategy

| Layer | Test type | Tools |
| --- | --- | --- |
| Services, parsers, resolver | Unit tests | `flutter_test` |
| Repositories | Unit tests with a mocked `SupabaseClient` / Dio | `mocktail` |
| Providers | Unit tests with `ProviderContainer` and overrides | `flutter_riverpod` |
| Key screens and widgets | Widget tests in dark and light themes | `flutter_test` |
| RLS policies and the bootstrap trigger | Manual checks against local Supabase | `supabase start`, `supabase db reset` |

Tests mirror `lib/` under `test/`. Fixtures (cURL samples, Postman files,
large JSON) go in `test/fixtures/`.

---

## 8. Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Guest session lost on reinstall before signing up | Guest loses access to their data | Prompt guests to sign up (avatar badge / hint in the status bar) |
| Guest data discarded when signing in to an existing account (D8) | Guest work is lost | Warning dialog before sign-in; merging is post-MVP |
| OAuth redirect (custom URL scheme) is not delivered on one desktop platform (D9) | Sign-in never completes | Test on all three platforms; the Waiting state has Cancel; fall back to a loopback redirect if a scheme cannot be registered |
| GitHub is the only sign-in method | Users without GitHub cannot create an account | Accepted for the MVP (developer audience); add other providers later |
| Orphaned guest rows in the database | Storage grows | Scheduled cleanup of old anonymous users (post-MVP) |
| Online-only | App is unusable without a network connection | Clear offline error state; revisit local cache (PRD Q2) |
| Large responses | UI freezes | Background isolate parsing; virtualized editor (`re_editor`); test with 5 MB fixture |
| Stitch designs still changing | Rework in UI | Build shell and shared widgets from the shell standard first; keep screens thin |
| RLS mistakes | Data leaks between organizations | Policies written in Phase 1 and checked with two test users locally |

---

## 9. Definition of Done (every phase)

- `flutter analyze` reports no issues.
- `flutter test` passes, with new tests for the phase's services and repositories.
- UI follows the shell standard (Ctrl hints, no wrapping, fixed method-pill width).
- Module boundaries respected: no imports into another module's internals.
- Docs updated when behavior or schema changes (`data_model.md`, `PRD.md`).
- The PRD user stories covered by the phase can be demonstrated.
