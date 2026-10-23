# Platform verification ledger

Updated: 2026-10-23. Current local execution: EXECUTION-2026-10-20.md.

| Surface | Status | Evidence / remaining work |
| --- | --- | --- |
| Shared Flutter code | Local remediation in progress | Session/async isolation, transport, profile, quiz, progress, calendars and list repairs have synthetic regressions. Native and backend acceptance remain separate. |
| iOS | Declared iOS15 simulator build succeeds | Owner approved15 minimum;17140ac builds without target override, produced plist/Mach-O min15. Earlier boot/sign-in was iPhone17Pro/iOS26.5; scenario navigation deferred after denied Device Hub access. Actual iOS15 device acceptance remains open. |
| Android | Debug build succeeds locally | Build at17140ac, exit0 with actual APK summary32.5s; no runtime/emulator/native download/media result. Existing SDK XML/Kotlin warnings remain. |
| Moodle backend | Not verified | No backend source/schema in the app repository. Account testing was authorized, server administration was not. |
| Web counterpart | Not located | No web implementation is present in this repository. |
| Toast/Back and auth form flows | Shared Flutter repairs locally verified | Actual MyApp Back/Toast gestures, completion form and reset/controller/HTTP regressions:45 tests pass. iOS build exit0 with simulator-only target override. iOS/Android interactive and server retests remain open. |
| EditProfile counterpart | Local race/partial-success repair verified | Captured session/photo/text snapshot, stale-owner rejection and photo-only retry are covered locally. Required-field/clear/digit policies, live writes and native photo flow remain open. |
| Auth/session and quiz | Shared local repairs verified in scoped reviews | Exact expiry handling, uncertain answer/finalization recovery and result-slot handling pass synthetic checks; server ACL, secure storage migration, deadline/resume and authoritative grades remain unverified. |
| Learning progress | Local refresh/failure-state repairs verified | Mounted Home/Profile statistics and owned route-return refresh update actual widgets; completion failures keep server checkmarks. Minutes, unit totals, unlock/Next and file completion require backend contracts. |
| Lists and localized controls | Host widget checks only | Lazy Blog/Leaderboard/Notifications/MyCourses/Certificates/Meetings/AllCourses/Home course+level tracks/Badges/ActivityPionts/MyAchievements tested with up to1000 records. Full titles/numbers, headers and actions verified at scaled text; shared points-card callers and numeric-boundary wrapping reviewed. Whole-list API retrieval, O(N) client data and device frame/decode budgets remain open. |
| Build and CI | M0 local gate verified; integration next | Pinned Flutter3.41.6/Dart3.11.4 now in a durable SDK path, matching approved locks/manifest minima and iOS15 configuration. Original locks backed up before replacement.605 cases/strict analyzer/both builds pass; actual remote CI and device scenarios stay open. |

All remaining gaps must be presented before any deployment. No deployment is
part of this audit.
