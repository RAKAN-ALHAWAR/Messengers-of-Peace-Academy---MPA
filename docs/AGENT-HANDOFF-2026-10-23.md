# Mopa agent handoff

Prepared2026-10-23, Asia/Damascus. Reader: the agent taking over this project.
Owner's latest instruction: document all completed work, remaining work and the
GitLab requirements in detail so another agent can continue. This handoff is
documentation, not a new implementation, deployment or account-testing approval.

Documentation review: draft e1c3d60, corrections30d79a2, independent listed
recheck closed both findings. Path/link/shell checks passed; product source and
the previously verified605-case baseline were unchanged by this handoff.

## 1. Read this first

The broad local remediation batch is integrated. **The seven GitLab requirements
are not all finished, and none was closed by this agent on GitLab.**605 passing
tests establish selected client regressions; they do not establish end-to-end
acceptance of those seven requirements. Do not repeat a blanket "all fixed".

GitLab16/22 have their requested client-side changes present, pending actual
account/native verification and the remaining policy checks below. GitLab17-21
are unfinished. Some remaining work is definitely in the client; some needs
backend contracts, and some needs native execution. Do not attribute everything
to the backend without reproducing it.

The owner asked both for GitLab fixes and a full-project audit. Much of the
completed work repaired general infrastructure, ownership, forms, quiz safety
and performance. The next implementation priority should be closing the named
GitLab scenarios, rather than treating more general cleanup as their delivery.
The proposed continuation order is in section10; product policies remain open.

### Checkout and exact checkpoint

| Item | Verified at preparation |
| --- | --- |
| Canonical checkout | `/Users/saker/Desktop/Flutter/Messengers of Peace` |
| Canonical branch | `main` |
| Starting HEAD | `b1409f4572e28e2fe689f21a06c132f14bb1527d`; handoff-only commits follow |
| Current implementation checkpoint | `17140ac`; earlier client/quiz/list implementation through `bedd7ad` |
| Durable managed worktree | `/Users/saker/.codex/worktrees/mopa-closeout-20261023/Messengers of Peace` |
| Worktree branch | `codex/mopa-closeout-20261023` |
| Starting status | Both trees clean before this documentation task |
| Remote delivery | No push, remote CI run, GitLab issue update or deployment performed |

Re-run `git status`/`git log` before acting; other agents/the owner can change
the checkout. No worker owns product files at handoff. The execution record
tracks any documentation-only helper/reviewer during preparation.

### Reading order

1. This document, particularly sections3,6,8,10 and11.
2. [Current disposition of all audit groups](REMEDIATION-STATUS-2026-10-22.md).
3. [Observed source map](PROJECT-MAP.source.md).
4. [Execution/coordination and detailed chronology](EXECUTION-2026-10-20.md).
5. [Approved remediation plan, M0-M8 and original43 audit IDs](REMEDIATION-PLAN-2026-10-18.md).
6. [Exact local evidence and commands](LOCAL-VERIFICATION.md),
   [platform gaps](PARITY-LEDGER.md), and
   [backend information request](BACKEND-CONTRACT-REQUEST.md).

[Original audit](AUDIT-2026-10-17.md),
[source follow-up](SOURCE-FOLLOWUP-2026-10-18.md) and
[urgent repair ledger](FIX-STATE.md) contain historical observations. They can
describe defects since repaired, protected locks since adopted, and an iOS
override since removed. Their baseline statements are not current verdicts.

## 2. Owner intent, decisions and safety boundaries

- Communicate with Saker in clear Arabic; technical code/docs/agent relays are
  English. Give issue-by-issue outcomes, with evidence and honest gaps.
- Original intent: inspect the seven issues on his GitLab account, run the app
  on an iPhone simulator, inspect the code, repair reported defects and audit
  the rest of the project. Local fixes and the M0-M8 plan were authorized.
- Saker has no backend repository. He said he might provide an API description
  later. No authoritative backend schema/plugin implementation was found.
- He initially authorized testing his own account and signed in. Native UI
  automation was denied access to Device Hub. He explicitly deferred that
  interaction and directed work toward code. It has not been resumed/proven.
- On2026-10-23 he explicitly approved **iOS15 minimum**, and **updating the
  tested dependency resolution after saving original locks and verifying it**.
  These decisions are implemented; do not ask for them again.
- That approval does not approve unrelated dependency upgrades, secure-storage
  migration/forced sign-in, invented grading/completion policies, server changes
  or remote delivery. Earlier backend/security choices remain open.
- All remediation automated checks used synthetic Hive/account data and
  intercepted HTTP. Do not contact the real API by accident while reproducing.
  Reconcile actual account/reset/grade/progress mutations with the owner and
  the applicable current-session authorization before exercising them.
- Do not push, deploy, rotate a service key, change a server or message a service
  owner without explicit scope. GitLab writes were not performed.
- Never dump Request objects, authenticated URLs, tokens, OTPs, passwords or
  user records. The endpoint configuration contains a bundled service secret;
  report its location/risk, never its literal value. Do not copy it into fixtures.
- Preserve other people's changes. Use explicit path staging, small scoped
  commits, actual post-change tests and the living execution/coordination board.

The project has no project-local AGENTS.md at this checkpoint. The owner supplied
a global constitution in chat. Actual local process/Flutter rules were found
under `/Users/saker/.claude/standards/process-standards.md` and
`/Users/saker/.claude/rules/flutter-{lib,tests}.md`. Named old `~/.Codex` imports
and `/Users/saker/Desktop/Gold/_refoundation/ROADMAP.md` were absent on this
machine; do not fabricate them. Apply the instructions available to the new run.

## 3. Every GitLab requirement: actual disposition and next proof

Source snapshot: seven items16-22 read on2026-10-17 from
[the owner's project](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items?sort=created_date&state=opened&first_page_size=100).
They were assigned to `abokhalel` in that inspection. They were not re-fetched
during this handoff. Current remote state/content/assignment is therefore not
asserted. Use the owner's signed-in browser/appropriate skill if a refresh is
requested; do not extract browser session secrets. Links below are identifiers,
not claims that remote acceptance or closure occurred.

### #16. Reject future birth dates and users younger than18

[GitLab16](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/16)

- Requested: prevent invalid future DOB/under18 registration; preserve the
  selected date and correct submitted age information.
- Present code: CompleteAccountInfo keeps the selected `DateTime` separately
  from the localized display string; picker maximum is the latest18-year-old
  birth date. `ValidatorX.birthDate` blocks missing/underage dates. Visible
  validation prevents an invalid save from sending a request.
- Additional repair: `UpdateUserForm.ageBucketAt` computes full years, including
  whether this year's birthday has occurred. Explicit backend age codes are
  preserved; no guessed DOB/clearing fields were added to the request.
- Files: `lib/Ui/Screen/Auth/CompleteAccountInfo/{controller/controller.dart,view/view.dart}`,
  `lib/Core/Util/validate.dart`, `lib/Data/Form/update_user_form.dart`.
- Evidence: `test/auth/complete_account_info_test.dart` covers visible missing/
  underage DOB and blocked requests; `test/data/profile_serialization_test.dart`
  covers before/on/after birthdays for26/41/66 age-bucket boundaries.
- Remaining: actual picker/form/account verification; add focused exact18th
  birthday/future-date cases rather than implying every boundary has a dedicated
  test. Confirm server age-code policy where necessary. The app sends an age
  bucket, not a raw DOB field. Do not invent a new server field.
- Closure: future DOB and17-year-old rejected; exact18 accepted; selection stays
  visible; submitted bucket is correct before/on birthdays; failure retains data.

### #17. Entry quiz completion must show1/1 rather than zero

[GitLab17](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/17)

- Status: **unfinished**, exact originally reported screen still unspecified.
- Completed related work: finalization acknowledgement validation, safe results,
  and owned return/entry refresh of Home/Profile/MyCourses/AllCourses. Refreshed
  statistics now update mounted widgets without replacing their Rx containers.
- Concrete client gap: `CourseDetailsController.getUniqueTopicsCount` still
  counts non-quiz video activities. A quiz-only course gives denominator0.
  Other screens use `numSections`, `totalSections`, `completedSections` or
  `completedTopicsTotal`. These are not established interchangeable units.
- Files: CourseDetails controller and `view/sections/completion_percentage.dart`;
  `lib/Data/Model/course/{course,mini_course}.dart`;
  `lib/Ui/Widget/Custom/Card/course_card.dart`; MyCourses view;
  `lib/Ui/Screen/Test/TestResults/controller/controller.dart`.
- Tests to preserve: `test/quiz/{finalization_ack,result_integrity,quiz_flow}_test.dart`;
  `test/learning/{empty_home,entry_route_ownership,mounted_statistics_refresh}_test.dart`.
  No inspected test proves a real quiz-only course becomes1/1.
- Next: identify the screen; obtain sanitized pre/post attempt and course/list
  snapshots; establish the total/completed unit; reproduce locally with fixtures.
  The denominator defect is a client investigation, not proof of a server fault.
- Closure: a passed finalized entry quiz displays1/1 on the actual affected
  screen and relevant origins, including after leaving/reopening the course.

### #18. Eleven lessons, file checkmark, lesson2 grading and durations

[GitLab18](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/18)

This is four deliverables, not a single "quiz fixed" checkbox:

1. **11 versus2 lessons:** CourseDetails controller and activities section count
   only non-quiz videos. Comments claim file-only topics count as one; the actual
   implementations have no file branch. Grouping uses `topicId`; card/detail
   totals use different units. Confirm what11 means using a mixed-content
   fixture, then repair the client counters consistently.
2. **File completion/checkmark:** the summary item does not pass `isCompleted`
   to `LessonItemOnAccordion`, whose default isfalse. `onTapLessonSummary` only
   downloads; it neither marks completion nor refetches. It also lacks the
   `activity.isOpen` check used for video/quiz. Actual file access/completion
   policy is unconfirmed. No file completion endpoint/trigger was invented.
3. **Lesson2 all-wrong grading:** local quiz safety/result identity repairs are
   implemented. Answer submission still sends a zero-based selected option index
   plus slot; backend acceptance/shuffle semantics are unconfirmed. No real
   known-answer lesson2 fixture established the original root cause. Do not
   change indexing merely because a response looked wrong.
4. **Duration:** optional `video_duration` is parsed by `ActivityX` and rendered
   in lesson items when supplied. Missing durations are not computed locally.
   Confirm units/format and actual payload before claiming this part fixed.

Files: `lib/Ui/Screen/Course/CourseDetails/controller/controller.dart`,
`view/sections/activities.dart`,
`lib/Ui/Widget/Custom/Other/lesson_item_on_accordion.dart`,
`lib/Data/Model/course/activity.dart`,
`lib/Ui/Screen/Test/TestQuestions/controller/controller.dart`,
`lib/Data/Database/database.dart` (`submitQuizQuestionAnswer`),
`lib/Data/Model/quiz/{quiz,quiz_result}.dart`.

Tests: `test/quiz/quiz_flow_test.dart` covers duplicate-label index identity,
save acknowledgement, rejected answers, resumed recovery and uncertain outcomes;
`result_integrity_test.dart` covers missing/malformed/reordered/duplicate slots.
There is no inspected dedicated acceptance test for the11 count, file checkmark
or a real duration payload.

Closure: one mixed quiz/video/file fixture establishes11 agreed units; authorized
file completion persists after reload; a known-correct/wrong lesson2 attempt has
the expected grade; provided lesson durations render in the agreed format.

### #19. Correct accumulated learning minutes

[GitLab19](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/19)

- Status: **not implemented as authoritative minute accounting**.
- Current code: `UserStatisticsX.fromJson` reads required `minutes` and
  `Ui/Section/UserStat/user_statistics.dart` displays it. Home/Profile refresh
  and mounted statistics updates are repaired.
- Evidence: `test/learning/mounted_statistics_refresh_test.dart` and the owned
  return/entry tests inject changed minute totals and prove they become visible.
  They do not prove correct accrual of learning time.
- Historical GitLab comment said the backend lacked minutes. Current server
  behavior was not reverified; do not state as fact that today's server lacks it.
- Need: source/event endpoint, active playback versus route time, pause/seek/
  background/replay/rounding rules, persistence and update latency.
- Closure: a controlled authorized learning event changes the authoritative
  total by the agreed rule; the app refreshes/persists the same total. Do not
  fabricate minutes from the retained five-second route-dwell trigger.

### #20. Immediate checkmark, unlocking and useful Next

[GitLab20](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/20)

- Status: **partly repaired, requirement unfinished**.
- Completed: stable CourseDetails Rx/Obx state; completion acknowledgement then
  refetch; failed completion/refetch preserves prior server state instead of
  fabricating success; abandoned/wrong-course work cannot publish; origin pages
  refresh after returning.
- Retained trigger: video-route wall-clock dwell of at least5seconds. It does
  not distinguish playback from loading/paused/background time. This is not
  approved watched-video completion or learning-minute measurement.
- Video checkmark uses server `isCompleted`; quiz uses completionPercent>=100;
  locking uses server `isOpen`. The file path remains incomplete as in#18.
- **Next is not implemented as next activity:** the results button says "Go to
  next lesson", but `TestResultsController.onTapButton` routes a passed attempt
  to course details. It never selects an eligible next lesson.
- Source-only candidate: AllCourses fallback uses `.map(...).isEmpty`/
  `.map(...).isNotEmpty` as existence predicates. Its intended need/authority
  must be confirmed; no new unlocking fallback was adopted.
- Tests: `test/learning/progression_test.dart`, `course_lifecycle_test.dart`,
  `entry_route_ownership_test.dart`, `refresh_owner_test.dart` and mounted-stat
  tests cover safe completion/refetch/lifetime/return behavior. They do not prove
  the actual next-lesson destination or backend unlocking policy.
- Closure: ordered progression fixture with video/quiz/file criteria; success
  updates checkmark/unlock across origins and reload; failures remain retryable;
  Next handles eligible/locked/final/mixed-content cases by an explicit rule.

### #21. Download, save and open files without blocking storage permissions

[GitLab21](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/21)

- Status: **existing permission fix present, full download requirement unverified**.
- Existing source: downloader falls back from unavailable/denied public Android
  Downloads to app-specific/documents storage; iOS uses app documents. Legacy
  WRITE_EXTERNAL_STORAGE is limited to Android SDK28. This predated the main
  remediation batch; do not claim the entire downloader was rewritten/tested.
- Files: `lib/Core/Service/download_file_form_url.dart`, AndroidManifest,
  CourseDetails summary handler, MyCertificates download callbacks.
- Open risks: standalone Dio GET has no app-session lease/auth integration;
  origin/redirect/auth/MIME/size/deadline policy is not established. URL-derived
  extension falls back to png; ASCII filename filtering may remove Arabic.
  OpenFile failure uses share fallback. Errors are swallowed after a toast and
  no explicit success result is returned. Awaiting this helper is not proof of
  a usable download or lesson completion; logout does not cancel the transfer.
- Global iOS arbitrary-loads configuration remains; inspect/confirm origins and
  justified exceptions before narrowing ATS or forwarding any credentials.
- No dedicated downloader regression suite was found. Certificate callback
  dispatch tests do not test actual download/save/open.
- Next: establish one safe authorized resource/auth/redirect contract; add local
  injectable downloader/path/open/share seams and synthetic fixture tests; then
  native permission/version/offline/Arabic-name/duplicate/HTML-login/oversize/
  invalid-content/open/share/logout scenarios. Do not send user credentials to
  guessed origins or mark a file completed just because the helper returned.
- Closure: a real authorized file is saved and opened on supported iOS/Android;
  rejection/error cases are correct and Arabic names/content remain usable.

### #22. Arabic complaint/mark-all messages and legacy old password

[GitLab22](https://gitlab.edialoguecenter.com/amerh/mopa-app/-/work_items/22)

- Requested client changes are present: complaint success and mark-all success
  use localized keys; old password uses `ValidatorX.oldPassword` rather than
  new-password strength validation. New password keeps its existing policy.
- Important limit: old-password validation still requires a nonempty trimmed
  value of at least6characters. No evidence establishes that every legacy
  password satisfies this; do not call the backend policy confirmed.
- Files: `lib/Ui/ScreenSheet/submit_complaint_or_suggestion_sheet.dart`,
  `lib/Ui/Screen/Notifications/controller/controller.dart`,
  `lib/Ui/Screen/Profile/ChangePassword/{controller/controller.dart,view/view.dart}`,
  `lib/Core/Util/validate.dart`, four translation maps under Config/Translation.
- Additional local repair: Notifications mark-all acknowledgement invalidates
  older list reads, preserves current ownership, updates unread state and returns
  the correct unread count through Back. Tests:
  `test/app/notifications_lifecycle_test.dart`, `test/ui/toast_navigation_test.dart`.
- Remaining: actual Arabic complaint/mark-all success and rejection, plus a
  backend-authorized legacy-password account scenario. No dedicated complaint
  or legacy old-password acceptance test was found in the current suite.
- Source-only follow-up candidate: complaint sheet still awaits submission then
  calls `Get.back()` without a route/session lease and uses a delayed state
  reset Timer. Reproduce dismissal/account-change while pending synthetically;
  do not report a verified navigation bug from inspection alone.
- Closure: acknowledged success shows Arabic feedback, failure shows no false
  success; mark-all count stays correct; a valid legacy password is accepted by
  the confirmed policy; dismiss/Back/pending flows remain owned.

## 4. Other user-reported symptoms and what was changed

These were additional to the GitLab7. Their actual original server stages were
not established by a live reproduction during remediation.

| Reported symptom | Implemented local repair | Evidence / remaining |
| --- | --- | --- |
| Resetting password failed | Reset acknowledgement is separate from sign-in; accepted reset returns to login; no automatic replay because later login/profile failed; reject empty HTTP error statuses; guard duplicate/abandoned work | `test/auth/password_reset_test.dart`, `test/core/http_response_test.dart`; actual OTP/reset stage/policy still needs a controlled scenario |
| Back did nothing | Toast presenter uses root Navigator overlay and owns dismissal/lifetime without trapping page navigation | `test/ui/toast_navigation_test.dart`, actual MyApp/GetMaterialApp harness; native gesture/keyboard scenarios still pending |
| Toast invisible | Same shared presenter/lifetime repair; supported localized feedback is exercised | Toast/navigation, fade and button tests; user-visible iOS/Android confirmation pending |
| Extra account information Save did nothing | Visible semantic/DOB validation, scroll to first error, no invalid request; stable reference request identity; single-flight/session ownership; text/image partial-success handling and safe teardown | `test/auth/complete_account_info_test.dart`, dropdown/profile/upload tests; real custom-field contract/native form still pending |

## 5. Full completed local implementation inventory

"Completed" here means the stated client slice passed its recorded local checks
and scoped review. The remaining columns in REMEDIATION-STATUS still apply.

| Area | Actual local work | Main evidence / commit anchors |
| --- | --- | --- |
| Urgent shared UI/auth/forms | Root-overlay Toast/Back, reset-stage separation, empty-error HTTP rejection, visible completion/dropdown validation | `9a18948`, `b7cea21`, `8c3ce77`, `a71999d`, `bfe8fa2`, `31a6cfe`; auth/UI/core tests |
| Session ownership and expiry | SessionLeaseX captures token/user revision and caller lifetime; credential rewrites invalidate leases even with same values; mounted views are notified; reject stale continuations and protected anonymous snapshots; current-token expiry coordinated | `3c60e34`, `0472fb8`, `9500fb2`, `83f86a6`, `882164a`; session/login/startup/verification/transport tests |
| Safe diagnostics/transport | Redact private response/parameter diagnostics, remove OTP output, explicit authorization fallback; bounded multipart header/body acknowledgement/deadline and immediate client cleanup | `8a95115`, `9500fb2`, `e400283`, `4199376`; diagnostic/data-source/authenticated-transport/multipart tests; actual server ACL/uploads unverified |
| Profile integrity | Preserve malformed legacy phone/reference choices instead of destructively normalizing; exact birthday age buckets; coherent text/photo snapshots, acknowledged text save/photo-only retry; locale/session-owned references | `cb20394`, `4a078d3`, `efb3d08`, `2792239`, `57eb0ef`; data/profile/auth completion tests |
| Shared data/request identity | Numeric-string parsing without losing identifiers; short-tag article parsing; FutureBuilderX retained request identity, retry/refresh/generation/session handling rather than repeat calls on incidental rebuilds | `be5ef36`, `db0eddd`; conversion/blog/future-builder/cache tests |
| Locale/calendar/events | Filipino UI locale fil with explicit backend ph mapping; current-locale dates; calendar selection/day filtering/twelve-hour display/noon; owned acknowledged deletion and return refresh | `ee00c9e`, `1bfa63a`, `6892fb5`, `657bf41`, `4a446d8`; locale/blog/calendar/event tests |
| Notifications | Live unread return, stale ownership retirement and pre-ack list invalidation after mark-all | `fe82b56`, `1745a50`; notifications lifecycle tests |
| Quiz safety/results | Strict slot identity and explicit pass status; unavailable results stay unavailable; rejected finalization blocks result fetch; answer-save/finalization single-flight, attempt/session lifetime and timeout recovery; no guessing restored answers | `21172e6`, `1671be4`, `5eff540`, `4bb800a`, `0ea15f3`; quiz3-suite coverage; semantic grading/deadline/resume contracts remain open |
| Course/overview refresh | Empty Home safe; retain server completion on failed writes; capture original activity despite reorder; stable Rx statistics; force owned return/new-entry refresh; double taps retain actual navigation owner; retired routes stop follow-ups/publication | `13a129e`, `10e71bf`, `afab527`, `efab99f`, `f74669a`, `7868801`; learning7-suite coverage; actual progression still incomplete |
| Player controls | Regular video controller notifications rebuild visible controls | `7a3da66`; player controls tests; native regular/YouTube/audio/interruption behavior not verified |
| Feed/pagination/lists | Blog initial single page/on-demand pages/retry/dedup/overlap; removed recursive prefetch in a separate commit; lazy Leaderboard/Notifications/MyCourses/Certificates/Meetings/AllCourses and owned protected observers | `d8f26d0`, `38ef0f5`, `30110ea`, `601e22f`, `ab7a6ed`, `6a1eea0`; performance pagination/list/counterpart/session suites |
| Course/level sizing | Shared lazy full-title CourseCarousel with exact layout-key/text/font invalidation; lazy Home level track preserves full labels,46px art,5px stagger and continuous completion line | `6a1eea0`, `232848c`; carousel/level tests and independent real-font/RTL/cache probes |
| Catalog/history/points | Lazy Badges/ActivityPionts catalogs and grouped MyAchievements history; atomic personal snapshots and app identity ownership; bounded6-badge preview; shared PointsCard grows from160px; full large activity numbers wrap | `b6bcd4a`, `4f192bb`, `bf1b52d`, `bedd7ad`;25 ownership+36 catalog/card+24 real-font numeric cases, plus independent probes |
| Shared controls/lint/CI | Full scaled ButtonX/ButtonStateX labels with normal geometry/state callbacks; typed RadioGroup equality and card-only predicate behavior; dropdown withValues and DataSource constructor cleanup; case-sensitive import repair; strict analyzer CI config | `494d622`, `6e6ae2f`, `194bb9e`, `6838419`, earlier `628a458`; shared UI/control tests; remote Linux runner not run |
| Reproducible M0 native baseline | Durable pinned SDK, approved exact lock graph/manifest floors; backed-up foreign locks; declared Runner/Pod iOS15 and preserving higher dependency minimums; original ignored metadata regenerated | `17140ac`, `393341f`, `48cc0d2`, `b1409f4`;605 tests, strict0, both native builds and independent floor/lock checks |

The full chronological record remains EXECUTION. For exact patches/history:

```sh
git log --oneline --reverse 31a6cfe..b1409f4
git show 17140ac
git show bedd7ad
```

## 6. Known limits and remaining audit groups

The approved plan maps all43 original audit IDs; they are not43 still-open bugs.
Use its inventory plus current REMEDIATION-STATUS, not a count inferred here.

| Remaining area / IDs | What still needs proof or a decision |
| --- | --- |
| S01-S03, M1B | Bundled service credential ACL/public-operation classification and rotation/removal; server authorization/revocation; secure-storage/session migration. Selected personal client guards are not backend ACL proof. No storage migration or forced reauthentication adopted. |
| S04,L05 | Download origin/redirect/auth/MIME/size/deadline/file policy, ATS and file-completion trigger. See#18/#21; downloader is not covered by the guarded main HTTP adapter. |
| L04,L06,L09,L11,A10 | Authoritative unit/completion/minute/unlock/grade policy, attempt/result identity and deadline/resume state. Five-second route dwell and zero-time-limit→120seconds are retained, not policy endorsements. AllCourses existence-predicate candidate and real Next remain as above. |
| A01,A02,A04 | Meeting ID/end/status and unconfirmed-account verification identity/token contracts; do not fabricate a usable tokenless session or send an empty verification identity. |
| A07,I03,I04,X03-X05 | Omit-versus-clear optional fields, inactive serializer policy, Unicode phone/name/legacy-password and repeat-event rules. I03 is inactive/characterized; do not present it as an observed account failure. |
| U01-U03,H01-H03,C01-C02,F01,I01,A08-A09,D01,D03,I02 | Recorded local fixes remain subject to actual server payload/age/custom-field/native interaction/reset/upload checks. Generic session repair does not mean every standalone sheet/callback was audited at runtime. |
| A03,A05,A06,X01,X02,X06 | Actual API timezone/event/status/mark-all sentinel/complaint acknowledgements and native locales remain unconfirmed despite local client fixes. |
| P01-P03 | Actual pagination/payload/query/retention contracts and device-profile decode/mapping/frame budgets. Lazy mounts do not bound API payload/model memory. Initial carousel/level sizing is O(N); history grouping is O(N log N). |
| Q03,Q04,B01 acceptance | Strict local analyzer/CI config/import repair are present; actual remote GitLab Linux CI, release/profile/signing, supported-device native flows and iOS15-device runtime are unrun. Local Docker daemon sockets were unavailable; no daemon or remote Docker context was started/contacted. |

Q01/Q02 are locally closed after the owner's2026-10-23 lock/iOS decisions.
D02 and explicitly refuted allegations stay excluded: inactive HttpOverrides
does not establish an active TLS bypass; the Ahem overflow was a harness issue;
do not pad findings with inactive retry/cache poisoning or disproven time-picker
claims. Existing native dependency/Swift/Kotlin/CocoaPods warnings remain; builds
passed, but the toolchain is not warning-free.

Backend needs are detailed in BACKEND-CONTRACT-REQUEST. No message/request was
sent to the backend owner. Missing backend source is not a reason to postpone
client fixture reproduction or source defects that can be established locally.

## 7. Exact verification, durable evidence and reproducibility

Latest complete check was run from the **canonical original checkout**, after
approved locks and ignored metadata were regenerated:

- 605/605 tests passed, expanded reporter.
- Strict `flutter analyze --no-pub`:0 issues, exit0.
- iOS arm64 Debug simulator build exit0 using declared iOS15, no deployment
  override. Produced plist and Mach-O report minOS15.0, SDK27.1. No install/run.
- Android Debug actual APK built, exit0,32.5seconds. Kotlin daemon fallback
  warnings/trace remain. No emulator/native file/media acceptance.
- Original Git status clean and all5 M0 reviewed build-file hashes match.

### Durable evidence directories

| Path | Contents |
| --- | --- |
| `/Users/saker/.codex/backups/mopa-20261023-locks` | Pre-adoption original locks/manifest; original605 test/analyzer logs, offline lock and deployment-mode Pod logs; native build logs/derived app; SDK diagnostic/interrupted attempt evidence |
| `/Users/saker/.codex/backups/mopa-m0-independent-review-20261023` | Independent5-file frozen manifest; actual plist/Mach-O metadata and24 synthetic post-install floor cases/72 configurations, preserving higher16/16.4 and3 non-iOS configs |
| `/Users/saker/.codex/backups/mopa-handoff-evidence-20261023` |42 copied supporting review/log/render/probe files,415316bytes at creation, with source paths/SHA256 in manifest.json; no originals deleted |

Key durable logs in the first directory: `original-full-tests.log`,
`original-analyze.log`, `original-pub-get.log`, `original-pod-install.log`,
`android-build.log`, `ios-build-no-override-retry.log`.

The successful iOS quiet log is empty. It alone cannot establish exit0; that
exit was observed by the owning process, and produced native artifacts were
independently inspected. First iOS attempt was interrupted exit75, not green.

Most earlier logs/renders used `/private/tmp` or `/var/folders`. Some temporary
files disappeared between turns, including the old remediation `.git` file and
tracked files. All commits were retained in the real repository. The durable
evidence snapshot preserves selected earlier logs/probes/renders; it is not a
complete archive of every initial audit command. Do not rely on every old tmp
path still existing, and do not repair/reset/delete old partial worktrees.

### Review corrections worth preserving

- Retained Home/Profile double-tap navigation and retired origin ownership were
  independently reproduced, then corrected; focused108 plus5 independent cases.
- Catalog Badges missing AppController/user ownership:3 independent reds;
  correction32/32 includes25 persistent+7 independent cases.
- Shared activity numeric max-int overflow:159/349px at2x/3x; root16pass/8fail
  before correction;24 new+36 existing cases green. Independent35 correction
  cases include8 ordinary geometry comparisons unchanged within0.001px.
- M0 review confirmed131→139 Dart packages,8 expected additions,0 existing
  Dart version changes;42 native targets/19 resources/126 configs at15.0.
- A retained MockClient fixture, a route-disposal fixture and early un-settled
  fade captures were corrected during verification. Their initial failures/
  blank pictures are not product-defect proof; correct green reruns are recorded.

Selected performance observations are host-debug measurements, not device frame
guarantees. Real-font400x700/1000-record catalog review mounts5 badge and7 activity
rows initially; history initially shows its bounded prefix. End mounts7/8/9,
last entries reachable.31 warm samples: mapping1000 p50/p95=.774/1.084ms;
history sort/group/flatten=.439/.591ms, excluding transport/JSON decode.31 retained
theme rebuilds trigger0 history preparations and retain the original2 requests.
See evidence manifests/LOCAL-VERIFICATION for carousel/level metrics and methods.

## 8. Safe local commands and source entry points

Use the verified SDK. An earlier run observed the global Flutter drifting to
3.47candidate; its current state was not rechecked for this documentation task.
Pinned Flutter3.41.6 commit `db50e20168db8fee486b9abf32fc912de3bc5b6a`,
Dart3.11.4, engine `425cfb54d01a9472b3e81d9e76fd63a4a44cfbcb`.
Manifest declares Dart^3.11 and Flutter>=3.41; CI pins exact3.41.6.

```sh
cd "/Users/saker/Desktop/Flutter/Messengers of Peace"
git status --short
git log -5 --oneline
/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter --version
/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter pub get --offline --enforce-lockfile
/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter test --no-pub --reporter expanded
/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter analyze --no-pub
```

No dependency updates are necessary just to reproduce. If offline resolution
cannot use the expected cache, investigate the missing package first; do not
silently upgrade72 packages reported as newer outside the current constraints.

```sh
cd "/Users/saker/Desktop/Flutter/Messengers of Peace/ios"
pod install --deployment --no-repo-update
```

Verified native build form, allocate a new owned derived-data path for each run.
The old `backups/mopa-20261023-locks/ios-derived` directory contains hashed
evidence; preserve it. Historical commands in LOCAL-VERIFICATION record that
old path for provenance and must not be copied to overwrite the snapshot.

```sh
cd "/Users/saker/Desktop/Flutter/Messengers of Peace"
mkdir -p "/Users/saker/.codex/build-runs"
mopa_derived="$(mktemp -d "/Users/saker/.codex/build-runs/mopa-ios.XXXXXX")"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath "$mopa_derived" ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO -jobs 4 -quiet build
/Users/saker/.codex/workspace-runtimes/flutter-3.41.6-mopa/bin/flutter build apk --debug --no-pub
```

These are build commands. Launching the app may initialize real API/session
work; do not equate build scope with permission for live account mutations.
Do not blindly reuse the old simulator ID, assume the user's session remains
logged in, or interfere with simulators used by other work. Resume UI access
through supported tools/permissions; do not bypass the Device Hub denial.

Request chain:

```text
GetX view -> controller -> DatabaseX -> endpoint selector / RemoteDataSourceX
  -> HttpX request/response -> Moodle REST -> parsed models -> owned state -> UI
```

Important files: `lib/main.dart`, `lib/Config/Route/route_list.dart`,
`lib/Core/Controller/App/app_controller.dart`, `lib/Core/Service/session_lease.dart`,
`lib/Data/Database/database.dart`, `lib/Data/Database/remote/remote_data.dart`,
`lib/Core/Helper/http/`, `lib/Ui/Widget/Basic/Utils/future_builder.dart`.
The download helper bypasses the principal HttpX path as described above.

## 9. Lock adoption, backups and rollback boundaries

Owner-approved current hashes:

| File | SHA256 |
| --- | --- |
| `pubspec.lock` | `6d4f614da44fdd097bc6929b6fbed9581a7d4d17e7fd34fe080b8ab4c7ab1190` |
| `ios/Podfile.lock` | `821c41e0b8f114e7eb274b3f4e6a94f33ebcb38b1e34ea546406fa020dfddacb` |

Original pre-adoption copies are in the first durable evidence directory:

- Dart original SHA256 `9ad24bce6ed2b390ee55772a69c51798d36c313c016841a36c44fa24941ad9c7`.
- Native original SHA256 `eded9ae6dfe3c31cabc6f901a1c31e6b79e1dcab6081382f5f8ce4d50dfe4bcd`.
- The native resolution changed open_file_ios pod0.0.1→1.0.3 and7 reviewed
  plugin spec checksums, plus the intentional new Podfile checksum. No existing
  Dart package version changed. Native pod versions and Dart package versions
  are different records; do not describe the native version change as absent.

Do not blindly restore these historical locks onto the current manifest. A
rollback must restore a coherent source/manifest/native/lock checkpoint, account
for the owner-approved support decision and preserve any later work. Use scoped
Git history/revert proposals and the backed-up originals, not hard resets,
history rewrites or broad worktree deletion.

The durable SDK was restored from the same pinned engine after copied tmp cache
artifacts lacked ios-release and2 LICENSE files. Flutter cache.dart checks these
licenses and otherwise attempts redownload while holding its startup lock.
All346 existing engine files matched the verified primary; only missing assets
were copied. Do not patch Flutter cache checks, delete a shared startup lock,
kill unrelated processes or adopt an interrupted wrapper's exit0 as build proof.

## 10. Recommended continuation order, not new policy approval

1. Read the current source/status and revalidate checkout, baseline and permission
   scope. Report the seven issues using **implemented / locally verified /
   native-account verified / still needed**, not a single completion count.
2. Separate remaining client defects from unknown policies: quiz-only denominator,
   video-only counts, unwired file completion marker, real Next selection and
   standalone downloader behavior. Add narrow synthetic reproductions before
   changing behavior; use known wire field names and preserve existing guards.
3. Resolve UI-control access for the actual chosen simulator only when native
   testing is resumed. Smoke#16/#22 and one authorized download scenario#21.
   A real password reset changes credentials; quiz/progress/notification/profile
   writes change account data. Group needed environment/account/rollback
   questions once, without repeatedly asking "continue?".
4. Obtain a minimal sanitized course/attempt fixture to join#17/#18/#20: ordered
   topics/activities of all types, actual count units, before/after completion,
   known answer identities and result-attempt identity. Reproduce locally; fix
   confirmed client code without assuming the whole problem is backend-only.
5. Obtain only the genuinely missing authoritative minute/playback/file/grade/
   unlock contracts. Mark a subtask BLOCKED-CONTRACT with the precise missing
   field/rule/sample; continue independent work rather than blocking all5 issues.
6. Complete device/native/error/language scenarios and the actual authorized
   GitLab Linux runner. Remote push/issue closure/deployment are separate actions,
   not implicit consequences of green local checks.
7. Close an issue only when all its requested subparts have after-change proof.
   Record expected/observed values, fixture version, app commit, platform and
   remaining counterpart. Update execution/status/parity and commit each slice.

Do not silently choose: answer IDs versus indices, course denominator units,
zero-timer semantics, watched-completion threshold, file-completion trigger,
missing grade relabel, clearing behavior, unlock rules or credential migration.
These are business/API decisions; source names are not a backend contract.

## 11. Quick-start prompt for the next agent

```text
Continue the Mopa Flutter project from its current checked-out state. Read
docs/AGENT-HANDOFF-2026-10-23.md fully, then the linked current status, execution
board, source map and approved plan. Revalidate Git and the pinned toolchain;
preserve all other changes and the605-test baseline. Prioritize the unfinished
GitLab17-21 and the remaining native/policy acceptance of16/22. Distinguish
confirmed client defects, untested native flows and genuinely missing backend
contracts. Do not assume all605 tests mean these seven requests are delivered.
Use local synthetic reproductions first; do not invent grading/progression/
minute/download-auth rules. Respect current live-account/remote permissions,
never expose credentials, and do not bypass denied UI control. Communicate
clear Arabic status to Saker. Keep the execution/status/parity files current,
make scoped commits, and report each requirement with actual closure evidence.
```

This prompt transfers context; the next agent must still follow the governing
instructions and actual owner's scope in its new task.
