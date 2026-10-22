# Observed source map

Baseline `f338fa9`, inspected 2026-10-17. This is a map of existing source,
not adoption of an architecture or a replacement product specification.

## Startup and ownership of state

`lib/main.dart` initializes ConfigX, DataX and CoreX, then constructs MyApp with
GetMaterialApp. DataX opens the Hive app box. CoreX initializes metadata and
HTTP configuration. AppControllerX stores the reactive user and logged-in flag.
LoadingController calls AppControllerX.init and selects the saved route.
Routes and their GetX bindings are in `lib/Config/Route/route_list.dart`.

## Request chain

```text
feature view
  -> feature GetX controller
  -> DatabaseX static facade
  -> DBEndPointX endpoint selection + RemoteDataSourceX request/response policy
  -> HttpX / HttpRequestX / HttpResponseX
  -> Moodle REST service
  -> ModelUtilX validation and feature model factory
  -> controller state
  -> widgets
```

- Database facade: `lib/Data/Database/database.dart`.
- Endpoint definitions: `lib/Data/Database/config/database_end_point.dart`.
  Do not print literal credential values when inspecting this file.
- Remote adapter: `lib/Data/Database/remote/remote_data.dart` and `lib/build.dart`.
- HTTP helper: `lib/Core/Helper/http/`.
- Local preferences/session facade: `lib/Data/Local/`.
- Model validation/conversion: `lib/Core/Helper/model/model.dart` and
  `lib/Core/Extension/convert/convert.dart`.
- The downloader creates a separate Dio client in
  `lib/Core/Service/download_file_form_url.dart`.

The backend repository, schema, Moodle plugin implementation and API fixtures
were not located in this app checkout. Endpoint names do not prove server rules.

## Feature areas screened

- `lib/Ui/Screen/Auth/`: login, signup, verification, forgot/reset password,
  completing account information.
- `lib/Ui/Screen/Course/`, `Test/`, `Home/`, `My/MyCourses/`: learning content,
  video, attempts, assessment results and progression.
- `Events/`, `Meeting/`: calendar, event create/edit/details and meeting join.
- `Profile/`, `Notifications/`, `Ui/ScreenSheet/`: profile/password, notifications,
  complaints and language choice.
- `Blog/`, `My/MyCertificates/`, `My/MyAchievements/`, `Badges/`,
  `ActivityPionts/`, `Leaderboard/`: remaining data surfaces.
- `lib/Ui/Widget/`: shared components and asynchronous loading.
- `lib/Config/Translation/`: GetX maps in existing `ar/en/es/ph` source folders;
  remediated UI locales are `ar/en/es/fil`. Explicit backend language fields
  preserve `ph` through backendLanguageCode. Native localization remains open.
- `ios/` and `android/`: native permissions, transport, plugins and build setup.

Inventory found 303 Dart files under lib. Review coverage is reported by area;
this number is not a claim that every line has a runtime test.

## Local remediation seams2026-10-22

- `Core/Service/session_lease.dart` captures identity/revision/owner lifetime;
  LocalData credential writes invalidate leases synchronously. Session changes
  notify mounted FutureBuilderX widgets without requiring parent rebuilds.
- SessionExpiryX in the same lease service coordinates current-token expiry;
  AppController owns local authenticated-route recovery. General transport and
  Remote enforce status/ownership before fallback/publication.
- `Ui/Widget/Basic/Utils/future_builder.dart` retains request identity, supports
  explicit refresh/retry and retires obsolete data/callbacks by generation.
- BlogPage and the one-page database/archive controller replace the recursive
  archive loader; subsequent pages are on demand, deduplicated and retryable.
- `Ui/Widget/Custom/Other/course_carousel.dart` owns shared lazy course layout,
  exact per-pass text metrics and font/layout invalidation for Home/AllCourses.
  It retains O(N) value records; first sizing remains O(N), not constant cost.
- Shared ButtonX/ButtonStateX use minimum heights/full wrapping labels while
  preserving ordinary state dimensions. Session/profile/quiz/list regression
  fixtures live under test/, and use synthetic intercepted HTTP only.

These are observed implementation responsibilities, not new backend contracts.

## Records for continuation

- Current work/coordination: `docs/AUDIT-STATE.md`.
- Findings, requirement mapping, proposals: `docs/AUDIT-2026-10-17.md`.
- Completed local commands/evidence: `docs/LOCAL-VERIFICATION.md`.
- Platform gaps: `docs/PARITY-LEDGER.md`.
- Additional reproductions and urgent auth symptoms: `docs/SOURCE-FOLLOWUP-2026-10-18.md`.
- Missing backend information (proposed request): `docs/BACKEND-CONTRACT-REQUEST.md`.
- Full remediation proposal and finding/acceptance mapping: `docs/REMEDIATION-PLAN-2026-10-18.md`.
