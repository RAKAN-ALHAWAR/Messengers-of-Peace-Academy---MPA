# Source-only follow-up, 2026-10-18

Status: historical baseline analysis and proposed corrections. Urgent U01-U03
and H01 now have local repairs and regression coverage in FIX-STATE.md. Other
findings remain open unless that ledger explicitly records verification.
This extends `AUDIT-2026-10-17.md`; it does not replace the previous findings.

## Owner direction and boundaries

Saker explicitly deferred interactive simulator work and requested continued
code analysis. He does not have the backend source and may provide an API
description later. This pass uses source, actual application modules, synthetic
records, intercepted HTTP and local widget tests only. No server or real account
operations, credential changes, package upgrades or product implementation.

## New active findings

### U01: invisible Toast leaves Back navigation trapped, P1

Reproduced with actual `MyApp`, `ToastX` and `BackButtonX` on installed Flutter
3.41.6 / Get 4.7.2. Only the test's in-memory route list and Hive data were
synthetic. MyApp's builder, theme, translation setup and initial binding remain.
Before displaying a Toast, tapping the actual Back arrow pops the probe page.
After `ToastX.error`, observed:

```text
FlutterError: No Overlay widget found.
TOAST route=/probe snackbarOpen=true visible=0
LateInitializationError: Field '_controller' has not been initialized.
AFTER_BACK route=/probe snackbarOpen=true errors=2
```

The project's `lib/Ui/Widget/Basic/Alert/toast.dart:6,57,108` uses Get.rawSnackbar
for all three message types; shared Back at `Basic/Button/back_button.dart:22`
uses Get.back. Installed Get's `extension_navigation.dart:1146` selects the
Navigator Overlay's child as its overlayContext. `snackbar_controller.dart:91`
passes this context to Overlay.of, which fails under the installed Flutter
Overlay structure. `_configureOverlay` fails before animation controller setup.
Get's async queue does not clean up this Error (`get_queue.dart:37` catches only
Exception), so `isSnackbarOpen` remains true. `Get.back` at
`extension_navigation.dart:821` then tries to close that uninitialized snackbar
and returns instead of popping the page.

This demonstrates a shared runtime defect without any iOS-specific API; it is
not proof of a simulator fault or a completed device retest. MyApp's MediaQuery
builder is not established as the cause. Do not add an arbitrary outer Overlay
as a product fix solely because that isolation harness makes Toast work.

The error is asynchronous to the Toast caller: rawSnackbar does not await its
queue. In reset/profile code, isLoading can still return to false. A permanent
AbsorbPointer lock from a synchronous Toast throw was suspected and rejected.

Proposed repair: reliable central notification presentation using the valid
Flutter overlay/messenger lifecycle, explicit toast dismissal, and independent
page Back semantics. Test all Toast types, repeated messages, close/timed
dismissal and navigation during a message. No dependency upgrade is adopted.

### U02: completion validation explains failures only through Toast, P2

`CompleteAccountInfo/controller/controller.dart:187` validates text fields, then
lines190-228 check DOB and required selections using Toast-only guards before
setting loading or making a request. `Basic/Input/dropdown.dart:64` uses
DropdownButton, not a validating FormField. No inline selection error is shown.

Actual controller test: DOB, phone and city validators pass, all required
selections except country supplied. Save made zero intercepted requests, loading
remained false and button normal; only 'Please select a country' Toast appeared
in the isolation host. Combined with U01 this branch looks like an inert Save.
Which field, if any, Saker omitted is unknown. Text validation can also fail
above the scrolled viewport; no scroll-to-first-error mechanism exists.

Proposed repair: field-level required-selection errors with accessible focus/
scroll to the first invalid field. Reconcile completion/edit validation against
the real backend requirements. The completion view explicitly has isBack=false
at view line23 and offers Skip; do not infer an absent Back is a failed tap.

### U03: reset success is conflated with automatic-login failure, P2

`ForgotPasswordReset/controller/controller.dart:59` resets the password, then
line66 logs in, and line80 loads the profile. All three stages share the catch
at line93. Synthetic actual-controller test returned reset success then login
failure: exactly two calls, no profile request, route stays /reset and button
shows failed. isLoading correctly becomes false. The reset may already have
succeeded; this is not proof that Saker's actual password changed.

Profile failure also occurs after user ID/token/root route are stored at
lines75-77 but before isLogin becomes true at line83 (source observation).
Retrying the whole sequence resubmits the original OTP; server consumption and
retry rules are unknown. The current server-side cause cannot be determined
without a sanitized response/stage or backend contract.

Proposed repair: separate reset acknowledgement from sign-in/profile recovery,
avoid resubmitting an accepted OTP, commit session state consistently, and show
the specific failed stage without logging passwords, OTPs or tokens.

### H01: empty HTTP failures appear successful, P1/P2

Root: `lib/Core/Helper/http/lib/response.dart:121` returns null for an empty body
before validating HTTP status. Untyped mutation calls accept this through
`lib/Data/Database/remote/remote_data.dart:62`.

Reproduced with actual `DatabaseX.readNotifications`, `addEvent` and
`submitComplaintOrSuggestion`: empty 401, 403, 429 and 500 responses all resolved
normally, 12 failed mutations in total. A nonempty JSON 401 correctly threw.

Callers then mark notifications read locally, close the complaint sheet, or
report event success. This is false client success, not server acceptance of a
rejected operation. Repair: status validation precedes empty-body handling;
explicitly document legitimate empty success and endpoint acknowledgements.

### H02: expired sessions have no recovery transition, P2

`lib/Core/Controller/App/app_controller.dart:9,17` derives login state from a
stored user ID and fetches profile without handling session expiry. Only manual
logout invokes the logout path. Actual startup tests using JSON HTTP 401 and
HTTP 200 with `errorcode=invalidtoken` threw while retaining token, user ID,
authenticated route and login flag. The latter error becomes generic code1000.

Actual initialized `HomeController.getData` swallowed five unauthorized refresh
requests and resolved normally. Repair: normalize confirmed authentication
errors and make one session-expiry transition, without treating ordinary network
failures or every 403 as logout. Exact Moodle error codes need documentation.

### H03: avatar upload deadline excludes body consumption, P2

`lib/Core/Helper/http/http.dart:167` times out `request.send()`, then consumes
the body through `Response.fromStream` outside that deadline. Actual
`DatabaseX.updateUserImage` remained pending after125ms with a25ms helper timeout
when synthetic headers arrived but body completion was withheld. It completed
only when that body stream closed. These test intervals are not production
timeouts; the production default is15 seconds, with the same uncovered phase.

Repair: deadline/cancellation across headers and body, response-size limit,
and reliable release of the profile submission state on failure.

### F01: failed reference-data fetch rewrites unchanged phone, P1/P2

`lib/Ui/Screen/Profile/EditProfile/controller/controller.dart:130,142,150`
defaults the user's country code to `+966` when the code list fails to load.
`formData` at line230 combines that new code with the existing national number.

Reproduced with an actual controller, synthetic US profile and intercepted503:
without any user edit, outgoing form changes from `+12025550123` to
`+9662025550123`. No profile save was sent. This can change the phone when the
user only intends to edit another field. Repair: retain existing selections on
reference-data failure; distinguish loading/error/unknown from user changes.

### V01: video controls do not observe playback, P2

`lib/Ui/Screen/Course/VideoPlayer /view/sections/regular_player.dart:49,99`
uses Obx over getters that read a `VideoPlayerController` ValueNotifier. The Rx
dependency is the unchanged video-kind flag. Playback updates do not rebuild
position/slider or the play/pause icon.

Actual widget probe changed the synthetic player's position from00:10 to00:20
and playing from false to true. Old-position widgets=1, current-position=0,
pause icons=0. Repair: bind controls to the player listener/ValueListenable and
keep existing player disposal; test progress, seek and playback toggles.

### C01: a disposed reset form still changes navigation, P2

`lib/Ui/Screen/Auth/ForgotPassword/controller/controller.dart:67` navigates after
awaiting a request and delay, without checking operation/controller lifetime.
`onClose` disposes the email field but does not invalidate that continuation.

Actual intercepted-HTTP widget probe: start reset, pop form, navigate elsewhere,
then release delayed response. Before response: route=/other, isClosed=true.
After response: route=/otp, isClosed=true. Repair: invalidate pending operations
when ownership ends and check after awaits before navigation/shared-state writes.

Related signup/login/profile/event continuations were source-inspected, not all
individually reproduced. Do not infer a memory leak merely from missing dispose.

### C02: a pending profile continuation uses a new session, P1

Source chain: EditProfile.onEdit begins textual update for account A at line256;
top app-bar Back remains outside body AbsorbPointer. After leaving and changing
to B, the old continuation can reach photo upload at line264. The actual
`DatabaseX.updateUserImage` at `lib/Data/Database/database.dart:200` reads the
current stored user ID, and the endpoint selects the current token. AppController
is permanent and there is no operation/session-generation guard.

Independent actual-controller probe completed: begin A's text update, tap the
actual appbar Back, confirm controller closed, seed synthetic session B, release
A's delayed response. The follow-up multipart carried B's user ID and token
with A's selected photo. All HTTP intercepted; no real photo/account involved.
This demonstrates wrong outbound account attribution, not actual server
persistence or backend authorization bypass. A real race requires B login
before A's first response/deadline. Repair: capture initiating session generation
and invalidate further requests/shared writes after identity/ownership changes;
merely capturing A's token or disabling Back does not solve the full lifecycle.

## Conditional input handling and excluded suspicions

- Actual `UserX.phone` throws RangeError for a nonempty stored phone shorter
  than its country prefix (`user.dart:44`); EditProfile.onInit calls it at
  controller line322. This is a reproduced malformed/legacy-data fixture,
  not evidence that any current account has malformed data.
- `BlogX.fromJson` calls substring(0,2) on the first tag name
  (`lib/Data/Model/blog.dart:42`). A one-character tag throws and the list parser
  drops that article. Synthetic complete two-article input produced one article.
  Actual server tag contents are unknown.
- The country-code form serializer is gated by an unrelated nullable
  how-found-us field. It can omit the code for null; current screen callers
  supply nonnull text, so this is not counted as an active screen defect.
- Phone validation accepts Arabic digits while current form construction does
  not normalize them. Whether the server accepts/normalizes them is a contract
  question, not a demonstrated failure.
- The age-bucket boundary error from the first audit was independently repeated.
- The shared time picker correctly displays noon as12 and decrements to11.
  A suspicion based on `hourOfPeriod` was refuted by actual Flutter source and
  runtime controls. Initial Ahem-font test overflow disappeared with the actual
  product font/theme; no product layout defect is claimed from that harness.
- Multipart retry reuses a finalized request only when explicitly configured
  for multiple attempts. No current caller does so; default attempt count is1.
  Generic response caching has no active cache-key callers. Neither is promoted
  to active request replay/cache-poisoning findings.

## Evidence and method corrections

All probes are outside the repository and use resolved packages from
`/private/tmp/mopa-audit-20261017`:

```sh
flutter test --no-pub --reporter expanded /private/tmp/mopa-security-http-probes/http_session_test.dart
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/source_followup_test.dart
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/lifecycle_app_test.dart
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/toast_back_actual_app_test.dart /private/tmp/mopa-audit-probes/symptoms_controller_test.dart
flutter test --no-pub --reporter expanded --timeout 20s /private/tmp/mopa-security-http-probes/cross_session_profile_test.dart
```

- Main independently completed HTTP/session/upload suite:8 tests passed.
- Main completed data-boundary suite:8 tests passed, including observations and
  two controls. Passing observations expose current behavior, not corrected
  product acceptance. Two conditional checks are not active-defect claims.
- Lifecycle suite restored and independently completed:2 tests passed. A third
  concurrent session-switch harness hung and was terminated; it was not counted
  as an app defect. The independent, separate cross-session profile file then
  completed:1 test passed. Each reviewer owns a separate scratch file.
- Urgent actual-MyApp and controller suites independently completed together:
  3 tests passed. The first MyApp harness awaited disk IO inside fake-async
  widget setup and hung; initialization moved to setUpAll before the completed
  run. The first faithful-builder Back tap targeted a wide Row rather than its
  arrow and missed; targeting the actual arrow fixed that harness. Neither
  harness failure is product evidence.
- Initial data probe compilation incorrectly awaited void Get.reset; fixed in
  the scratch harness. Actual product code was not changed.

## Repair split proposed for review

**Frontend-only corrections that preserve wire semantics:** HTTP status/empty
body handling; notification display and Back lifecycle; visible validation;
separate reset/sign-in stages; preserving form data on reference-list errors; player listeners;
controller/route/session ownership of continuations; numeric conversions;
future caching; missing/slot-ordered result rendering; duplicate answer-label
selection by position; stale notification/progress invalidation; empty states;
age-boundary math; import case and public list pagination/rendering.

**Requires backend description or owner decisions:** minute accounting, lesson
unit totals, file-completion endpoint, video completion policy, stable answer
wire identity/index basis, authoritative attempt timing/resume and `passed`
values, finalization acknowledgements, secure download authentication, service
credential ACL/rotation, exact session-expiry codes and legacy password policy.

Do not change these unknown policies by guessing. The concrete request is in
`BACKEND-CONTRACT-REQUEST.md`. Interactive verification remains intentionally
deferred. No implementation, CI-green or production-ready claim is made.
