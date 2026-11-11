# Test Point — Stitch MVP Design: Progress Notes

_Last updated: 2026-11-10. Resume from "Next steps"._

## Goal
MVP screens for Test Point, a lightweight Postman/Insomnia-style desktop API client built with Flutter.
Style: Material 3 Expressive, teal brand, dark theme first and light theme after. Only the core features are in scope.

**Decisions**
- Theme: Dark (primary) + Light variant
- Brand seed: Teal `#0F9D8A`
- MVP extras: Environments & variables, Import (cURL / Postman v2.1), Settings. History excluded.
- Out of scope (future iterations): history, pre-request/test scripts, runner, mock servers, monitors, GraphQL/gRPC/WebSocket, OAuth2, codegen, sync/teams/sharing, cookie editing, certificates, console, visualizer.

## Stitch references
- Project: **Test Point — MVP**, ID `3561297165959721299` (https://stitch.withgoogle.com)
- Design system Dark: `assets/1955584032106423519`
- Design system Light: `assets/11861585566286790069`
- Fonts: Google Sans Flex (headline), Inter (UI), JetBrains Mono (code/URLs). Roundness ROUND_TWELVE, colorVariant EXPRESSIVE.
  Note: the generated HTML uses Public Sans for headlines. Ignore this; Flutter will use the design-system fonts.

### Token notes (from designMd)
| Token | Dark | Light |
|---|---|---|
| Background | `#0E1513` | `#F5FBF8` |
| Surface container | `#161D1B` | `#EAF2EF` |
| Surface high | `#1E2624` | `#E0EAE6` |
| Outline | `#3F4946` | `#BFC9C5` |
| Primary | `#0F9D8A` | `#006B5E` |
| GET | `#34C759` | `#1E8E3E` |
| POST | `#F5A524` | `#B26A00` |
| PUT | `#4C9AFF` | `#1A66D2` |
| PATCH | `#A78BFA` | `#7C4DDB` |
| DELETE | `#F25F5C` | `#C62828` |
| HEAD/OPTIONS | `#9AA4A2` | `#5F6B68` |

Status chips: 2xx green, 3xx blue, 4xx amber, 5xx red. An unresolved `{{var}}` is shown as an amber chip with a dotted underline.
Shape: cards 12–16px, dialogs 28px, pill buttons, tags 6px, inputs 12px. Spacing: 4/8/12/16/24/32.

## Screen inventory (dark)
| # | Screen | Screen ID | Status |
|---|---|---|---|
| 1 | Request Builder — Params (base layout for the shell) | `ed998a08cff84f2bb84eedb841b0436d` | ✅ Shell standard verified in HTML (2026-11-10). Nits: `{baseUrl}` chip shows single braces; Send hint `Ctrl+↵` → `Ctrl+Enter` |
| 2 | Request — Body (JSON) | `4c01036bbdb74674888855b2cbe9f395` | ✅ Shell standard verified. The edit created this **new** screen; the old `d6e2924243da4523b6e7ee0a0ce72fa1` is stale, so delete it in the Stitch UI |
| 3 | Request — Headers & Auth | `48099dc4b4e04c1db230e0bc117c661c` | ✅ Shell standard verified in HTML (2026-11-10) |
| 4 | Response — Success | `e0408493e8294cf3ad161b043becaa96` | ✅ Shell mostly verified. The edit created this **new** screen; the old `1215c64090fe4c0d939084d99c3c95ec` is stale, so delete it in the Stitch UI. Nits: remove the "Tests" request tab; the search tooltip says `⌘F` (should be `Ctrl+F`); the 200 chip is teal (2xx should be green) |
| 5 | Response — Error & Loading | `a8e02c1a0f7746d7a824baac0d30960a` | ✅ Shell standard + guest avatar verified in HTML (2026-11-10, second pass; edit landed in place after ~8 min) |
| 6 | URL variable autocomplete & method menu | `22b2c180a74c48ac86eec96893438acf` | ❌ First edit was lost (HTML still old). Second shell + avatar edit sent 2026-11-10; **not landed after 13 min**: re-check |
| 7 | Collections — Context menu & Overview | `873ceb87a55f478c852c3de677bbfe5b` | ❌ First edit lost. Issues: "TESTPOINT" logo text, "+" and "JD" avatar in rail, `⌘K`, "Synced", cookie/gear top-bar icons, Share / Run collection / Pre-request Scripts, UTF-8 and Zoom in status bar. Needs shell + guest avatar edit (keep Export) |
| 8 | Welcome — Empty workspace | `1944f19e6dea46ed8e8e545fa2bed3ee` | ❌ First edit lost. Issues: no avatar, `⌘K`, code/eye top-bar icons, "v1.0.0" badge, text mentions GraphQL / OpenAPI / scripts / tests, `Ctrl+↵`, status bar has UTF-8 / Zoom / Console. Needs shell + avatar edit |
| 9 | Environments manager | `99e290784847420d8009bab4cc14a1f1` | ❌ First edit lost. Issues: gradient logo + "TP v1.0" + divider, no avatar, breadcrumb in top bar, code/eye/gear icons, "PINNED" Globals, status bar UTF-8 / Zoom / Console. Needs shell + avatar edit |
| 10 | Import dialog | `ced12a93fd1a4957a19067a618d7089e` | Good |
| 11 | Settings | `2deb00d7f4c84bef8b3570ebfc07b4ba` | ✅ Shell standard applied in place via DOM ops (2026-11-10). Nits: logo is a gradient tile with a divider below it, and the top bar has a "Test Point / Settings" breadcrumb plus a "Saved" chip |
| 12 | Dialogs & feedback components sheet | `db66394568e7446c898bc41af769ac4b` | Good |
| 13 | Account dialogs — GitHub OAuth & Waiting state | `d08e5905101f4d4e9e6e6d87fa3a7bea` | ✅ Dark: 440px 28px-radius dialogs over the dimmed shell: "Account" with a neutral "Continue with GitHub" button and "Signing in with GitHub keeps your guest workspace.", and "Waiting for GitHub" with spinner and Cancel. Built in Flutter. Still to design: signed-in dialog and guest-data warning (built from the doc spec), light variant |
| — | Stale duplicates `d6e29242…`, `1215c640…`, `89a58325…` | — | ✅ Gone from `list_screens` (2026-11-10) |
| — | Fallback generation of #5 (sent 2026-11-10) | — | Never appeared. If a second "Response — Error & Loading states" shows up later, delete it and keep `a8e02c1a…` |
| L1 | Response Success (Light), early variant | `19efbd895bee44e4bcc073fc8c6bd39b` | Made too early; regenerate after the dark screens are fixed |

## Known issues found in review
- **Text wrapping and clipping** in the Stitch renders, for example "Form-/data", "SECRE/T", "PINNE/D", "Active/Environment", a squashed filter field ("Fil"), names cut short ("List p…"), and status-bar text split over two lines.
- **Inconsistent shell across screens:** the logo (TP circle / bolt / "TEST POINT" / "TP v1.0"), the rail-bottom items (+, avatar, help), the top-bar icons (code, eye, gear, cookies), the sidebar title (EXPLORER vs COLLECTIONS), ⌘/^ vs Ctrl, DEL vs DELETE, pill vs plain method tags, and the status-bar contents (Console, Zoom, UTF-8).
- **Out-of-scope items Stitch keeps adding:** Tests/Scripts tabs, Visualizer, Sync/Synced, Share, Run collection, Audit log. (The user avatar is now in scope: see the shell standard.)

## Stitch MCP gotchas
- `generate_screen_from_text` and `edit_screens` usually return **"operation timed out"**. A generation still finishes server-side (2–6 min), so poll with `list_screens` and don't retry blindly. A **timed-out edit is sometimes lost** (this happened to Welcome and Error once), so check the HTML afterwards.
- In-place DOM edits **do not refresh the screenshot**: the file ID and size stay the same. To verify, download the HTML (`download_file` on `htmlCode.name`) or look in the Stitch UI.
- `download_file` screenshots are large base64 JSON. They are auto-saved to tool-results and can be decoded with PowerShell `[Convert]::FromBase64String`.
- `update_design_system` returned "invalid argument". It isn't needed, because the design systems exist and are passed via `designSystem` on generation.
- `GEMINI_3_5_FLASH_LITE` handled small text-only edits quickly without timing out.
- A timed-out edit can take **8+ minutes** to land (#5 on 2026-11-10). Wait at least 10 minutes before treating it as lost, and **do not send a fallback generation meanwhile**: jobs seem to queue per project, so an extra job delays the next edit (#6 had not landed after 13 min while a #5 generation was queued).
- A timed-out edit can land as a **new screen** with the same title instead of updating in place (this happened to Body and Response Success). After each edit, compare the `list_screens` output for new IDs as well as changed `htmlCode.name` values.

## SHELL STANDARD (apply to every workspace screen)
- **Nav rail 72px:** top is the teal rounded-square bolt logo only, with no text, version or dot. Items are icon above label, label 11px on one line: Collections, Environments, Settings. The active item gets a teal tonal pill and teal text. The bottom holds only the theme toggle (moon), help (?) and the user avatar (guest icon for anonymous users, the user's initial when signed in; click opens the Account dialog). No "+" button.
- **Top bar 44px:** request tabs show a method pill and the full name on one line (max 200px, then ellipsis), an amber unsaved dot and a close ×, followed by a "+" new-tab button. The right side holds only the environment dropdown pill (green dot + "Development" + chevron), a layout toggle and an overflow ⋮. No code, eye, gear or cookies icons.
- **Collections sidebar 280px:** a header row with "COLLECTIONS" and the count "8" on the left and "Import" on the right; a filter field ("Filter requests" with a "Ctrl+K" hint); a full-width teal "+ New" split button; the tree under "Petstore API" (GET List pets, POST Create pet, GET Get pet by ID, PUT Update pet, PATCH Update pet status, DEL Delete pet) plus a collapsed "Authentication" (2). Method pills are a fixed 52px wide. The footer shows only "8 requests".
- **Status bar 28px:** the left side shows "Ready" and "Development · http://localhost:8080"; the right side shows "Proxy: Off" and a layout icon. No Console, Zoom or UTF-8.
- **Keyboard hints:** always Ctrl, never ⌘ or ^.
- **No wrapping:** every label, chip, badge, tab, button and status text stays on one line with no clipping or overlap, and containers grow to fit.

## Next steps
1. ~~Verify #1–#4~~ Done 2026-11-10 (see the inventory). In the Stitch UI, delete the stale `d6e29242…` (old Body), `1215c640…` (old Response Success) and `89a58325…` (duplicate Params).
2. Shell + avatar pass, **one screen at a time, wait ≥10 min each**: #5 ✅ done; #6 edit pending (check `htmlCode.name` / new same-title screen); then #7, #8, #9 (issues listed in the inventory). The prompt is the SHELL STANDARD section below plus the screen-specific removals.
3. Avatar + nit pass on #1–#4 and #11 (avatar at rail bottom on all of them). Nits: #1 `{{baseUrl}}` double braces and `Ctrl+Enter`; #4 remove the Tests tab, `⌘F` → `Ctrl+F`, green 2xx chip; #11 a flat tonal bolt logo with no divider, and drop the breadcrumb and Saved chip from the top bar.
3b. Generate #13 Account dialogs with the Dark design system, each shown as a modal dialog (28px radius, scrim) over the dimmed workspace shell: **13a** guest dialog (one "Continue with GitHub" button, "Signing in with GitHub keeps your guest workspace", plus a "Waiting for GitHub" state with Cancel) and **13b** signed-in dialog (GitHub name or email + Sign out) plus the guest-data warning dialog ("Your guest workspace will not be carried over", Cancel / Sign in anyway). These could also be added to the #12 dialogs sheet.
4. ~~Fix #11 Settings~~ Done 2026-11-10.
5. Re-check every screen for wrapping, clipping and consistency.
6. Then generate the light variants (`generate_variants`, REFINE, COLOR_SCHEME, using the light tokens above) for Params, Response, Environments, Welcome and Account (13a), and delete the early L1 variant.
7. Write the design-to-Flutter handoff: map the tokens to `ColorScheme` plus a `ThemeExtension` (method/status colors) for `lib/core/ui/theme/`.
