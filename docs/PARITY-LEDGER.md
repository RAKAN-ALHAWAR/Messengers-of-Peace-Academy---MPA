# Platform verification ledger

Updated: 2026-10-22. Current local execution: EXECUTION-2026-10-20.md.

| Surface | Status | Evidence / remaining work |
| --- | --- | --- |
| Shared Flutter code | Local remediation in progress | Session/async isolation, transport, profile, quiz, progress, calendars and list repairs have synthetic regressions. Native and backend acceptance remain separate. |
| iOS | Build, boot and user sign-in observed | iPhone 17 Pro / iOS 26.5; scenario navigation blocked by denied Device Hub Computer Use access. |
| Android | Debug build succeeds locally | Build at7868801, exit0; no runtime/emulator/native download/media result. Existing SDK XML/Kotlin warnings remain. |
| Moodle backend | Not verified | No backend source/schema in the app repository. Account testing was authorized, server administration was not. |
| Web counterpart | Not located | No web implementation is present in this repository. |
| Toast/Back and auth form flows | Shared Flutter repairs locally verified | Actual MyApp Back/Toast gestures, completion form and reset/controller/HTTP regressions:45 tests pass. iOS build exit0 with simulator-only target override. iOS/Android interactive and server retests remain open. |
| EditProfile counterpart | Local race/partial-success repair verified | Captured session/photo/text snapshot, stale-owner rejection and photo-only retry are covered locally. Required-field/clear/digit policies, live writes and native photo flow remain open. |
| Auth/session and quiz | Shared local repairs verified in scoped reviews | Exact expiry handling, uncertain answer/finalization recovery and result-slot handling pass synthetic checks; server ACL, secure storage migration, deadline/resume and authoritative grades remain unverified. |
| Learning progress | Local refresh/failure-state repairs verified | Mounted Home/Profile statistics and owned route-return refresh update actual widgets; completion failures keep server checkmarks. Minutes, unit totals, unlock/Next and file completion require backend contracts. |
| Lists and localized controls | Host widget checks only | Lazy Blog/Leaderboard/Notifications/MyCourses/Certificates/Meetings/AllCourses/Home course cards/level track tested with up to1000 records. Full titles, Latin numbers and certificate/button actions verified at scaled text. Badges/points catalogs and personal history remain active work; device frame/decode budgets remain open. |
| Build and CI | Final local gate in progress | Pinned Flutter3.41.6, isolated SDK caches and synthetic test resources. Foreign original pubspec.lock preserved; no remote CI run/push or product minimum-OS decision. |

All remaining gaps must be presented before any deployment. No deployment is
part of this audit.
