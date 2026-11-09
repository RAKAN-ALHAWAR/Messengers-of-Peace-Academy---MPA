# Mopa audit state

Updated: 2026-11-09 (Asia/Damascus).

## Profile points card (2026-11-09)

The screenshot showed a balance of 7, remaining -7 and a 0/7 counter. The
mobile contract documents zero `required_points` as an unavailable threshold,
with `earned` independently provided by Moodle. Both points screens selected
the last reward when no eligible target existed. The card subtracted the
balance from zero, divided by zero and wrote the total before the balance.
The Profile and Achievements widget checks failed against the old behavior.

`2c87c87` uses the first unearned reward with a positive threshold above the
balance. With no eligible target, both screens retain the balance and explain
that there is no next points target. Valid targets show the attained points
first and clamp the displayed progress and remaining value to valid bounds.
The badge preview and catalog omit claims of a zero-point requirement.
Moodle's earned flag continues to identify awarded rewards.

Arabic renders verified the reported case and a 7-of-10 target, including 3
points remaining. All 80 focused checks and 1,022 tests in an isolated Flutter
3.47.7 checkout passed. Analysis retained the existing quiz-results warning.
The existing AccountDeletion view edit stayed outside scope. Native devices,
remote CI and live account behavior remain pending.

## Points card layout follow-up (2026-11-09)

The owner asked to preserve the original card design. `14b8f34` restores its
160 logical-pixel minimum height, artwork, glass track, and footer placement
on Profile and Achievements. An unavailable target leaves the track empty and
uses a dash in the counter's existing location. A valid target fills the same
track and shows attained points first using an LTR isolate within the label.

The regression detected the shortened 74-pixel card before the correction.
Arabic renders using the bundled font at 350 pixels matched the original card
rectangle and track placement in both the unavailable and positive goal cases.
All 80 focused checks and 1,022 full-suite tests passed. The existing
AccountDeletion edit stayed outside scope. Native checks remain pending.

On the owner's wording follow-up, the empty-target state now shows
"No current points target" above the track and "Progress unavailable" in the
footer. All 39 catalog and card checks passed, and the Arabic render again
matched the original card and track geometry. This change was local.

## Course lesson counts and progress (2026-11-09)

The owner reported 2/3 and 66% on the catalog card versus 2/13 and 21% on
CourseDetails for an 11-lesson course. The catalog used Moodle's summary
fields and details counted every topic with content. The Arabic regression
failed on the old card's missing 2/11 value before implementation.

`b4cd48b` derives lesson progress from the detailed activities and shares it
between the Home and All Courses cards, Enrolled Courses and CourseDetails.
Each topic with a lesson counts once. Locked named lesson modules still count
when Moodle withholds the video URL. A lesson finishes when its videos and
in-topic quizzes are complete. Standalone files and the final assessment stay
in the course content and keep their own status. An assessment-only course
shows test progress without a lesson count. Moodle owns official course
completion and unlocks. Downloads do not change lesson progress.

The mobile guide documents single-course details. Mounted open cards request
those details with at most four concurrent reads, deduplicate same-course
requests and reuse up to 64 recent, session- and locale-scoped summaries. An
owned detail refresh replaces older catalog results. Locked cards and failed
reads omit unverified counts. The guide provides no explicit type for an
activity with all links and quiz ID withheld, so the established named-module
rule still applies. A future backend contract could include an explicit module
type and stable lesson totals plus completed lessons in the catalog response.
The older request to count every topic in BACKEND-REQUESTS.md section 5 is
superseded by the owner's lesson-count clarification.

The Arabic widget flow shows 2/11 at 18% in the card and details, then 3/11 at
27% in both. It still shows the final assessment and the file in the content.
Focused verification passed 69 checks. The isolated Flutter 3.47.7 suite
passed 1,019 checks with the committed lock. Analysis retains the existing
warning in the quiz results controller. CI's Flutter 3.41.6 requests five SDK
package changes when enforcing the current lock locally. Remote CI, native
interactive checks and the live Moodle account remain unverified.

## Captured lesson count and Home progress follow-up (2026-11-09)

A saved simulator response for Foundations of Da'wah supplies 11 video lesson
sections. The final section contains a quiz with `quizid` and a separate level
certificate with a name and `cmid`, but without a URL or an activity type.
The app's fallback classifies that linkless certificate as a locked video.
A local replay of the sanitized response reproduces 12 lessons where 11 are
expected. The earlier synthetic test omitted the co-located certificate.
Moodle's custom course-details response needs a stable activity classification
for entries it already returns, independent of access to their URLs. No
fallback based on an activity title was approved or implemented.

A saved Home snapshot shows `completedcourses: 1`, `totalcourses: 2`, and
`completion_percent: 0` at the selected level. The admission exam is the only
completed course in the returned levels. `get_user_statistics` independently
returns `completedcourses: 1` as an aggregate without course IDs. A widget
probe using these captured values verifies 1/2 and 0% in the gold level card
and 1 in the completed-courses statistics card. The owner confirmed that the
admission exam counts as an official course in both Home cards. The server's
formula for the separate level percentage remains unconfirmed.

The installed simulator binary predates `b4cd48b`. A simulator build of
`b4cd48b` succeeded, and local replay established the same 12-count defect
in that source before installing it. No live service calls were made. Next:
confirm a stable lesson/type field with the backend owner, then replay the
captured activity shape through the course card and details after the fix.

## Account deletion and version format (2026-11-09)

The owner asked to use the `version + build` format below Delete account and
to connect that button to the supplied mobile integration guide. `e3d3868`
kept dynamic version metadata and localized the build digits. The owner
clarified that the build must use Latin digits in Arabic too. `d01ef67`
displays `1.0.0 + 7` with bundled metadata and preserves the format for
native build overrides. Both footer checks reproduced the bug and passed
after the fix. All 18 focused profile and account deletion checks passed.

`0928dab` opens the explanation and asks for consent before sending an email
code. Only the final confirmation sends the deletion request. The two requests
use a dedicated HTTPS POST transport with the session token in the body. A
lost or unreadable confirmation is reported as uncertain and is never retried
automatically. Confirmed success clears the account's local session and data
and closes the protected routes. `7493391` separates new course downloads by
account so deletion can cancel and remove the matching files. Legacy shared
exports have no reliable ownership record and are retained.

All 1,019 tests passed in the isolated checkout. The 11 deletion checks passed
again after a lint-only fix. They cover both API steps, the signed-out route
guard, owner-only cleanup, wrong and expired codes, duplicate presses, a
changed session, and a narrow layout with larger system text and a keyboard.
Analysis reports the pre-existing quiz result controller warning. Native
device checks, screen-reader runs, email delivery and the live deletion API
were not exercised. No real account was used. The owner decided to keep
session tokens in Hive. The guide's OS-protected storage requirement is a
known deviation from the mobile implementation.

The owner reported that the consent and code stages looked different from
the rest of the app and asked to follow its controller and OTP conventions.
The profile opens a protected named route with a bound GetX controller for
the deletion session, deadlines, validation and requests. The `GetView`
uses the profile app bar and consent control for the first step. The code
step uses the same `AuthLayoutX` and six-box `OtpFieldsX` as account
verification. The shared input preserves leading zeroes, normalizes Arabic
and Persian digits, and supports the keyboard's one-time-code autofill hint.
Both Arabic stages were rendered locally in the light and dark themes.
`82b5e5b` shares the OTP field and `b6f5268` separates the deletion controller.
All 1,019 tests passed in the isolated checkout, with 14 focused checks passing
again after test cleanup. Analysis retains the existing quiz result warning.

The owner asked for the actual verification controls and less vertical space.
`0c9b79f` shares the verification button and resend control between account
verification and deletion. Deletion uses the standard secondary support button,
reduces the consent spacing, and sets a smaller top inset in `AuthLayoutX`.
The displayed code validity and resend countdowns now start when a successful
response opens the code step. The server remains authoritative for the code's
actual expiry. Failed requests retain a local resend cooldown without exposing
an OTP countdown on the consent screen.
`45887e1` adds a 12-second response-delay regression. It observes no countdown
before the code step, then a full `05:00` for validity and `01:00` for resend.
All 1,020 tests passed locally. All 15 focused tests passed again after the
final timer formatting change. The Arabic layouts were rendered in both app
themes. Analysis reports the existing quiz result warning.

## Account version footer follow-up (2026-11-09)

The owner reported the footer missing and specified it must immediately follow
Delete account. The booted simulator had an older native binary without the
package metadata channel. `c6e3fa6` keeps installed metadata first and falls
back to the bundled pubspec version and build when the channel is absent.
A phone-size Arabic test reproduced the missing line before the fix and
verified placement immediately below Delete account after it. All 10 focused
checks passed. A synthetic phone-size render confirmed the visible footer.
The installed simulator app was not replaced.

## Account version footer (2026-11-09)

The owner requested a small, muted version and build line below the account
controls. Implemented in `f2a08b7`. The line uses the installed package values
on Android and iOS, including Flutter build overrides. It is localized in all
four app languages. The Arabic account widget test verifies the placement,
small muted style, and runtime metadata. Isolated Android and iOS simulator
builds carried the custom version `2.4.9` and build `73`. The iOS retry exited
successfully with local Swift build overrides after diagnostics from existing
plugins. All 1,010 tests passed in the isolated checkout; static analysis
reports the existing quiz results warning. No native app was installed or
launched for this change.

## Quiz fallback timing policy (2026-11-09)

The owner specified one shared exam countdown when Moodle has no time limit:
60 seconds per question, with the quiz finalized and results shown at zero.
Reopening an existing attempt starts a new window for unanswered questions.
Implemented in `379340d`. The fallback starts when questions are ready; it
never uses the server attempt's age or resets between questions. The original
server-based deadline remains in effect for quizzes with a time limit. The
elapsed time reported for the fallback is the elapsed time of its current
window. Focused checks passed 47 tests, including old attempts, resuming with
saved answers, preserving the shared budget on navigation, expiry, and a
partial question list. All 1,009 tests passed in the isolated suite. Static
analysis reports the existing results-controller warning. Native device and
live submission were not exercised.

## Untimed quiz attempt follow-up (2026-11-09)

The owner requested that the previous countdown be restored. `2746c56`
reverts the timing change, restoring the 120-second fallback and its prior
behavior. Forty-six focused tests passed, including checks of the countdown
on entry, resuming within the fallback, and the known recovery screen when
an older attempt exceeds it. At that point, no replacement policy had been approved.

The owner reported the recovery screen persisted and supplied `timelimit: 0`
plus an `existing`, `inprogress` attempt with both questions. Authorized
checks on the academy service confirmed the same attempt was still in progress
after more than an hour, without a scheduled deadline. Both question slots
were `notyetanswered` with `hasautosavedstep: false`. The prior app substituted
a 120-second deadline, which reproduced the recovery screen in a widget test.
`129a93b` preserves Moodle's zero duration as untimed. It omits the countdown
and automatic timeout for these attempts, while result elapsed time still uses
the original start. The regression covers fresh and resumed untimed attempts
and explicit submission. All 1,007 tests passed in the isolated checkout.
Analysis reported only the prior quiz results warning. The patched build was
not driven against the academy service. The service probe did not create,
answer, or submit a quiz attempt.

## Quiz attempt resume (2026-11-09)

Owner reported recovery on re-entering unfinished exams, including attempts
with no answer saved. The questions controller previously blocked all
`inprogress` attempts before requesting their data. Implemented in `93466bd`
on `main`: preflight an active attempt and its original start time, require a
matching `existing` result, then reconcile the Moodle summary by question slot.
The screen opens at the first unsaved question and never replays saved slots.
Partial or ambiguous summaries, autosaved drafts, changed attempt IDs, elapsed
local deadlines, and attempts with no unanswered slot remain recovery cases.
The symptom reproduced before the fix and local widget checks cover blank and
partially saved attempts, original timing, and fail-closed cases. Focused
checks passed 43 tests, and the isolated suite passed all 1,005. Static
analysis retains the existing warning in the quiz results controller. No live
Moodle or native device verification was performed.

## Android build tool compatibility (2026-11-09)

Owner approved applying the tested Android toolchain fix to local `main`.
Commit `a02d253` updates AGP to 8.11.1 and the Kotlin Gradle plugin to 2.2.20
in `android/settings.gradle.kts`, using the existing Gradle 8.14 wrapper.
Flutter 3.47.7 reproduced the AGP minimum failure before the fix. The
integrated source built an arm64 Debug APK on Flutter 3.47.7 in the primary
checkout and on the CI-pinned Flutter 3.41.6 in an isolated checkout with the
committed lock. Both used `flutter build apk --debug --no-pub --target-platform android-arm64`.
The primary APK signature was verified. Kotlin daemon fallback occurred during
the builds and Flutter 3.47.7 reported future minimum-version warnings.
Emulator launch and remote CI remain unverified.

## Course lesson visibility (2026-11-09)

Owner approved displaying the lesson when its video link is unavailable.
Implemented in `ce661d5` on `main`. The saved response confirms that Moodle
can provide a named activity with a module ID and an empty `video_url`.
The course screen lists that activity by name as a disabled lesson when no
quiz or download identifies it. An open activity without a link is unavailable,
and a closed activity shows a lock. A playable video requires both `is_open`
and a nonempty `video_url`. Navigation and progress still use their existing
content rules because the response does not identify linkless activity types.
The quiz regression failed before the change at the missing lesson row and
then passed, including opening the video from Next and by tapping the row
when the refreshed course returned its link.
All 1,001 tests passed in the isolated checkout with the same dependency lock.
The primary checkout had 12 shader decoding failures, which did not reproduce
in the isolated checkout. Static analysis reported the same existing warning
in the quiz results controller before and after the fix. No native device or
remote validation was performed.

## Current continuation

Handoff request2026-10-23: owner asked for a detailed record so another agent can
continue. Start with [AGENT-HANDOFF-2026-10-23.md](AGENT-HANDOFF-2026-10-23.md).
It separates the seven GitLab requirements from the general605-case client
repairs, and records concrete remaining client gaps, backend unknowns, native
acceptance, approved decisions, exact commands and durable evidence. This task
changes documentation only; it does not add product implementation/remote work.
Handoff drafte1c3d60/correction30d79a2 passed an independent listed recheck with
no open findings. Documentation links/paths/shell examples and durable evidence
hashes were checked. Start there before interpreting historical records below.

Owner repeated 'اكمل'. Current durable worktree is
/Users/saker/.codex/worktrees/mopa-closeout-20261023/Messengers of Peace,
branchcodex/mopa-closeout-20261023. Earlier temporary worktree lost some files;
all commits were retained and final catalog records092f1dc integrated locally.
Owner approved lock adoption after backup/review and iOS15 minimum. Frozen M0
source17140ac now has605 tests/strict analyzer0, offline matching lock and
successful Android/iOS builds. The iOS build uses declared targets, no override;
independent reviewer confirms plist/Mach-O min15 and no source blocker. Original
foreign lock is backed up intact. Reviewed393341f is integrated locally into
original main; approved locks adopted and ignored Dart/native metadata
regenerated successfully with offline/enforced-lock and deployment-mode Pod
install. Main's605/605 tests and strict analyzer0 pass; Git is clean. No remote
push/CI, device install or account/API operation occurred during this closeout.

Previous2026-10-22 checkpoint:
Original main was fast-forwarded locally through reviewed checkpointedfa429,
including catalog/history sourcebedd7ad; its foreign lockfile is unchanged.
Only this final integration-record update follows the tested source checkpoint.
Execution/ownership/evidence: EXECUTION-2026-10-20.md.
Root observed605/605 synthetic tests and strict analyzer with no issues through
bedd7ad after M4/M5/M6/M7 and M8 lint/control fixes. Home level track and final
entry/route ownership corrections passed independent scoped reviews. Android
debug build succeeds; iOS arm64 simulator rebuild succeeds with the
command-only15.0 override. Badges/points catalog, history and shared points card
are implemented with25 ownership,36 list/card and24 real-font numeric-label
regressions. Ownership review passes32/32. List/card review closed its sole
inherited numeric-label finding with35/35 correction/geometry probes; updated
Android debug and iOS arm64 builds both exit0. No open local finding remains
in these two reviewed slices; backend/device/release acceptance stays separate.
The old declared-target failure is superseded by the approved iOS15 build in
17140ac. Concrete lock/OS decision/evidence is in
DEPENDENCY-LOCK-REVIEW-2026-10-22.md.
This is not full project,
backend, device, CI or release acceptance. No live/remote operations authorized.

## Historical authorization and planning


Latest direction (2026-10-20): Saker said 'اكمل' after the full remediation plan.
Proceed with its locally actionable slices. Backend/owner decisions explicitly
left open in the plan stay open; no production/remote authorization is inferred.
Main owns session/request ownership, transport/logging, integration and records;
profile and shared-data workers use separate branches/worktrees. Current board:
EXECUTION-2026-10-20.md. Preserve original foreign pubspec.lock unchanged.

Planning request (2026-10-18): Saker asked for a plan to address all errors. Main owns docs-only
comprehensive planning and coverage/review; no new application implementation.
Proposed plan: REMEDIATION-PLAN-2026-10-18.md, covering every finding, excluded
suspicions, all GitLab16-22 acceptance scenarios, backend/owner dependencies and
platform/CI gates. Its future choices remain proposed pending Saker's review.
Fresh read-only plan reviewer owns gap/dependency/acceptance review only.
Review completed: no missing actionable findings or blockers; one dependency
clarification applied so M5 depends on M1A rather than the full migration gate.
Plan remains proposed; no new product code or session/storage changes made.
Coverage check mapped all43 original audit IDs (including fixed/excluded IDs,
not43 open defects) and every GitLab16-22 row. Final reviewer rechecked the
dependency clarification and early logging redaction: no blockers. Docs-only
checks passed; no runtime test rerun was needed for this planning step.

## Authorized scope

Run the existing Flutter application on an iPhone simulator, explore its code,
analyze GitLab issues 16 through 22, and audit the rest of the application for
defects before preparing corrections. Saker authorized using his own account for
testing in this session. He will enter any credentials directly in the simulator.
No server edits, deployment, credential rotation, GitLab writes, or remote push
are authorized by this audit.

Earlier user direction (2026-10-17): defer interactive simulator access and
continue analyzing the code itself. The backend source is not available to
Saker; he may supply an API description later. Do not request simulator access
again during this source-analysis pass. This earlier direction authorized
analysis only; the later approval below authorizes the urgent repair batch.

Urgent repairs (2026-10-18): shared Toast/Back, visible completion validation,
stable reference loading, reset-to-sign-in with abandoned-work guards, and
rejection of empty failed HTTP responses implemented. Final integrated suite45
passed; fresh independent review found no blockers. Analyzer:6 existing infos,
0 errors/warnings. iOS build exit0 with simulator-only target override. Updated
app installed/launched (process evidence only). CI configured, not remotely run.
Verified commits fast-forwarded into original main at31a6cfe; original foreign
lockfile remains byte-identical. No push/deploy. Package resolution/testing is
in the isolated worktree; original ignored package configuration stays stale.
Exact evidence and remaining audit work: FIX-STATE.md.

Latest report (2026-10-18, user-observed):
password-reset password submission fails; Back appears ineffective; no toasts
appear; CompleteAccountInfo Save appears ineffective and the user skipped it.
Prioritize tracing these paths. Main owns Toast/Back/root-overlay reproduction;
app reviewer owns password-reset and CompleteAccountInfo validation/request
chains. Local reproductions are complete as described below; the exact failed
stage in Saker's live reset remains unknown. No simulator-specific cause claimed.

Urgent findings independently reproduced by main (2026-10-18):
- Actual MyApp + ToastX + BackButtonX: Back works before Toast; Toast raises
  `No Overlay widget found`, shows nothing, and leaves Get's snackbar queue open.
  Next Back raises `LateInitializationError` and leaves the page unchanged.
  Test changes only the in-memory routes to synthetic pages; it retains MyApp's
  real builder/theme/bindings. No application source was edited.
- Actual reset controller: accepted reset followed by rejected automatic login
  leaves the form failed. Two intercepted requests, no profile fetch. This
  proves a misleading combined failure is possible, not that Saker's password
  definitely changed. Loading resets to false; no loading-lock claim.
- Actual completion controller: valid text fields and missing country produce
  zero requests, no loading and only a Toast warning. Controller probes use an
  extra outer Overlay to isolate this flow from the product snackbar failure.
- The three urgent probes completed together: 3 passed. These observations
  prove current defects, not completed fixes. See SOURCE-FOLLOWUP-2026-10-18.md.
- Independently repeated cross-session profile probe: after actual appbar Back
  disposes A's controller, its delayed continuation uploads A's selected photo
  using synthetic B's token and user ID. Outbound attribution proved; actual
  backend persistence/authorization bypass not established. One test passed.
- Additional completed suites: HTTP/session/upload 8, data boundaries 8,
  playback/abandoned navigation 2. All synthetic/intercepted, no account calls.

Latest direction (2026-10-18): Saker approved starting repairs ('طيب ابداء
بالاصلاح') following the urgent findings. Start with shared Toast/Back,
completion field validation, and unambiguous password-reset success. Work in
isolated branches, preserve original pubspec.lock, add regression tests and
review before integration. Backend policy changes and remote push remain out
of scope. The implementation ledger is FIX-STATE.md.

## Workspace and ownership

- Baseline: `f338fa9`.
- Original checkout: `/Users/saker/Desktop/Flutter/Messengers of Peace`.
- Audit checkout: `/private/tmp/mopa-audit-20261017`.
- Branch: `codex/mopa-audit-20261017`.
- An existing modified `pubspec.lock` in the original checkout is protected.
  Its contents were copied into this isolated checkout before resolving packages.
- Main agent owns simulator/build, verification, audit evidence and state files.
- Read-only reviewers own learning/quiz, security, and remaining app flows.
  They have no permission to edit project files or call live APIs.

## Observed so far

- No project-specific memory index, living spec, map, coordination board, Dart
  tests, or CI configuration were found among tracked files.
- Flutter 3.41.6 / Dart 3.11.4 are installed. iPhone 17 Pro simulators running
  iOS 26.4 and 26.5 are available.
- Initial `flutter analyze --no-pub` in the original checkout: 3 errors caused by
  unresolved `open_file` and 6 informational findings. This is the stale package
  baseline, not a source correction result.
- HEAD already contains earlier fixes for downloads, course refresh, birth date,
  and translated messages. Open GitLab state alone does not establish regression.
- A service credential is embedded in the endpoint source and appeared in local
  inspection output. Its value is deliberately omitted here. Rotation is OPEN
  and requires coordination with the service owner. Never exercise it to infer
  its privileges. Per-user scope and server authorization remain unverified.

## Current work

- Dependencies resolved in the isolated checkout. Eight missing `open_file`
  packages were added by Pub, with one dependency classification change. The
  original checkout and its lockfile were not changed.
- Normal iOS run failed: current Xcode rejects deployment targets below 15.0.
  A command-line simulator-only `IPHONEOS_DEPLOYMENT_TARGET=15.0` override built
  successfully with exit 0. Product deployment-target files were not edited.
- Installed and launched `com.messengersofpeace.rakanalhawar` on simulator
  `1C4C054D-0C46-4762-8328-0B3E72617A48` (iPhone 17 Pro, iOS 26.5).
  Screenshot `/private/tmp/mopa-launch-20261017.png` confirms Arabic login UI.
- Post-resolution analyzer: 0 errors, 0 warnings, 6 informational findings;
  command exits 1 because informational findings are fatal by default.
- Seven probes in `/private/tmp/mopa-audit-probes/behavior_test.dart` failed
  their expectations: six demonstrate application behavior and one demonstrates
  Dart dynamic-extension dispatch. No active dynamic receiver was established;
  the dynamic-dispatch probe is a caveat, not an application defect. No failing product
  tests were added to the repository.
- Seven synthetic security observations were independently repeated successfully:
  shared-token fallback, current user-token selection, plaintext session data,
  no default local token expiry, and residual bytes after logical deletion.
- Simulator visibility: conventional Simulator.app was absent. Located and
  launched `/Applications/Xcode.app/Contents/Applications/DeviceHub.app`.
  Computer Use reports that Xcode and Device Hub access is not approved.
  The user first reported no simulator, then confirmed Device Hub appeared.
  A subsequent simulator screenshot shows the account-verification screen,
  confirming user interaction with the app. The user was asked to enter the
  verification code directly. Do not record that code or the displayed email.
  The user subsequently confirmed sign-in. A fresh screenshot confirms
  authenticated Home. Do not store the displayed identity or screenshot in
  the repository. Computer Use again denied Device Hub access; independent
  navigation and account scenarios remain pending, not completed.
- Three wrong-case local import/part paths were found; case-sensitive CI is
  not runtime-verified, but source spelling is confirmed mismatched.
- Performance evidence independently repeated: 4 synthetic tests passed.
  Actual getBlogs at 1,000 rows made 101 intercepted HTTP calls. Actual
  LeaderboardView mounted 1,000 images and 1,002 fade states before scrolling.
  HTTP decode timings are debug-host synthetic measurements, not iPhone jank.
- Fresh audit verifier requested three corrections: qualify credential
  privileges, move dynamic dispatch to caveats, and avoid an unmonitored
  no-network claim. These are applied to the report.
- Inspect the complete request/model/controller/view paths.
- Capture reproducible findings and separate source evidence from live behavior.
- Continue source-only analysis and synthetic local reproductions. Interactive
  simulator verification is deliberately deferred by Saker, not a blocker to
  this pass. Backend source is unavailable; descriptions may arrive later.

## Pending decisions and limits

- Backend source, schema, and test/staging environment have not been located.
- Requirements such as minute accounting and lesson completion need their real
  server contract; proposals are not adopted requirements.
- A comprehensive fix plan will distinguish local changes, backend dependencies,
  platform verification gaps, and user decisions. No production-ready claim.
- Documentation commit `62598dc` was fast-forwarded into the original main
  branch. Original lockfile SHA-256 stayed identical. No remote push was made.
  Generated build locks remain isolated and outside the documentation commit.
