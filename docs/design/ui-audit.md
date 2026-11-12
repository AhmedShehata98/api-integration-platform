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
| Missing | Top bar: layout toggle and overflow ⋮ menu | `app/shell/top_bar.dart`, `layout_toggle_button.dart` | Fixed: toggle stores `stackedLayout` in settings and switches the panes; menu has Import…, Close all tabs, Settings (tested) |
| Missing | Status bar: layout icon on the right | `app/shell/status_bar.dart` | Fixed (same toggle) |
| Nit | Sidebar title is "Collections", not uppercase "COLLECTIONS"; count is collections (2), Stitch shows 8 | `sidebar.dart` | Fixed: uppercase title. Count stays the number of collections (the footer already shows the request count) |
| Nit | Active request tab used a bottom underline; Stitch uses a top teal border | `modules/requests/widgets/request_tab_bar.dart` | Fixed |

## 1–3 — Request builder (Params, Body, Headers & Auth)

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| Missing | Send button has no `Ctrl+Enter` hint | `modules/requests/widgets/request_bar.dart` | Fixed (hint inside the button; tested) |
| Missing | Tabs have no count badges (Params 2, Headers 3) | `modules/requests/widgets/request_editor.dart` | Fixed (enabled, non-empty rows; hidden at 0; tested) |
| Nit | `{{baseUrl}}` chips are listed under the URL field; Stitch shows them inline in the URL | `modules/requests/widgets/variable_highlight_controller.dart` | Fixed: variables are colored in the field (teal resolved, amber undefined); the chip row under the field is removed (tested) |
| Nit | Request header row (breadcrumb, Save + `Ctrl+S` hint) | `request_screen.dart` | Not built: the plan lists breadcrumbs as out of scope; Save exists as an icon with a `Ctrl+S` tooltip |
| Missing | Table header ("Query Parameters", Key / Value) and "Bulk Edit" | `key_value_table.dart` | Bulk Edit fixed (`key: value` lines, `# ` disables a row; tested). Table header not built (not in PRD) |
| Nit | Empty response state: icon tile and `Ctrl+Enter` hint added; `RESPONSE` label with Status / Time / Size placeholders not added | `response_viewer.dart` | Fixed (placeholders skipped: not in PRD) |

Reviewed: Auth tab (segmented None / Bearer / Basic / API key, helper text) and Body tab (none / JSON / form-data / urlencoded / raw, highlighted JSON editor) match PRD §5.3 with no findings. The Headers table is the same widget as Params.

## 4–5 — Response

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| OK | 200 chip is green with time and size; JSON highlighted; Pretty / Raw and copy present | `response_viewer.dart` | — |
| Missing | `Ctrl+F` search affordance is not visible in the capture | `response_viewer.dart` | Open (verify) |
| Nit | Error state was an icon and one line; Stitch has a title and Retry | `response_viewer.dart` | Fixed (icon tile, "Request failed", message, Retry; tested) |
| Nit | Loading state not reviewed against Stitch | `response_viewer.dart` | Open |

## 6 — Autocomplete & method menu

| Type | Finding | File | Status |
| --- | --- | --- | --- |
| OK | Method menu lists 7 methods with fixed-width pills | `method_menu.dart` | — |
| OK | `{{var}}` autocomplete lists the active environment's variables as `{{name}}` in a mono menu under the field | `url_field.dart` | — |

## 7–13

| # | Screen | Status |
| --- | --- | --- |
| 7 | Collections context menu and overview | Reviewed: menu has New request, Rename, Duplicate, Delete (red) per PRD §5.2; overview lists requests with method pills and URLs; no findings |
| 8 | Welcome | Captured; logo, title and New request present; not compared in detail |
| 9 | Environments manager | Reviewed: variable table with enable toggle, secret lock + masked value with reveal, delete, Add variable and Save match PRD §5.5; no findings |
| 10 | Import dialog | Reviewed against PRD §5.6: cURL / Postman tabs, paste field, Cancel and Import present; no findings |
| 11 | Settings | Reviewed against PRD §5.7: theme, timeout, follow redirects and proxy present; no findings. Stitch layout not compared pixel by pixel |
| 12 | Dialogs & feedback | Save request dialog and delete confirm captured; save dialog shape and actions match. The dialog now preselects the first collection when one exists (tested). Snackbar was a light full-width bar covering the status bar; now floating on theme surfaces (`app_theme.dart`), captured in both themes |
| 13 | Account dialogs | Guest, Waiting, signed-in and guest-data warning captured in both themes. Layout, 28px shape, copy and actions match the spec; no findings (warning confirm uses the error-tinted button on purpose) |
| L1 | Light theme | All 14 captures exist in light; Response Success (light) reviewed and consistent with dark |

## Summary (2026-11-12)

- **Fixed:** status bar, nav rail label, sidebar header (uppercase title), filter hint, environment pill, layout toggle and overflow menu, Send hint, tab count badges, Bulk Edit, inline variable colors, response idle / error states, active-tab top border, Save dialog default collection, snackbar style.
- **Not built:** request breadcrumb row (out of scope per the plan), table header row (not in PRD).
- **Not done:** Stitch HTML was read for screen #1 only; the app was not run against a live Supabase for this phase (all checks are widget tests and goldens).
