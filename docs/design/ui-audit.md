# UI Audit — Built app vs Stitch (Phase 7)

_Started 2026-11-12 · Method: golden captures (`test/app/design_audit/goldens/`, 1280×800, dark + light, Petstore sample data) compared with the Stitch screenshots in `docs/design/stitch-export/` and the shell standard in [stitch-mvp-progress.md](stitch-mvp-progress.md)._

Refresh the captures:
`flutter test test/app/design_audit --dart-define=DESIGN_AUDIT=true --update-goldens`

**Method notes**
- Several Stitch screenshots are broken (screen #1 shows an empty nav rail and sidebar), so the shell standard text and the HTML of #1 were used as the source of truth when they disagree.
- Only the HTML of #1 was read. For other screens, HTML is pulled only when a screenshot detail is unclear.
- Out-of-scope Stitch items are ignored (Tests/Scripts tabs, Cookies tab, Share, Run collection, Sync, Console/Zoom/UTF-8, `⌘` hints, breadcrumbs, Description column).

Status values: **Fixed** · **Open** · **Decision needed** (conflicting or needs new behavior; skipped).

## S — Shell

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| Wrong | Status bar: environment and proxy text stopped partway across (a `Spacer` and a `Flexible` shared the free space), so Proxy was not on the right edge | `app/shell/status_bar.dart` | Fixed |
| Missing | Status bar: green "Ready" dot; environment text belongs next to Ready on the left | `app/shell/status_bar.dart` | Fixed |
| Wrong | Nav rail label "Environments" was cut to "Environme…" | `app/shell/nav_rail.dart` | Fixed (scales down, one line) |
| Wrong | Sidebar header: "Collections" truncated; Import was an icon only; New was a small tonal button next to it | `app/shell/sidebar/sidebar.dart` | Fixed: title + count + "Import" text button, full-width teal New |
| Wrong | Filter field showed `Ctrl+K` only while focused | `app/shell/sidebar/sidebar.dart` | Fixed (always visible) |
| Wrong | Environment dropdown was a plain text button with a layers icon; standard is a pill with a dot | `modules/environments/widgets/environment_dropdown.dart` | Fixed |
| Missing | Top bar: layout toggle and overflow ⋮ menu | `app/shell/top_bar.dart` | Decision needed (no layout setting exists; needs provider + test) |
| Missing | Status bar: layout icon on the right | `app/shell/status_bar.dart` | Decision needed (same as above) |
| Nit | Sidebar title is "Collections", not uppercase "COLLECTIONS"; count is collections (2), Stitch shows 8 | `sidebar.dart` | Decision needed |
| Nit | Active request tab uses a bottom underline; Stitch uses a top teal border | `modules/requests/widgets/request_tab_bar.dart` | Open |

## 1–3 — Request builder (Params, Body, Headers & Auth)

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| Missing | Send button has no `Ctrl+Enter` hint chip | `modules/requests/widgets/request_bar.dart` | Open |
| Missing | Tabs have no count badges (Params 2, Headers 3) | `modules/requests/widgets/request_editor.dart` | Open |
| Wrong | `{{baseUrl}}` chip is shown under the URL field; Stitch shows it inline in the URL | `modules/requests/widgets/url_field.dart` | Open |
| Missing | Request header row (collection / name, Save + `Ctrl+S` hint) | `request_screen.dart` | Open |
| Missing | Table header ("Query Parameters", Key / Value) and "Bulk Edit" | `key_value_table.dart` | Decision needed (Bulk Edit is new behavior) |
| Nit | Empty response state has no card, shortcut chip, or `RESPONSE` label with Status / Time / Size placeholders | `response_viewer.dart` | Open |

Not reviewed in detail yet: Body and Auth tab captures (`02_*`, `03_*`).

## 4–5 — Response

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| OK | 200 chip is green with time and size; JSON highlighted; Pretty / Raw and copy present | `response_viewer.dart` | — |
| Missing | `Ctrl+F` search affordance is not visible in the capture | `response_viewer.dart` | Open (verify) |
| Nit | Error state is an icon and one line; Stitch has a card with a title, hint and Retry | `response_viewer.dart` | Open |
| Nit | Loading state not reviewed against Stitch | `response_viewer.dart` | Open |

## 6 — Autocomplete & method menu

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| OK | Method menu lists 7 methods with fixed-width pills | `method_menu.dart` | — |
| — | `{{var}}` autocomplete popup not captured yet (needs typing into the URL field) | `url_field.dart` | Open |

## 7–13

| # | Screen | Status |
| --- | --- | --- |
| 7 | Collections context menu and overview | Overview captured and looks consistent; context menu capture not reviewed |
| 8 | Welcome | Captured; logo, title and New request present; not compared in detail |
| 9 | Environments manager | Captured with an environment selected; not reviewed |
| 10 | Import dialog | Captured; tabs and actions present; not compared in detail |
| 11 | Settings | Captured; has Theme, timeout, redirects, proxy toggle; Stitch layout not compared |
| 12 | Dialogs & feedback | Only the New menu is captured; save and delete dialogs and the snackbar still to add |
| 13 | Account dialogs | Guest dialog captured; Waiting, signed-in and warning dialogs still to add |
| L1 | Light theme | All 14 captures exist in light; Response Success (light) reviewed and consistent with dark |
