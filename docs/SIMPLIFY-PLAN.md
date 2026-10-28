# Simplification plan: defensive layers into the owner's style

Status: REVISED after plan review and owner answers (section 8). Not yet executed; no code was changed.
Date: 2026-10-29. Base: `main` at 4bac93b. Style reference: f338fa9 (2026-07-08).
Scope: `lib/` code added by the defensive work in f338fa9..main, plus the tests that prove each guard (section 4, Step 0). Existing tests are edited only where a slice renames a symbol they use; new tests go in new files.

## 0. Ground truth this plan is built on

- `git diff --stat f338fa9..main -- lib`: 124 files, +7721 / -4749.
- Most of those added lines are NOT defensive layers. The largest rows are UI and model work (TestResults view 774, user.dart 518, levels_progress 497, button 332, dropdown 315, toast 276). They are out of scope (Decision 4: a separate, later style pass).
- The defensive layers live in about 30 controllers plus 4 core files. Counts from `rg` on main:
  - `SessionLeaseX.capture(` call sites: 53 matches in 27 files. 4 of them are not controller sites (the definition in `session_lease.dart:10`, `http.dart:98`, `remote_data.dart:26`, `future_builder.dart:91`). The base for this plan is therefore **49 controller sites in 23 files** (AppController 5, Home 4, CalendarEvents 4, and the rest 1 to 3 each).
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
- The sites do NOT all use all six atoms, and they do not take the app controller at the same moment:
  - App reference taken once, as a field at creation: Home `:26`, CourseDetails `:23`, Login `:17`, OTP `:14`.
  - App reference taken at call time, as a local: TestInfo `:103`, TestQuestions `:237`, TestResults `:216`. Badges `:20` also takes it at call time and allows `null` (no app registered yet).
  - Sites that omit an atom today: MyCourses `getData` has no atom 2 (`MyCourses/controller.dart:28-36`); MyCourses `onTapCourse` has no atom 3 and no generation (`:53-62`); Notifications `:65` uses `!isClosed` only.
  This is why the atoms are options chosen per site (Decision 1), not a fixed bundle.
- The f338fa9 style: `//====` banners with "Injection of required controls / Variables / Functions / Lifecycle", short `///` comments, one obvious flow per method. Example: f338fa9 `BadgesController` is 13 lines; main is 54 lines, and fields sit above the banners.
- What the tests can see today (checked by reading them): only three tests switch the locale in the middle of a request: `test/profile/profile_integrity_test.dart:144`, `test/quiz/quiz_flow_test.dart:648`, `test/auth/complete_account_info_test.dart:637` (plus `changeLanguage` at `:120`, which is a form field, not a locale switch). The locale atom at Home, AllCourses, MyCourses, CourseDetails, Blog, Notifications, Events, Meetings, Achievements, Certificates and Badges has no locale-switch test. Most `Get.delete<T>` calls in tests are teardown, not the case "another live instance is now registered while the old request is in flight". So a dropped atom would pass the suite at most sites. Step 0 of every slice (section 4) exists to close that gap.

## 1. What we found and what we took

Searched: Dart `async` package cancellation, cancellation tokens, Flutter `mounted` idiom, GetX lifecycle (`isClosed`, tags). House research index (`~/.claude/knowledge/research-index.md`): nothing on this topic.

| Source | Tier | What it says | Taken? |
|---|---|---|---|
| `CancelableOperation` (package:async), https://api.flutter.dev/flutter/async/CancelableOperation-class.html | 1 | Wraps a Future; `cancel()` drops its value or error. | Not taken. It cancels one Future the caller holds. The bugs here are about state that changes under the request (account, locale, route, controller instance), which a cancel call made by the controller cannot see. It would add a dependency-level concept without removing any check. |
| `use_build_context_synchronously` lint, https://dart.dev/tools/linter-rules/use_build_context_synchronously | 1 | After an `await`, check `mounted` before touching the widget. | Taken as the idea: `isClosed` is the GetX twin of `mounted`. The explanation document uses this analogy. |
| GetxController docs (`isClosed`, `onClose` before `onDelete`), https://pub.dev/documentation/get/5.0.0-release-candidate-9.3.3/get_state_manager_src_simple_get_controllers/GetxController-class.html | 1 | `isClosed` reports a closed controller. | Confirms `isClosed` alone is not enough for this app: a closed controller is not the problem when GetX hands back a DIFFERENT live instance of the same type, which is why the "registered instance" atom exists. |
| GetX tags (`Get.put(..., tag:)`), same docs | 1 | Instances of one type can be told apart by tag. | Not taken (Decision 5: no GetX tags; fix only existing problems). |
| Request-id pattern (each request keeps an incrementing id, result applied only if it is still the latest), e.g. https://www.kindacode.com/article/ways-to-cancel-a-future-in-flutter-and-dart/ | 3 (lead only) | Same idea as the generation counters already in the code. | Confirms the counters are the common idiom; kept as plain `int` fields. |

Conclusion: no ready library replaces `SessionLeaseX`. The win is to stop writing its condition by hand 49 times: one small helper in the owner's `...X` style builds it from per-site options.

## 2. Inventory per mechanism

Verdicts: keep = leave as is; simplify = same mechanism, less code or clearer in the owner's idiom; merge = several hand-copies become one helper; remove = dead. "Lines" is est. net lines removed, basis: counted sites x lines per site in the current code. Comment trimming (Decision 3) is inside row 22.

| # | Mechanism | Files | Bug it prevents | Test that proves it | Verdict | Lines (est.) |
|---|---|---|---|---|---|---|
| 1 | `SessionLeaseX` core (user id + token + `sessionRevision` + `isActive`) | `lib/Core/Service/session_lease.dart` | A reply that arrives after logout, account switch or a same-value re-login writes into the new session. | `test/auth/session_lease_test.dart` (A to B to A, same-value login write, retired owner) | keep | 0 |
| 2 | `SessionExpiryX` (local expiry event, no server retry) | `session_lease.dart`, `app_controller.dart` | A 401 from an OLD session logs out the new one; two 401s log out twice. | `session_lifecycle_test.dart` "concurrent expiry clears once without a server logout", `session_lease_test.dart` "expiry only reports current explicit user credentials" | keep | 0 |
| 3 | Transport lease (`authenticates(url)`, "Session changed" throw, expiry report) | `lib/Data/Database/remote/remote_data.dart:26-41`, `lib/Core/Helper/http/http.dart:98-111` | A response for a previous token is returned to the new session. | `test/core/authenticated_transport_test.dart` | simplify (one shared `ErrorX` factory for the "Session changed" error, see #13) | 3 |
| 4 | Hand-built `isActive` closures (the six atoms) | 23 files, 49 controller sites | Each site prevents stale writes for its own screen. | per-screen tests listed in the slices, plus the Step 0 tests (section 4) | merge into the shared helper `ControllerLeaseX` (section 3), atoms chosen per site | 180 to 230 |
| 5 | Ownership getters `_ownsApp`, `_ownsCourse`, `_ownsHome` and inline `identical(Get.find<T>(), this)` | `app_controller.dart:9`, `CourseDetails/controller.dart:48`, `Home/controller.dart:74`, 7 more inline | GetX keys controllers by type: closing one route can delete or replace another route's controller of the same type; work from the old instance must not write. | `session_lease_test.dart` "controller ownership and logout invalidate work", `course_lifecycle_test.dart`, `test/app/achievement_ownership_test.dart:449` "badge app ownership retires a pending $invalid result" (loop over `user-change` and `instance-replacement`) | merge into the helper's `owns` | 35 to 45 |
| 6 | `_captureScope` | `CourseDetails/controller.dart:55-66` (6 calls) | Same as #4 for the course page (course id + locale + operation). | `course_lifecycle_test.dart`, `next_activity_test.dart` | merge (becomes the helper call) | 12 |
| 7 | Generation counters | 15 files, 79 lines | A newer load or tap must win over an older one still in flight (last request wins). | `cache_ownership_test.dart` "new calendar refresh retires an older in-flight result", `session_lifecycle_test.dart` "concurrent startup only publishes its newest request", `empty_home_test.dart` "a Home snapshot cannot overwrite a newer notification return" | keep as plain `int` fields (owner idiom); simplify only the comparisons into the helper's `also:` | 0 to 10 |
| 8 | Content / cache / pending leases (`_contentLease`, `_cacheLease`, `_pendingLease`, `_pendingOwner`, `_pendingLoad`) | CourseDetails, Home, AllCourses (record key) | Cached data of account A or locale X shown to B or Y; two rebuilds start two identical requests. | `cache_ownership_test.dart` "profile cache is reused only for its session and locale", `entry_route_ownership_test.dart` "rebuild reuses request and remount refreshes once" | keep; simplify comments and field grouping | 5 |
| 9 | Owner chaining (`getData(owner: lease)`) | Home, MyCourses, ProfileDetails, AllCourses | The refresh after returning from a child page must die if the tap that started it died. | `test/learning/refresh_owner_test.dart`, `entry_route_ownership_test.dart` "abandons ... before starting refresh" | keep | 0 |
| 10 | `RouteOriginX` (top route read from the navigator) | `lib/Core/Service/route_origin.dart`, 4 call sites | `Get.rawRoute` is null on the root page after `offAllNamed`, so every course-card tap there counted as stale and the page never refreshed. | `root_course_tap_test.dart` "Courses tab card opens the details on a fresh root page", "a card tap whose page was left gives no refresh after return" | keep as is (already small, comment explains the trap) | 0 |
| 11 | Busy flags against double taps | AllCourses, CourseDetails, Home, MyCourses, ProfileDetails | Two fast taps push the same page twice and run two refreshes. | `entry_route_ownership_test.dart` "repeated ... course tap retains the real return refresh" | keep; simplify the `finally` reset to one line each | 5 |
| 12 | `isClosed` checks after `await` (GetX `mounted`) | 26 files, 86 lines | Writing to a disposed controller's text controllers / Rx after the user left (OTP, password reset, login). | `otp_disposal_test.dart`, `password_reset_test.dart`, `login_reentry_test.dart`, `quiz_next_test.dart` | simplify: drop the ones that sit right next to a `lease.isCurrent` that already contains `!isClosed`; keep every standalone one (this includes the 2 in the VideoPlayer controller, S2) | 15 to 25 |
| 13 | "Session changed. Please try again." error built by hand | `remote_data.dart:37`, Home `:148,160`, CourseDetails `:70,118` | Same as #1. Translation key exists in 4 locale files and must stay byte-identical. | `authenticated_transport_test.dart`, `course_lifecycle_test.dart` "wrong-course response is rejected before publication" | merge into one `ErrorX.sessionChanged()` | 4 |
| 14 | `ExtendedFutureBuilder` lease + `sessionRevision` | `lib/Ui/Widget/Basic/Utils/future_builder.dart` | A widget-level future from account A finishes into B's screen; retry after a session change. | `test/ui/future_builder_test.dart` | keep (widget code, not a controller; the helper does not apply) | 0 |
| 15 | `AppControllerX` init / `clearLocalSession` / `_initRequest` | `lib/Core/Controller/App/app_controller.dart` | Startup with id but no token; late startup profile of A replaces B; double expiry. | `session_lifecycle_test.dart` (6 tests), `loading_startup_test.dart` | simplify: owner banners, use helper `owns`; logic unchanged | 8 |
| 16 | Login provisional lease | `lib/Ui/Screen/Auth/Login/controller/controller.dart:38-70` | A login that fails half-way must not leave a usable half-session. | `login_lifecycle_test.dart`, `login_expiry_retry_test.dart`, `login_incomplete_account_test.dart` | keep; `_capture` becomes the helper | 5 |
| 17 | Injectable seams `downloadFile`, `addLearnedSeconds` | `CourseDetails/controller.dart:31-36` | Hive writes hang inside fake-async tests. | `file_checkmark_test.dart`, `learned_minutes_test.dart` "time spent on a lesson video is added when the user returns" | keep as is | 0 |
| 18 | TEMP(backend): file-done flag, local video seconds | `CourseDetails/controller.dart:77-99, 397-407`, `activity.dart:20,25`, `local_key.dart:14`, `lib/Ui/Screen/Course/VideoPlayer /controller/controller.dart:153` (note the space in the folder name `VideoPlayer `) | Server never marks a file done and sends duration "0:00". | `file_checkmark_test.dart`, `lesson_duration_test.dart` | keep (tracked in `docs/BACKEND-REQUESTS.md`) | 0 |
| 19 | TEMP(backend): learned seconds | `user_statistics.dart:42`, CourseDetails `:304` | Server minutes stay 0. | `learned_minutes_test.dart` | keep | 0 |
| 20 | TEMP(backend): first course unlock | `first_course_unlock.dart`, Home `:163`, AllCourses `:54` | Entry exam is never open. | `first_course_unlock_test.dart` | keep (already one shared function; the two call-site comments may shrink to one line) | 2 |
| 21 | TEMP(backend): quiz-only course card, account deletion | `course_card.dart:27`, ProfileDetails `:208` | Quiz-only course shows 0 lessons; no deletion endpoint. | `lesson_counts_test.dart`, `delete_account_test.dart` | keep | 0 |
| 22 | Style drift (fields above banners, long agent comments, missing banners) | every touched controller | none (readability) | `flutter analyze` | simplify inside each slice, including trimming long Codex comments to the owner's one-line `///` density (Decision 3) | 40 to 80 |

Totals: 22 mechanisms. keep as is 10 (#1, #2, #9, #10, #14, #17, #18, #19, #21, and #7 as data), simplify 8 (#3, #8, #11, #12, #15, #16, #20, #22), merge 4 (#4, #5, #6, #13), remove 0. No dead mechanism was found: each one has a test that names its bug (but see section 0: for many sites that test does not yet see the individual atom, which Step 0 fixes).

Est. lines removed: 310 to 430, basis the column above. That is about 4 to 6 percent of the +7721; the rest of the diff is feature and UI work. New test lines from Step 0 are added on top and are not counted here.

## 3. The one new helper

Owner style (Decision 1): his helpers are plain classes named `...X` under `lib/Core` or `lib/Data` (`ToastX`, `LocalDataX`, `SessionLeaseX`, `RouteOriginX`). So the helper is a small class with static methods, not a mixin: `ControllerLeaseX` in a new file `lib/Core/Service/controller_lease.dart`, imported next to `session_lease.dart` and `route_origin.dart` the same way those two are. The name is a working name; S1 may adjust it before anything depends on it.

Draft shape (S1 fixes the exact signature through its tests):

```dart
class ControllerLeaseX {
  /// The controller is open, is still the live instance of its type (atoms 1, 2)
  /// and, when [withApp] is true, [app] is still the live app controller (atom 3)
  static bool owns<T extends GetxController>(T controller,
      {bool withApp = false, AppControllerX? app}) => ...;

  /// A lease for work started now. Each option is one atom, off unless asked:
  /// [app]/[withApp] atom 3, [locale] atom 5 (read at this call), [origin] atom 6,
  /// [owner] the parent tap's lease, [also] atom 4 or any site-specific test
  static SessionLeaseX capture<T extends GetxController>(T controller,
      {bool withApp = false, AppControllerX? app, bool locale = false,
       RouteOriginX? origin, SessionLeaseX? owner, bool Function()? also}) => ...;
}
```

Rules for the helper:
- **Where the app controller comes from (capture point).** The helper never calls `Get.find<AppControllerX>()` itself. The caller passes the reference it already holds today, so no site changes behaviour:
  - field-at-creation sites (Home, CourseDetails, Login, OTP) pass `app: app` (the field);
  - call-time sites (TestInfo, TestQuestions, TestResults) take their local `final app = Get.find<AppControllerX>()` at the same statement as today and pass that local;
  - nullable sites (Badges `:20`) pass a possibly `null` local with `withApp: true`; a `null` app counts as "not owned", exactly as `ownsAppUser()` does today.
  Omitting `withApp` means atom 3 is not checked (MyCourses `onTapCourse`, Notifications).
- **Atoms are per-site options, never a bundle.** The helper only offers the atoms already written by hand; it never adds or drops an atom for a site. A site passes exactly the options it has today. The generation capture (`++_loadGeneration`) and the locale read stay at their current position in the method, so the captured value is the same value as before.
- If a site needs more than three options besides `controller`, it keeps its hand-written closure and is listed as such in the slice table.
- Generation counters stay plain `int` fields in each controller and enter through `also: () => request == _loadGeneration` (Decision of the earlier plan, unchanged).
- `ErrorX.sessionChanged()` goes in `lib/Core/Error/error.dart` next to the other factories.

## 4. Slices (riskiest first)

Shared floor for every slice: behaviour unchanged; no edits to translation texts, UI look, or `lib/Ui/Section/UserStat/user_statistics.dart:22`; owner banners and short `///` comments (long Codex comments trimmed to one line inside the same slice); `TEMP(backend)` markers stay. Flutter: `/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter`. Each slice runs `flutter analyze` (must print "No issues found!") and its tied tests (must print "All tests passed!"; the count must equal the pre-slice count of those files, recorded first, plus the number of tests the slice added in Step 0). Every slice has Work, Acceptance and an exact Verify command.

**Step 0 of EVERY slice (atom mutation pass, test-first), before any refactor of that slice's files:**
1. List every capture site of the slice and the atoms it has today (1 to 6).
2. For each site and each atom, remove that one atom alone from the hand-written closure, run the slice's tied tests, and record which test goes red (file and test name). Restore the line exactly afterwards (`git diff` of the file must be empty after each mutation).
3. Where no test goes red, write a test first that catches the removal: watched RED with the atom removed, GREEN with it restored. The new test goes in a new file `test/<area>/atoms_<slice>_test.dart` (no overlap with other slices). Patterns: locale atom = `Get.updateLocale(const Locale('ar'))` while the request is pending (as in `profile_integrity_test.dart:144`); registered-instance atom = register a second live instance of the type (not `Get.delete` teardown) while the first request is pending; app atom = replace the registered `AppControllerX`; closed atom = `Get.delete`/`onClose` while pending; generation atom = start a second request first; route atom = pop or replace the route while pending.
4. Write the table `site (file:line) | atom | test that goes red | new test?` into the slice handoff. There is no accepted-risk list: a row without a red test is not allowed. Only then start the refactor; the same table is re-run green at the end (the refactored site must keep every atom it had).

**Acceptance for every slice includes:** the Step 0 table is complete; the per-site checklist "atoms before / atoms after" matches line by line; analyze clean; tied tests green with the expected count.

Count of capture sites per slice (sum 49): S1 5, S2 1, S3 4, S4 7, S5 8, S6 3, S7 14, S8 7.

### S1. Helper and transport (sequential, first)
- Files: new `lib/Core/Service/controller_lease.dart`, `lib/Core/Error/error.dart` (`ErrorX.sessionChanged()`), `lib/Data/Database/remote/remote_data.dart`, `lib/Core/Helper/http/http.dart`, `lib/Core/Controller/App/app_controller.dart` (5 sites), new test cases in `test/auth/session_lease_test.dart`.
- Work: write the helper test-first. New tests for `owns` and `capture(...)`: replaced instance of the same type, closed, app replaced, locale change, route change, `also` false, owner dead, and the two capture styles: app taken at creation (field) and app taken at call time (local), plus a `null` app with `withApp: true` (not owned) and an omitted app (atom 3 not checked). Written and watched RED before the helper exists. Then Step 0 on the 5 AppController sites, then move AppControllerX to the helper and the three "Session changed" throws in transport to `ErrorX.sessionChanged()`.
- Acceptance: AppControllerX uses `owns`/`capture`; transport behaviour identical; new tests green; Step 0 table for the 5 sites.
- Verify: `flutter test test/auth/session_lease_test.dart test/auth/session_lifecycle_test.dart test/core/authenticated_transport_test.dart test/auth/loading_startup_test.dart && flutter analyze`
- Model: Sonnet 5.5 xhigh. XHIGH-REASON: defines the concurrency guard every other slice depends on.

### S2. CourseDetails and VideoPlayer (after S1)
- Files: `lib/Ui/Screen/Course/CourseDetails/controller/controller.dart`, `lib/Ui/Screen/Course/VideoPlayer /controller/controller.dart` (folder name has a trailing space; quote the path), new `test/learning/atoms_s2_test.dart`.
- Work: Step 0 on CourseDetails (1 capture site plus the 6 `_captureScope` calls and the `openNext` condition). `_ownsCourse` and `_captureScope` become `owns` / `capture(...)`; keep `_contentLease`, both counters, `_videoBusy`, seams. Do NOT collapse the `openNext` condition (`:325-332`) into `lease.isCurrent`: the lease also requires `identical(course.value, selectedCourse)`, which is false after the refresh publishes a new course, so the two conditions differ on purpose. Keep it, comment why. VideoPlayer controller: it has no lease; its two `isClosed` checks (`:127`, `:134`, after `initialize()`) are standalone and stay (mechanism #12); the `TEMP(backend)` marker at `:153` stays; Step 0 mutates each `isClosed` (remove it, dispose the controller while `initialize()` is pending) and, if no test goes red, adds a test first; then trim its long comments to one-line `///`.
- Acceptance: Step 0 table covers CourseDetails and both VideoPlayer checks; `openNext` condition unchanged with its why-comment; TEMP markers unchanged (`rg "TEMP\(backend\)"` count in these two files equals the pre-slice count).
- Verify: `flutter test test/learning/atoms_s2_test.dart test/learning/course_lifecycle_test.dart test/learning/next_activity_test.dart test/learning/video_next_button_test.dart test/learning/player_controls_test.dart test/learning/file_checkmark_test.dart test/learning/lesson_duration_test.dart test/learning/learned_minutes_test.dart test/learning/lesson_counts_test.dart test/learning/progression_test.dart test/learning/refresh_owner_test.dart && flutter analyze`
- Model: Sonnet 5.5 xhigh. XHIGH-REASON: five overlapping async guards (load, visit, route, course identity, busy flag) on one page.

### S3. Home (after S1)
- Files: `lib/Ui/Screen/Home/controller/controller.dart`, new `test/learning/atoms_s3_test.dart`.
- Work: Step 0 on the 4 sites (the locale atom has no locale-switch test today). `_ownsHome` to `owns`; the lease sites to the helper (app passed from the field `app`, `:26`); keep `_pendingLoad` dedup, `_cacheLease`, counters, `RouteOriginX`; the two "Session changed" throws to `ErrorX.sessionChanged()`.
- Acceptance: Step 0 table for 4 sites; `_pendingLoad` dedup behaviour unchanged (`entry_route_ownership_test.dart` green).
- Verify: `flutter test test/learning/atoms_s3_test.dart test/learning/empty_home_test.dart test/learning/entry_route_ownership_test.dart test/learning/root_course_tap_test.dart test/learning/refresh_owner_test.dart test/learning/first_course_unlock_test.dart test/learning/mounted_statistics_refresh_test.dart test/learning/learned_minutes_test.dart && flutter analyze`
- Model: Sonnet 5.5 xhigh. XHIGH-REASON: shared in-flight request reuse plus owner chaining (concurrency).

### S4. Course lists and profile (after S1)
- Files: `lib/Ui/Screen/Course/AllCourses/controller/controller.dart` (2 sites), `lib/Ui/Screen/My/MyCourses/controller/controller.dart` (2), `lib/Ui/Screen/Profile/ProfileDetails/controller/controller.dart` (3), new `test/learning/atoms_s4_test.dart`.
- Work: Step 0 on the 7 sites. MyCourses `getData` (no atom 2) and `onTapCourse` (no atom 3) keep exactly their atoms; the helper call passes only the options each has. Move the sites to the helper; keep `RouteOriginX`, owner chaining and busy flags (`finally` reset to one line).
- Acceptance: Step 0 table for 7 sites with MyCourses omissions preserved; analyze clean.
- Verify: `flutter test test/learning/atoms_s4_test.dart test/learning/root_course_tap_test.dart test/learning/entry_route_ownership_test.dart test/learning/refresh_owner_test.dart test/app/cache_ownership_test.dart test/profile/delete_account_test.dart test/profile/profile_integrity_test.dart test/learning/first_course_unlock_test.dart && flutter analyze`
- Model: Sonnet 5.5 high. Reason: three controllers, each guard is a single async load with no shared in-flight request.

### S5. Auth screens (after S1)
- Files: controllers of `Auth/Login`, `Auth/OTP`, `Auth/SignUp`, `Auth/ForgotPassword`, `Auth/ForgotPasswordReset`, `Auth/CompleteAccountInfo`, `Loading` (8 sites), new `test/auth/atoms_s5_test.dart`.
- Work: Step 0 on the 8 sites. Login `_capture` to the helper (app from the field, `:17`); OTP likewise (`:14`); drop `isClosed` checks that duplicate a lease; keep standalone ones (timers, text controllers) after proving each with Step 0.
- Acceptance: Step 0 table for 8 sites; every dropped `isClosed` has a red test showing the lease still covers it; analyze clean.
- Verify: `flutter test test/auth && flutter analyze`
- Model: Sonnet 5.5 high. Reason: independent forms, each a single request.

### S6. EditProfile (after S1)
- Files: `lib/Ui/Screen/Profile/EditProfile/controller/controller.dart` (3 sites, 45 lease lines, the densest file), new `test/profile/atoms_s6_test.dart`.
- Work: Step 0 on the 3 sites (the locale switch at `profile_integrity_test.dart:144` already covers atom 5 here; record it). Move to the helper; keep upload and save behaviour.
- Acceptance: Step 0 table for 3 sites; file is shorter and in banner layout.
- Verify: `flutter test test/profile/atoms_s6_test.dart test/profile/upload_lifecycle_test.dart test/profile/profile_integrity_test.dart test/data/profile_serialization_test.dart && flutter analyze`
- Model: Sonnet 5.5 high. Reason: one controller, guards are sequential (load, upload, save), not interleaved.

### S7. Content screens (after S1)
- Files: controllers of `Blog/Blog` (1), `Notifications` (2), `Events/CalendarEvents` (4), `Events/EventDetails` (3), `Meeting/AllMeetings` (1), `Badges` (1), `My/MyAchievements` (1), `My/MyCertificates` (1) = 14 sites, new `test/app/atoms_s7_test.dart`.
- Work: Step 0 on the 14 sites (this slice has the most missing locale-switch tests). Notifications keeps `!isClosed`-only where it has only that; Badges passes a possibly `null` app with `withApp: true` and keeps its `try` around the late `app.user` read (it can sit in `also:`); Calendar keeps its generation counters as `also:`.
- Acceptance: Step 0 table for 14 sites; Badges ownership tests green.
- Verify: `flutter test test/app/atoms_s7_test.dart test/app test/performance/counterpart_session_test.dart test/performance/counterpart_lists_test.dart test/performance/catalog_activity_lists_test.dart test/performance/vertical_feed_test.dart test/performance/pagination_test.dart && flutter analyze`
- Model: Sonnet 5.5 high. Reason: many small, similar list controllers; no shared in-flight state. (Largest high slice; see open question 1.)

### S8. Quiz screens (after S1)
- Files: controllers of `Test/TestInfo` (2), `Test/TestQuestions` (3), `Test/TestResults` (2) = 7 sites, new `test/quiz/atoms_s8_test.dart`.
- Work: Step 0 on the 7 sites (locale atom is covered at `quiz_flow_test.dart:648` for TestResults only). These three take the app controller at CALL time (`:103`, `:237`, `:216`); the helper call keeps that local and passes it. Only the controllers are in this plan; the TestResults view rewrite is out of scope (Decision 4).
- Acceptance: Step 0 table for 7 sites; call-time capture preserved.
- Verify: `flutter test test/quiz && flutter analyze`
- Model: Sonnet 5.5 high. Reason: three controllers with the same load-then-act shape.

### Batch end (orchestrator, once)
- Full suite once: `flutter test` must print "+731: All tests passed!" plus the new tests (expected 731 + N, N = new S1 tests + all Step 0 tests, summed from the slice handoffs), and `flutter analyze` "No issues found!".
- Drive the app once on a simulator through: login, Home card tap, course page, video then Next, quiz return, profile edit, logout (F27; logic batch, so a short drive). Add: switch the app language while Home, My Courses and a list screen are still loading, and confirm no data of the old language stays on screen.
- One blind review of the merged batch (Opus 5.5 medium: it touches session and data-integrity logic), given the per-site atom tables (Step 0) and checklists from every slice.

## 5. Overlaps and order

- `lib/Core/Service/session_lease.dart`, `controller_lease.dart` and `app_controller.dart`: S1 only. Every other slice imports them, so S1 merges first.
- `test/learning/refresh_owner_test.dart`, `entry_route_ownership_test.dart`, `root_course_tap_test.dart`, `first_course_unlock_test.dart`: run by S2, S3 and S4, edited by none (unless a renamed private symbol leaks, which no test does today: no test mentions `_owns`, `_captureScope` or `RouteOriginX`). Shared to RUN, not to edit.
- `learned_minutes_test.dart`: run by S2 and S3, edited by none.
- New Step 0 tests live in one new file per slice (`atoms_s2_test.dart` ... `atoms_s8_test.dart`), so no test file is edited by two slices. S1 adds cases only to `test/auth/session_lease_test.dart`.
- No `lib/` file is touched by two slices. The VideoPlayer controller belongs to S2 only.
- Order: S1 alone; then S2 to S8 in parallel worktrees (P29), each with its own branch; merge in the order S2, S3, S4, then the rest; full suite after the last merge.

## 6. Estimate (agent-work hours)

- 8 slices, 8 agents.
- Basis: house measurement for a single kit-driven slice, Sonnet high median 17 min and p75 32 min. Sonnet xhigh median 49 min and p75 72 min (figures given in the review; est., no separate measurement here). The mutation pass (Step 0: one test run per atom per site, 49 sites) and the new tests add an assumed 50 to 100 percent on top of the base (est., no measurement; first slice's real time replaces it).
- Per slice: xhigh slices (S1, S2, S3) 74 to 144 min each; high slices (S4 to S8) 26 to 64 min each.
- Agent time: 3 x (74 to 144) + 5 x (26 to 64) = 352 to 752 min, so about 5.9 to 12.5 agent-hours.
- Wall clock with S2 to S8 in parallel: S1 (74 to 144) + longest parallel slice (74 to 144, S2 or S3) + batch end with the longer drive (45 to 65) = 193 to 353 min, so about 3.2 to 5.9 hours.
- Fix round after review not included. The earlier draft (2.3 to 4.3 agent-hours, 1.1 to 1.8 hours wall clock) did not include the mutation pass or new tests.

## 7. Outline of the explanation document (Arabic, written after the slices land)

Path: `docs/MECHANISMS-EXPLAINED.md` (one file, Decision 6). Each section: the idea in plain words, then the term, then why it exists, then a real scenario from this app, then where it lives (file:line) and the test that proves it.

1. The core problem: an answer that arrives late. Analogy: a courier delivering a parcel to an address whose tenant moved out. Term: stale async result.
2. Session lease (`SessionLeaseX`): a ticket stamped with the account, token and login count; work checks the ticket before writing. Scenario: log out while Home loads, log in as another account.
3. Session expiry event (`SessionExpiryX`): only the CURRENT session can be expired by a 401. Scenario: two requests fail with 401 at once.
4. The controller helper (`ControllerLeaseX.owns` / `capture`): the questions asked before writing, each chosen per screen. Analogy: `mounted` in a StatefulWidget. Include the atom table of Step 0 as the proof of which test guards which question.
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

## 8. Decisions (owner answers, final and binding)

The owner's answers to the earlier questions, in his words as relayed, and where this plan applies them:

1. "Add the small shared helper, named and placed in the owner's `...X` style (his helpers are classes like ToastX, LocalDataX, SessionLeaseX under lib/Core or lib/Data). Each guard 'atom' is an option chosen per site, NOT a fixed 1+2+3 bundle." Applied in section 3 (`ControllerLeaseX`, per-site options, explicit app capture point).
2. "Tests first: before the refactor of each site, remove each atom one at a time, record which test goes red; where none goes red, write a test first (watched red) that would catch its removal. No accepted-risk list." Applied as Step 0 of every slice (section 4) and the table as an acceptance artifact.
3. "Trim the long Codex comments to the owner's one-line `///` density, inside the same slices." Applied in the shared floor, mechanism #22 and S2.
4. "UI and model rewrites (TestResults view, user.dart, levels progress, button, dropdown, toast) are OUT of this plan; note them as a separate later style pass." Applied in section 0 and S8. They are noted here as a separate later style pass, not planned in detail.
5. "No GetX tags. Fix only existing problems." Applied in section 1 (tags not taken, no later step recorded).
6. "One Arabic explanation file: docs/MECHANISMS-EXPLAINED.md (written after the slices land; keep the outline section)." Applied in section 7.

## 9. Open questions only the owner can decide

1. S7 has 8 controllers and 14 capture sites, the most missing locale-switch tests, and is the longest of the five "high" slices (up to about 64 min). Split it into two slices (for example S7a Blog, Notifications, Events, Meetings; S7b Badges, MyAchievements, MyCertificates) to shorten the parallel run, or keep it as one? The plan keeps one slice unless you say otherwise.
