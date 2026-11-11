# Test Point — Product Requirements Document (MVP)

_Status: Draft · Last updated: 2026-11-10_

Related docs:
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Data model: [data_model.md](data_model.md)
- Design progress (Stitch): [design/stitch-mvp-progress.md](design/stitch-mvp-progress.md)
- Agent / coding rules: [../agents.md](../agents.md)
- Implementation plan: [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)

---

## 1. Overview

**Test Point** is a lightweight desktop API client built with Flutter. Developers
use it to build, send, organize and inspect HTTP requests, in the style of
Postman or Insomnia but faster and simpler.

**Product goal:** make connecting, running and validating API calls simple,
fast and reliable, with a clean developer experience.

## 2. Problem

Existing API clients are heavy: slow start-up, crowded UIs and many features
most developers never use. Developers want a tool that opens fast, keeps the
request/response loop tight, and shows only what matters.

## 3. Target Users

| Persona | Needs |
| --- | --- |
| Backend developer | Quickly hit local and staging endpoints, switch environments, inspect JSON responses |
| Frontend / mobile developer | Explore an API, check payloads and status codes, import existing Postman collections or cURL commands |
| QA engineer | Organize requests into collections and re-run them against different environments |

## 4. Goals and Non-Goals

### Goals (MVP)
1. Send any HTTP request and inspect the response within one screen.
2. Organize requests into collections inside a workspace.
3. Reuse values across requests with environments and `{{variables}}`.
4. Bring existing work in by importing cURL commands and Postman v2.1 collections.
5. Feel fast and polished on desktop, in dark and light themes.

### Non-Goals (future iterations)
Request history, pre-request / test scripts, collection runner, mock servers,
monitors, GraphQL / gRPC / WebSocket, OAuth2, code generation, sync / teams /
sharing, cookie editing, client certificates, console, response visualizer.

---

## 5. Scope — MVP Features

Each feature maps to a module under `lib/modules/`.

### 5.1 Workspace shell (`app/`, `core/ui/`)
- Nav rail (Collections, Environments, Settings) with theme toggle, help and the user avatar at the bottom.
- Top bar with request tabs (method pill, name, unsaved dot, close) and a "+" new-tab button.
- Environment dropdown in the top bar; layout toggle; overflow menu.
- Status bar showing state ("Ready"), active environment + base URL, and proxy state.
- Empty-workspace welcome screen.

### 5.2 Collections (`modules/collections`)
- Create, rename, delete collections.
- Tree view of collections and their requests with method pills.
- Filter requests (`Ctrl+K`).
- Context menu: rename, duplicate, delete.
- Collection overview page.

### 5.3 Request builder (`modules/requests`)
- Method selector: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS.
- URL field with `{{variable}}` autocomplete; unresolved variables shown as amber chips.
- Tabs: **Params**, **Headers**, **Auth**, **Body**.
  - Params / Headers: key–value table with enable toggle.
  - Auth: None, Bearer token, Basic auth, API key.
  - Body: none, JSON (code editor with highlighting), form-data, x-www-form-urlencoded, raw text.
- Send (`Ctrl+Enter`) and cancel an in-flight request.
- Save request to a collection; unsaved changes marked on the tab.

### 5.4 Response viewer (`modules/requests`)
- Status chip colored by class (2xx green, 3xx blue, 4xx amber, 5xx red), time, size.
- Tabs: **Body** (pretty JSON with highlighting, raw view), **Headers**.
- Search inside the response (`Ctrl+F`), copy body.
- Loading state, and clear error states (timeout, DNS / connection failure, invalid URL).

### 5.5 Environments (`modules/environments`)
- Create, rename, delete environments per workspace.
- Variable table: key, value, secret flag (masked), enabled.
- Select the active environment from the top bar.
- Variables resolve in URL, params, headers, auth and body.

### 5.6 Import (`modules/import`)
- Paste a cURL command → new request.
- Choose a Postman v2.1 collection file → new collection with requests.
- Show a summary of what was imported and what was skipped.

### 5.7 Settings (`modules/settings`)
- Theme: dark (default) / light / system.
- Request defaults: timeout, follow redirects.
- Proxy: off / custom proxy URL.
- Settings are stored on the device.

### 5.8 Account (`modules/auth`)
- The app starts with Supabase **anonymous sign-in**, so the user can work right away as a guest.
- First sign-in creates a personal organization and a default workspace.
- Clicking the **user avatar** opens an **Account dialog** over the workspace (no separate route):
  - **Guest:** dialog with one **Continue with GitHub** button (GitHub OAuth is the only sign-in method; no email or password).
    The browser opens GitHub, then returns to the app. While waiting, the dialog shows a "Waiting for GitHub" state with Cancel.
  - **First time with GitHub:** the GitHub identity is linked to the guest user in place, so all guest data is kept.
  - **GitHub account already used** in Test Point: if the guest has data, a warning says it
    will not be carried over; after confirming, the account's workspace loads.
  - **Signed in:** a smaller dialog shows the GitHub name or email and **Sign out**. Sign out starts a fresh guest session.
- The avatar shows a guest icon for guests and the user's initial (GitHub name, else email) when signed in.
- Errors (sign-in cancelled, GitHub access denied, provider unavailable, network) show clear messages.
- Merging guest data into an existing account is post-MVP.

---

## 6. User Stories

| ID | As a… | I want to… | So that… |
| --- | --- | --- | --- |
| US-1 | developer | send a request and see status, time, size and body | I can check an endpoint quickly |
| US-2 | developer | save requests into collections | I can reuse them later |
| US-3 | developer | define `{{baseUrl}}` per environment | I can switch between local and staging in one click |
| US-4 | developer | paste a cURL command | I can reproduce a request from docs or browser dev tools |
| US-5 | developer | import a Postman collection | I can move my existing work over |
| US-6 | developer | use keyboard shortcuts | I can work without the mouse |
| US-7 | developer | read large JSON responses smoothly | the app stays responsive with real payloads |
| US-8 | developer | mark variables as secret | tokens are not shown on screen |
| US-9 | guest user | continue with GitHub from the avatar | I keep the work I did as a guest |
| US-10 | registered user | continue with GitHub on another computer | I see the same collections and environments |

---

## 7. Non-Functional Requirements

| Area | Requirement |
| --- | --- |
| Platforms | Desktop first: Windows, macOS, Linux |
| Performance | Cold start under 2 s; UI stays at 60 fps; a 5 MB JSON response opens without freezing the UI (parse off the main isolate) |
| Reliability | Requests can be cancelled; timeouts are configurable; no crash on malformed responses |
| Errors | Infrastructure errors never reach the UI raw; they are mapped to `Failure` types with clear messages |
| Security | Supabase Row Level Security on every table; only the anon key ships in the app; secret variables are masked in the UI |
| Accessibility | Keyboard navigation for all main actions; text contrast meets WCAG AA in both themes |
| UI consistency | Follows the shell standard in the design doc: `Ctrl` in all hints, no text wrapping, fixed method-pill width |

---

## 8. Design

- Material 3 Expressive, teal brand seed `#0F9D8A`, dark theme first, light theme second.
- Fonts: Google Sans Flex (headlines), Inter (UI), JetBrains Mono (URLs and code), bundled as assets.
- Method and status colors defined as a `ThemeExtension` in `lib/core/ui/theme/`.
- 12 MVP screens designed in Stitch; see the screen inventory in
  [design/stitch-mvp-progress.md](design/stitch-mvp-progress.md).

## 9. Technical Summary

- Flutter + Dart, modular monolith (see [ARCHITECTURE.md](ARCHITECTURE.md)).
- State: Riverpod · Routing: go_router · HTTP: Dio · Models: freezed + json_serializable.
- Database: Supabase (PostgreSQL); schema in [data_model.md](data_model.md), migrations in `supabase/migrations/`.
- Full package list and reasons: see **Core Stack** in [../agents.md](../agents.md).

---

## 10. Open Questions

| # | Question | Impact |
| --- | --- | --- |
| Q1 | ~~Is sign-in required for the MVP?~~ **Resolved:** start as an anonymous guest; the avatar opens an Account dialog with Continue with GitHub (see §5.8). | Auth module with Account dialogs |
| Q2 | Should the app work offline? With Supabase only, collections need a network connection to load. | May need a local cache |
| Q3 | Should secret variables be stored in Supabase or only on the device? | Security and sync behavior |
| Q4 | ~~`lib/common/` or `lib/core/`?~~ **Resolved:** rename `lib/common/` to `lib/core/`. | Folder rename (Phase 0) |

---

## 11. Milestones

| # | Milestone | Contents |
| --- | --- | --- |
| M1 | Foundation | Theme, fonts, shell layout, routing, Supabase setup, error types |
| M2 | Request loop | Request builder, send / cancel, response viewer |
| M3 | Organize | Collections, saving requests, tabs with unsaved state |
| M4 | Environments | Environments manager, variable resolution and autocomplete |
| M5 | Import & Settings | cURL and Postman import, settings screen |
| M6 | Account & Polish | Continue with GitHub account flow (§5.8), light theme, keyboard shortcuts, performance pass, tests |

## 12. Success Metrics

- Time from app start to first response under 10 s for a new user.
- No UI freeze on a 5 MB JSON response.
- 95%+ of sample Postman v2.1 collections import without errors.
- Crash-free sessions above 99.5%.
