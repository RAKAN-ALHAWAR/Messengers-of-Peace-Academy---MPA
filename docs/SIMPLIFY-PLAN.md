# Simplification plan: defensive layers into the owner's style

Status: DRAFT, not approved. Planning only; no code was changed.
Date: 2026-10-28. Base: `main` at b7bbcf9. Style reference: f338fa9 (2026-07-08).
Scope: `lib/` code added by the defensive work in f338fa9..main. Tests are edited only where a slice renames a symbol they use.

## 0. Ground truth this plan is built on

- `git diff --stat f338fa9..main -- lib`: 124 files, +7721 / -4749.
- Most of those added lines are NOT defensive layers. The largest rows are UI and model work (TestResults view 774, user.dart 518, levels_progress 497, button 332, dropdown 315, toast 276). They are out of scope here (see owner question 4).
- The defensive layers live in about 30 controllers plus 4 core files. Counts from `rg` on main:
  - `SessionLeaseX.capture(` call sites: 53, in 25 files.
  - Generation counters (`_loadGeneration`, `_visitGeneration`, `_navigationGeneration`, ...): 79 lines in 15 files.
  - `isClosed` checks: 86 lines in 26 files.
  - Hand-written "this controller is still the registered one" checks (`Get.isRegistered<T>() && identical(Get.find<T>(), this)`): 10 files; the same check for `AppControllerX`: 13 files.
  - `TranslationX.getLanguageCode ==` (locale still the same): 23 sites.
  - `RouteOriginX.capture()`: 4 sites (Home, AllCourses, MyCourses, ProfileDetails).
  - `TEMP(backend)` markers: 13 in 12 files.
  - Busy flags against double taps (`_openingCourse`, `_videoBusy`, `_openingProgressRoute`): 5 files.
- Every `isActive:` closure is assembled from the same six atoms, written out by hand each time:
  1. `!isClosed`
  2. this controller is still the registered instance of its type
  3. `AppControllerX` is still the same instance
  4. a generation counter still equals the captured value
  5. the locale is still the captured one
  6. the route is still the captured one (`Get.currentRoute == route` or `origin.isActive`)
  Example of the repetition, `lib/Ui/Screen/My/MyCourses/controller/controller.dart:28-36` and `:53-62`, `lib/Ui/Screen/Profile/ProfileDetails/controller/controller.dart:151-160`, `lib/Ui/Screen/Badges/controller/controller.dart:15-41`.
- The f338fa9 style: `//====` banners with "Injection of required controls / Variables / Functions / Lifecycle", short `///` comments, one obvious flow per method. Example: f338fa9 `BadgesController` is 13 lines; main is 54 lines, and fields sit above the banners.

## 1. What we found and what we took

Searched: Dart `async` package cancellation, cancellation tokens, Flutter `mounted` idiom, GetX lifecycle (`isClosed`, tags). House research index (`~/.claude/knowledge/research-index.md`): nothing on this topic.

| Source | Tier | What it says | Taken? |
|---|---|---|---|
| `CancelableOperation` (package:async), https://api.flutter.dev/flutter/async/CancelableOperation-class.html | 1 | Wraps a Future; `cancel()` drops its value or error. | Not taken. It cancels one Future the caller holds. The bugs here are about state that changes under the request (account, locale, route, controller instance), which a cancel call made by the controller cannot see. It would add a dependency-level concept without removing any check. |
| `use_build_context_synchronously` lint, https://dart.dev/tools/linter-rules/use_build_context_synchronously | 1 | After an `await`, check `mounted` before touching the widget. | Taken as the idea: `isClosed` is the GetX twin of `mounted`. The explanation document uses this analogy. |
| GetxController docs (`isClosed`, `onClose` before `onDelete`), https://pub.dev/documentation/get/5.0.0-release-candidate-9.3.3/get_state_manager_src_simple_get_controllers/GetxController-class.html | 1 | `isClosed` reports a closed controller. | Confirms `isClosed` alone is not enough for this app: a closed controller is not the problem when GetX hands back a DIFFERENT live instance of the same type, which is why the "registered instance" atom exists. |
| GetX tags (`Get.put(..., tag:)`), same docs | 1 | Instances of one type can be told apart by tag. | Not taken. Tagging every route's controller changes bindings and every `Get.find` call site: a behaviour-level change, out of scope. Recorded as a possible later step. |
| Request-id pattern (each request keeps an incrementing id, result applied only if it is still the latest), e.g. https://www.kindacode.com/article/ways-to-cancel-a-future-in-flutter-and-dart/ | 3 (lead only) | Same idea as the generation counters already in the code. | Confirms the counters are the common idiom; kept as plain `int` fields. |

Conclusion: no ready library replaces `SessionLeaseX`. The win is to stop writing its condition by hand 53 times: one small helper on the controller builds it from named options.

## 2. Inventory per mechanism

Verdicts: keep = leave as is; simplify = same mechanism, less code or clearer in the owner's idiom; merge = several hand-copies become one helper; remove = dead. "Lines" is est. net lines removed, basis: counted sites x lines per site in the current code.

| # | Mechanism | Files | Bug it prevents | Test that proves it | Verdict | Lines (est.) |
|---|---|---|---|---|---|---|
| 1 | `SessionLeaseX` core (user id + token + `sessionRevision` + `isActive`) | `lib/Core/Service/session_lease.dart` | A reply that arrives after logout, account switch or a same-value re-login writes into the new session. | `test/auth/session_lease_test.dart` (A to B to A, same-value login write, retired owner) | keep | 0 |
| 2 | `SessionExpiryX` (local expiry event, no server retry) | `session_lease.dart`, `app_controller.dart` | A 401 from an OLD session logs out the new one; two 401s log out twice. | `session_lifecycle_test.dart` "concurrent expiry clears once without a server logout", `session_lease_test.dart` "expiry only reports current explicit user credentials" | keep | 0 |
| 3 | Transport lease (`authenticates(url)`, "Session changed" throw, expiry report) | `lib/Data/Database/remote/remote_data.dart:26-41`, `lib/Core/Helper/http/http.dart:98-111` | A response for a previous token is returned to the new session. | `test/core/authenticated_transport_test.dart` | simplify (one shared `ErrorX` factory for the "Session changed" error, see #13) | 3 |
| 4 | Hand-built `isActive` closures (the six atoms) | 25 files, 53 sites | Each site prevents stale writes for its own screen. | per-screen tests listed in the slices | merge into one controller helper (section 3) | 180 to 230 |
| 5 | Ownership getters `_ownsApp`, `_ownsCourse`, `_ownsHome` and inline `identical(Get.find<T>(), this)` | `app_controller.dart:9`, `CourseDetails/controller.dart:48`, `Home/controller.dart:74`, 7 more inline | GetX keys controllers by type: closing one route can delete or replace another route's controller of the same type; work from the old instance must not write. | `session_lease_test.dart` "controller ownership and logout invalidate work", `course_lifecycle_test.dart`, `achievement_ownership_test.dart` "badge app ownership retires a pending result" | merge into the helper's `owned` getter | 35 to 45 |
| 6 | `_captureScope` | `CourseDetails/controller.dart:55-66` (6 calls) | Same as #4 for the course page (course id + locale + operation). | `course_lifecycle_test.dart`, `next_activity_test.dart` | merge (becomes the helper call) | 12 |
| 7 | Generation counters | 15 files, 79 lines | A newer load or tap must win over an older one still in flight (last request wins). | `cache_ownership_test.dart` "new calendar refresh retires an older in-flight result", `session_lifecycle_test.dart` "concurrent startup only publishes its newest request", `empty_home_test.dart` "a Home snapshot cannot overwrite a newer notification return" | keep as plain `int` fields (owner idiom); simplify only the comparisons into the helper's `also:` | 0 to 10 |
| 8 | Content / cache / pending leases (`_contentLease`, `_cacheLease`, `_pendingLease`, `_pendingOwner`, `_pendingLoad`) | CourseDetails, Home, AllCourses (record key) | Cached data of account A or locale X shown to B or Y; two rebuilds start two identical requests. | `cache_ownership_test.dart` "profile cache is reused only for its session and locale", `entry_route_ownership_test.dart` "rebuild reuses request and remount refreshes once" | keep; simplify comments and field grouping | 5 |
| 9 | Owner chaining (`getData(owner: lease)`) | Home, MyCourses, ProfileDetails, AllCourses | The refresh after returning from a child page must die if the tap that started it died. | `test/learning/refresh_owner_test.dart`, `entry_route_ownership_test.dart` "abandons ... before starting refresh" | keep | 0 |
| 10 | `RouteOriginX` (top route read from the navigator) | `lib/Core/Service/route_origin.dart`, 4 call sites | `Get.rawRoute` is null on the root page after `offAllNamed`, so every course-card tap there counted as stale and the page never refreshed. | `root_course_tap_test.dart` "Courses tab card opens the details on a fresh root page", "a card tap whose page was left gives no refresh after return" | keep as is (already small, comment explains the trap) | 0 |
| 11 | Busy flags against double taps | AllCourses, CourseDetails, Home, MyCourses, ProfileDetails | Two fast taps push the same page twice and run two refreshes. | `entry_route_ownership_test.dart` "repeated ... course tap retains the real return refresh" | keep; simplify the `finally` reset to one line each | 5 |
| 12 | `isClosed` checks after `await` (GetX `mounted`) | 26 files, 86 lines | Writing to a disposed controller's text controllers / Rx after the user left (OTP, password reset, login). | `otp_disposal_test.dart`, `password_reset_test.dart`, `login_reentry_test.dart`, `quiz_next_test.dart` | simplify: drop the ones that sit right next to a `lease.isCurrent` that already contains `!isClosed`; keep every standalone one | 15 to 25 |
| 13 | "Session changed. Please try again." error built by hand | `remote_data.dart`, Home (2), CourseDetails (2) | Same as #1. Translation key exists in 4 locale files and must stay byte-identical. | `authenticated_transport_test.dart`, `course_lifecycle_test.dart` "wrong-course response is rejected before publication" | merge into one `ErrorX.sessionChanged()` | 4 |
| 14 | `ExtendedFutureBuilder` lease + `sessionRevision` | `lib/Ui/Widget/Basic/Utils/future_builder.dart` | A widget-level future from account A finishes into B's screen; retry after a session change. | `test/ui/future_builder_test.dart` | keep (widget code, not a controller; the helper does not apply) | 0 |
| 15 | `AppControllerX` init / `clearLocalSession` / `_initRequest` | `lib/Core/Controller/App/app_controller.dart` | Startup with id but no token; late startup profile of A replaces B; double expiry. | `session_lifecycle_test.dart` (6 tests), `loading_startup_test.dart` | simplify: owner banners, use helper `owned`; logic unchanged | 8 |
| 16 | Login provisional lease | `lib/Ui/Screen/Auth/Login/controller/controller.dart:38-70` | A login that fails half-way must not leave a usable half-session. | `login_lifecycle_test.dart`, `login_expiry_retry_test.dart`, `login_incomplete_account_test.dart` | keep; `_capture` becomes the helper | 5 |
| 17 | Injectable seams `downloadFile`, `addLearnedSeconds` | `CourseDetails/controller.dart:31-36` | Hive writes hang inside fake-async tests. | `file_checkmark_test.dart`, `learned_minutes_test.dart` "time spent on a lesson video is added when the user returns" | keep as is | 0 |
| 18 | TEMP(backend): file-done flag, local video seconds | `CourseDetails/controller.dart:77-99, 397-407`, `activity.dart:20,25`, `local_key.dart:14`, `VideoPlayer/controller.dart:153` | Server never marks a file done and sends duration "0:00". | `file_checkmark_test.dart`, `lesson_duration_test.dart` | keep (tracked in `docs/BACKEND-REQUESTS.md`) | 0 |
| 19 | TEMP(backend): learned seconds | `user_statistics.dart:42`, CourseDetails `:304` | Server minutes stay 0. | `learned_minutes_test.dart` | keep | 0 |
| 20 | TEMP(backend): first course unlock | `first_course_unlock.dart`, Home `:163`, AllCourses `:54` | Entry exam is never open. | `first_course_unlock_test.dart` | keep (already one shared function; the two call-site comments may shrink to one line) | 2 |
| 21 | TEMP(backend): quiz-only course card, account deletion | `course_card.dart:27`, ProfileDetails `:208` | Quiz-only course shows 0 lessons; no deletion endpoint. | `lesson_counts_test.dart`, `delete_account_test.dart` | keep | 0 |
| 22 | Style drift (fields above banners, long agent comments, missing banners) | every touched controller | none (readability) | `flutter analyze` | simplify inside each slice | 40 to 80 |

Totals: 22 mechanisms. keep as is 10 (#1, #2, #9, #10, #14, #17, #18, #19, #21, and #7 as data), simplify 8 (#3, #8, #11, #12, #15, #16, #20, #22), merge 4 (#4, #5, #6, #13), remove 0. No dead mechanism was found: each one has a test that names its bug.

Est. lines removed: 310 to 430, basis the column above. That is about 4 to 6 percent of the +7721; the rest of the diff is feature and UI work.

## 3. The one new helper

A mixin in `lib/Core/Service/session_lease.dart` (same file as the lease, so the explanation document has one place to point to). Working name `LeaseOwnerX<T>` (owner question 1).

```dart
mixin LeaseOwnerX<T extends GetxController> on GetxController {
  /// This instance is still the live one of its type, and the app controller
  /// it was built with is still the live one
  bool get owned => ...; // atoms 1, 2, 3

  /// A lease for work started now: dies on logout, account switch, close,
  /// locale change, route change (when [route] is given) or when [also] fails
  SessionLeaseX lease({bool sameRoute = false, RouteOriginX? origin,
      SessionLeaseX? owner, bool Function()? also}) => ...; // atoms 4, 5, 6
}
```

Rules for the helper:
- It only bundles the atoms already written by hand. It never adds or drops an atom for a site. Each slice keeps a per-site checklist "atoms before / atoms after" in its handoff, and the reviewer checks it line by line.
- Sites that do NOT check atom 2 or 3 today (for example `Notifications` `:65` uses `!isClosed` only; `Badges` checks `app.user.value.id` inside a try because `user` is `late`) keep their exact atoms through flags or `also:`. If a flag list grows past three options, that site keeps its hand-written closure.
- Generation counters stay plain `int` fields in each controller and enter through `also: () => request == _loadGeneration`.

## 4. Slices (riskiest first)

Shared floor for every slice: behaviour unchanged; no edits to translation texts, UI look, or `lib/Ui/Section/UserStat/user_statistics.dart:22`; owner banners and short comments; `TEMP(backend)` markers stay. Flutter: `/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter`. Each slice runs `flutter analyze` (must print "No issues found!") and its tied tests (must print "All tests passed!" with the count equal to the pre-slice count for those files, recorded first).

### S1. Helper and transport (sequential, first)
- Files: `lib/Core/Service/session_lease.dart`, `lib/Core/Error/error.dart` (`ErrorX.sessionChanged()`), `lib/Data/Database/remote/remote_data.dart`, `lib/Core/Helper/http/http.dart`, `lib/Core/Controller/App/app_controller.dart`, new test cases in `test/auth/session_lease_test.dart`.
- Test-first (data integrity): new tests for `owned` and `lease(...)` (replaced instance of same type, closed, app replaced, locale change, route change, `also` false) written and watched RED before the mixin exists.
- Acceptance: AppControllerX uses `owned`; transport behaviour identical; new tests green.
- Verify: `flutter test test/auth/session_lease_test.dart test/auth/session_lifecycle_test.dart test/core/authenticated_transport_test.dart test/auth/loading_startup_test.dart && flutter analyze`
- Model: Sonnet 5.5 xhigh. XHIGH-REASON: defines the concurrency guard every other slice depends on.

### S2. CourseDetails (after S1)
- Files: `lib/Ui/Screen/Course/CourseDetails/controller/controller.dart`.
- Work: `_ownsCourse` and `_captureScope` become `owned` / `lease(...)`; keep `_contentLease`, both counters, `_videoBusy`, seams. Do NOT collapse the `openNext` condition (`:325-332`) into `lease.isCurrent`: the lease also requires `identical(course.value, selectedCourse)`, which is false after the refresh publishes a new course, so the two conditions differ on purpose. Keep it, comment why.
- Verify: `flutter test test/learning/course_lifecycle_test.dart test/learning/next_activity_test.dart test/learning/video_next_button_test.dart test/learning/file_checkmark_test.dart test/learning/lesson_duration_test.dart test/learning/learned_minutes_test.dart test/learning/lesson_counts_test.dart test/learning/progression_test.dart test/learning/refresh_owner_test.dart && flutter analyze`
- Model: Sonnet 5.5 xhigh. XHIGH-REASON: five overlapping async guards (load, visit, route, course identity, busy flag) on one page.

### S3. Home (after S1)
- Files: `lib/Ui/Screen/Home/controller/controller.dart`.
- Work: `_ownsHome` to `owned`; the five lease sites to the helper; keep `_pendingLoad` dedup, `_cacheLease`, counters, `RouteOriginX`.
- Verify: `flutter test test/learning/empty_home_test.dart test/learning/entry_route_ownership_test.dart test/learning/root_course_tap_test.dart test/learning/refresh_owner_test.dart test/learning/first_course_unlock_test.dart test/learning/mounted_statistics_refresh_test.dart test/learning/learned_minutes_test.dart && flutter analyze`
- Model: Sonnet 5.5 xhigh. XHIGH-REASON: shared in-flight request reuse plus owner chaining (concurrency).

### S4. Course lists and profile (after S1)
- Files: `lib/Ui/Screen/Course/AllCourses/controller/controller.dart`, `lib/Ui/Screen/My/MyCourses/controller/controller.dart`, `lib/Ui/Screen/Profile/ProfileDetails/controller/controller.dart`.
- Verify: `flutter test test/learning/root_course_tap_test.dart test/learning/entry_route_ownership_test.dart test/learning/refresh_owner_test.dart test/app/cache_ownership_test.dart test/profile/delete_account_test.dart test/profile/profile_integrity_test.dart test/learning/first_course_unlock_test.dart && flutter analyze`
- Model: Sonnet 5.5 high.

### S5. Auth screens (after S1)
- Files: controllers of `Auth/Login`, `Auth/OTP`, `Auth/SignUp`, `Auth/ForgotPassword`, `Auth/ForgotPasswordReset`, `Auth/CompleteAccountInfo`, `Loading`.
- Work: Login `_capture` to the helper; drop `isClosed` checks that duplicate a lease; keep standalone ones (timers, text controllers).
- Verify: `flutter test test/auth && flutter analyze`
- Model: Sonnet 5.5 high.

### S6. EditProfile (after S1)
- Files: `lib/Ui/Screen/Profile/EditProfile/controller/controller.dart` (45 lease lines, the densest file).
- Verify: `flutter test test/profile/upload_lifecycle_test.dart test/profile/profile_integrity_test.dart test/data/profile_serialization_test.dart && flutter analyze`
- Model: Sonnet 5.5 high.

### S7. Content screens (after S1)
- Files: controllers of `Blog/Blog`, `Notifications`, `Events/CalendarEvents`, `Events/EventDetails`, `Meeting/AllMeetings`, `Badges`, `My/MyAchievements`, `My/MyCertificates`.
- Verify: `flutter test test/app test/performance/counterpart_session_test.dart test/performance/counterpart_lists_test.dart test/performance/catalog_activity_lists_test.dart test/performance/vertical_feed_test.dart test/performance/pagination_test.dart && flutter analyze`
- Model: Sonnet 5.5 high.

### S8. Quiz screens (after S1)
- Files: controllers of `Test/TestInfo`, `Test/TestQuestions`, `Test/TestResults`.
- Verify: `flutter test test/quiz && flutter analyze`
- Model: Sonnet 5.5 high.

### Batch end (orchestrator, once)
- Full suite once: `flutter test` must print "+731: All tests passed!" plus the new S1 tests (expected 731 + N, N recorded by S1), and `flutter analyze` "No issues found!".
- Drive the app once on a simulator through: login, Home card tap, course page, video then Next, quiz return, profile edit, logout (F27; logic batch, so a short drive).
- One blind review of the merged batch (Opus 5.5 medium: it touches session and data-integrity logic), with the per-site atom checklists from every slice.

## 5. Overlaps and order

- `lib/Core/Service/session_lease.dart` and `app_controller.dart`: S1 only. Every other slice imports them, so S1 merges first.
- `test/learning/refresh_owner_test.dart`, `entry_route_ownership_test.dart`, `root_course_tap_test.dart`, `first_course_unlock_test.dart`: run by S2, S3 and S4, edited by none (unless a renamed private symbol leaks, which no test does today: no test mentions `_owns`, `_captureScope` or `RouteOriginX`). Shared to RUN, not to edit.
- `learned_minutes_test.dart`: run by S2 and S3, edited by none.
- No `lib/` file is touched by two slices.
- Order: S1 alone; then S2 to S8 in parallel worktrees (P29), each with its own branch; merge in the order S2, S3, S4, then the rest; full suite after the last merge.

## 6. Estimate (agent-work hours)

- 8 slices, 8 agents. Sonnet high median 17 min, p75 32 min (house measurement); xhigh assumed the same basis, est., no separate measurement.
- Agent time: 8 x 17 = 136 min to 8 x 32 = 256 min, so about 2.3 to 4.3 agent-hours.
- Wall clock with S2 to S8 in parallel: S1 (17 to 32) + longest parallel slice (17 to 32) + full suite, drive and review (about 30 to 45) = about 1.1 to 1.8 hours.
- Fix round after review not included.

## 7. Outline of the explanation document (Arabic, written after the slices land)

Path proposal: `docs/MECHANISMS-EXPLAINED.md`. Each section: the idea in plain words, then the term, then why it exists, then a real scenario from this app, then where it lives (file:line) and the test that proves it.

1. The core problem: an answer that arrives late. Analogy: a courier delivering a parcel to an address whose tenant moved out. Term: stale async result.
2. Session lease (`SessionLeaseX`): a ticket stamped with the account, token and login count; work checks the ticket before writing. Scenario: log out while Home loads, log in as another account.
3. Session expiry event (`SessionExpiryX`): only the CURRENT session can be expired by a 401. Scenario: two requests fail with 401 at once.
4. The controller helper (`owned`, `lease(...)`): the six questions asked before writing, in one place. Analogy: `mounted` in a StatefulWidget.
5. Why "still the registered instance": GetX keeps one controller per type; closing one CourseDetails page can remove the other. Scenario: course A open, Next opens course B.
6. Generation counters: last request wins. Scenario: pull to refresh twice quickly.
7. Owner chaining: a refresh started by a tap dies with that tap. Scenario: open My Courses from Home, switch tab before it returns.
8. `RouteOriginX`: why `Get.rawRoute` is null on the root page after `offAllNamed`, and how the top route is read from the navigator.
9. Busy flags: double taps.
10. `isClosed` after `await`: the GetX twin of `mounted`.
11. In-flight reuse and cache ownership on Home and AllCourses: one request for two rebuilds; cache never crosses accounts or languages.
12. Widget-level lease in `ExtendedFutureBuilder`.
13. Login provisional session.
14. Test seams (`downloadFile`, `addLearnedSeconds`): why Hive cannot run inside fake-async tests.
15. TEMP(backend) list: each workaround, the server change that removes it, link to `docs/BACKEND-REQUESTS.md`.

## 8. Questions only the owner can decide

1. Name and home of the helper: `LeaseOwnerX` in `lib/Core/Service/session_lease.dart` is a working name. Your naming, your call.
2. Generation counters: keep them as plain `int` fields in each controller (recommended: readable, your idiom, about 10 more lines) or hide them inside the helper (fewer lines, one more abstraction to learn)?
3. Comment density: Codex comments are long, multi-line English. Trim them to your one-line `///` density in the same slices, or leave comments untouched?
4. Scope: this plan covers the defensive layers only. The large UI and model rewrites from the same period (TestResults view, `user.dart`, levels progress, button, dropdown, toast) are not touched. Do you want a separate style pass for them later?
5. GetX tags: tagging route controllers would remove the "still the registered instance" check at its root, but it changes bindings and every `Get.find`. Park it, or plan it as its own later task?
6. Explanation document: one Arabic file at `docs/MECHANISMS-EXPLAINED.md`, or split per area (session, navigation, TEMP backend)?
