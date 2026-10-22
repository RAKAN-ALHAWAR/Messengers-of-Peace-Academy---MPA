# Remediation execution

Owner instruction: 'اكمل', 2026-10-20. Plan: REMEDIATION-PLAN-2026-10-18.md.
Base:23827e2. Original foreign lock SHA256 remains
9ad24bce6ed2b390ee55772a69c51798d36c313c016841a36c44fa24941ad9c7.

## Active coordination

Current2026-10-22: root owns integration and all committed remediation source.
Active implementation: app_audit, /private/tmp/mopa-catalog-activity-20261022,
codex/mopa-catalog-activity-20261022, limited to registered catalog/history
files/tests below. All earlier auth/profile/data/quiz, M8 controls, course/level
performance and final M5 ownership reviews are handed back. No agent may edit
another active scope. The table below records the initial coordination.

Earlier takeover: level-track worker also hit the usage limit after33 green
cases. Root owns its remaining formatting/metric-key/render check and all
following implementation. Both entry/route and level-track independent reviews
were resumed and completed after quota recovery. Newly discovered P02 counterparts are registered
to root: BadgesView, ActivityPiontsView and MyAchievements history/controller;
lazy catalog/history rows and owned atomic personal snapshots, with focused
tests. No server/public-token classification change is implied for catalogs.

### Initial coordination (completed)

| Lane | Branch/worktree | Exclusive ownership |
| --- | --- | --- |
| Main M1A/transport | codex/mopa-remediation-20261020; reuse /private/tmp/mopa-urgent-fixes-20261018 | SessionLeaseX service; LocalData/Hive session generation; AppController; remote auth expiry; auth/OTP/controller continuation guards; HTTP upload deadline; logging; integration/docs |
| Profile M2 | codex/mopa-profile-20261020; /private/tmp/mopa-profile-20261020 | EditProfile controller/view; CompleteAccountInfo session-guard integration; UserX phone parsing/print removal; exact age calculation; matching tests |
| Shared data M3 | codex/mopa-data-20261020; /private/tmp/mopa-data-20261020 | Conversion extensions; FutureBuilderX/callers' request identity; BlogX short tags; matching tests. Do not edit profile/auth controllers, HTTP transport or quiz model files |
| Security review | read-only isolated review | Lease/expiry design before implementation; final combined diff before merge |

Shared seam: Core/Service/session_lease.dart, SessionLeaseX.capture with optional
isActive callback, isCurrent getter. Captures local userid/token plus a monotonic
revision incremented even for same-value credential writes/removals. Main owns
this API; profile integrates after the seam commit. Never log tokens or URLs.

## Boundaries

All checks use synthetic records/intercepted requests. No live-account or server
operations, external messages, remote push, secret rotation, storage migration,
dependency upgrades or minimum-OS changes. Unknown grading/completion/minutes/
clearing/download/auth contracts remain blocked per plan. Local work continues
on independent slices. Existing45 tests are the starting regression gate.

## Progress

- Latest owner message2026-10-22 repeated 'اكمل'. Continue the same approved
  local remediation scope. Entry/route-refresh56 focused tests are green at
  f74669a; its independent re-review was interrupted by reviewer usage limit and
  remains pending. Home lazy level-track implementation and isolated Android
  build are still active. Android Kotlin compiler-daemon connection repeatedly
  fails; investigate only owned local build processes/config, never stop shared
  or foreign daemons. Original main/foreign lock remain untouched.

- Read current source/docs/status and prior context. Main unchanged since plan;
  only original foreign pubspec.lock is modified. No new source edits yet.
- Next: isolate work, add shared lease and red/green tests; profile and model
  fixes in parallel, then integrate, review and proceed to remaining local work.
- Toolchain drift observed: global Flutter is now3.47 candidate abaf9c52378;
  using its new source with old resolved packages caused SDK language-feature
  compilation failures before tests. No global SDK rollback was made. Created
  isolated /private/tmp/mopa-flutter-3.41.6 at verified tag/db50e20168; official
  SDK bootstrap downloaded artifacts. All project verification uses that binary.
  Offline project resolution matches the previously resolved audit lock exactly.
- Shared SessionLeaseX captures account/token plus monotonic generation. Low-level
  Hive write/delete/clear and automatic expiry invalidate it synchronously.
  Initial7 lease tests and2 privacy regressions passed locally with pinned SDK.
- Shared identity stream now coalesces credential writes into a microtask. The
  revision still invalidates immediately; open widgets can retire completed data
  without a parent rebuild. Observed8/8 lease tests, including notification after
  Hive identity update and no notification for unrelated preferences.
- Auth lifecycle ownership transferred to codex/mopa-auth-lifecycle-20261020:
  AppController/Core import; Login/SignUp/OTP/Loading controllers and auth tests.
  Main retains transport, shared leases, diagnostics, integration and translations.
- Diagnostics now emit error category/code/type and sanitized stack frames rather
  than arbitrary response bodies, nested details, error messages or framework
  context/library contents. Removed raw quiz-result print. Two synthetic privacy
  tests passed; no credential rotation or deployed-state claim is made.
- Authenticated transport preserves401 before typed body casting/fallback, emits
  local expiry only for the matching current user token, and recognizes Moodle's
  exact invalidtoken response.403/500/timeouts and old-account401 do not expire a
  replacement account. Unowned legacy cache is excluded for authenticated calls.
  Observed13 synthetic transport cases plus12 HTTP response regressions passing.
- Multipart deadlines cover response headers and streamed body; owned client
  closes immediately on completion/error/timeout. A16MiB acknowledgement cap
  bounds memory (not uploaded file size). Seven synthetic POST/PUT tests passed,
  including stalled body/headers, normal response, single request and size cap.
  This conservative protocol cap is an implementation choice pending final review.
- Replacement HTTP status path observed green34/34 transport/privacy/upload and
  response cases. Removed superseded post-cast error branch in a separate step.
- Integrated profile commits cb20394/4a078d3/efb3d08: preserve explicit legacy
  phone bytes/options on reference failure, calculate age buckets by birthday,
  snapshot profile/photo submissions, skip acknowledged text on photo-only retry,
  and guard mounted/closed/superseded forms. Main independently observed53/53
  focused profile/model/completion tests. Missing phone-prefix default remains
  the pre-existing policy pending contract approval; no silent policy rewrite.
- Added secure-session/recovery/session-changed messages to all four existing
  locale maps. Language copy is local source coverage, not device localization QA.
- M3 integrated be5ef36/db0eddd. Main independently observed20/20 focused parsing
  and widget cases, including request retention, retry, event edits and account
  data retirement without parent rebuild. Controller-local cache ownership is a
  separate followup; widget leases alone do not prove controller mutation safety.
- Main next local scope: VideoPlayer controller + regular/YouTube control
  sections and player widget tests (V01 only); LoadingView request identity.
  Playback completion policy/learning minutes remain contract-blocked.
- OTP source sweep found raw debug prints of manual/autofilled codes in the
  vendored active widget. Main owns removing those payload diagnostics and a
  callback-preservation widget test. No external disclosure has been observed.

## Resumed2026-10-22

- Owner repeated continuation instruction. Verified original checkout still only
  has foreign pubspec.lock with the recorded SHA256; execution branches retained.
  Auth final race hardening and profile locale guards were interrupted uncommitted;
  lane owners resumed verification. M6 has tests only, no implementation yet.
- Main re-observed regular video position/play/pause/seek/mute controls reacting to
  controller notifications, including out-of-range position clamping. OTP manual
  entry/autofill callbacks still receive codes without payload debug output.
  Both synthetic widget tests passed. Native playback/WebView behavior stays open.
- First combined suite found163 passed/7 failed. All7 failures are pending
  FadeAnimation entrance timers from active session reloads in profile fixtures;
  no failed auth assertions. M2 followup2febb90 retires stale forms and updates
  scoped test animation drains, independently green58 in its lane; integrate next.
- Main M7 next scope: BlogPage model, database getBlogsPage, Blog controller and
  BlogView after b9571af date-only handoff; bounded on-demand page retrieval and
  lazy rows. Existing recursive getBlogs remains until replacement is proved,
  then remove separately. No guessed server page-size, cursor or grading policy.
- Independent review found two cross-lane defects before integration: anonymous
  startup repeatedly removed absent credentials, causing FutureBuilder session
  reloads; confirmed profile expiry on the login route left its local busy state
  locked. Made anonymous init idempotent and separated local submission ownership
  from permission to publish profile data. Root60-case auth/transport gate passed,
  including actual LoadingView reaching login and200-invalidtoken/401 recovery.
  Independent reviewer replayed39 auth/startup cases successfully after fixes.
- Lease checks now reject a retired owner before reading storage; a completion
  after controller disposal cannot access a closed Hive box. Nine lease tests
  pass. New expiry widget fixture flushes real Hive work before closing its box;
  an initial fake-async fixture hang was corrected, not reported as app evidence.
- General Remote fallback no longer implicitly opts out of authenticated401.
  Explicit ignoreUnauthorized remains available and tested. Request-parameter
  diagnostics now omit arbitrary body/query/auth/header values.18 focused
  transport/privacy cases pass, including both Remote fallback policies.
- Main owns FadeAnimation delay disposal after M2/M6 fixtures exposed a bounded
  but uncancelled delayed callback. Timer is now cancelled on disposal; original
  delay/animation still works. Two actual widget cases pass, with no waiting
  added to mask pending callbacks.
- M7 replacement observed27/27 parsing/pagination/actual-list cases.1000-entry
  archive issues one initial page request; next-page failure keeps rows and
  explicit retry requests the same page. Unknown total ends on an empty response;
  no fixed page-size assumption. Duplicate requests/pages and stale account,
  locale, disposal and refresh responses are guarded. Blog/Leaderboard builders
  mount at most25 image widgets for a400x700 test viewport at0/1/20/100/1000 rows,
  and the final row remains reachable. These are host widget tests, not device
  frame/memory benchmarks or server query-cost proof. Independent review next.
- Added all four locale copies for quiz recovery and pagination; signup now uses
  the backend language getter so UI fil never changes the existing wire ph.
- Removed superseded recursive article loader and its unused import only after
  one-page replacement worked. Re-observed16/16 pagination and real dated-view
  cases after removal. Git history retains the previous implementation.
- Root integration observed292/292 tests passing before additional reviewer
  findings. Independent feed measurements show Blog1000 images1000->5 and
  Leaderboard1000->7 at400x700 (host only). Remaining eager counterparts and
  removed session observers in certificates/meetings require further repair.
- Overlapping archive pages no longer count duplicate records toward the unique
  total: pages[1,2,3],[3,4],[5] remain reachable.23 feed cases pass after correction.
- Root protected-screen regressions exposed anonymous fallback requests and a
  mismatched profile reaching follow-up reads. Calendar/profile now reject an
  anonymous identity before cache/read, and profile validates initiating userid
  before follow-ups/publication.45 app-flow cases pass, including2 new regressions;
  fixtures that formerly mislabeled profile IDs were corrected to valid accounts.
- Root resumed continuation, integrated M4 correction4bb800a.57 quiz tests pass
  independently; reviewer re-ran75 quiz/cache cases plus a warm-cache logout
  probe. Actual15s answer timeout no longer permits finalization/retry while
  delivery is uncertain, even after late acknowledgement. Invalid question slots
  are rejected without truncation or silently shortening an attempt.
- M7 counterpart lane registered at /private/tmp/mopa-counterpart-lists-20261022,
  codex/mopa-counterpart-lists-20261022: certificate/meeting boundaries and lists,
  AllCourses/controller/view, shared CourseCard/carousel metrics and certificate
  layout. Root owns MyCourses controller/view and Notifications controller/view;
  M5 retains Home/CourseDetails until handoff. No shared-file overlap is allowed.
- Derived carousel sizing proposal accepted within existing visuals: responsive
  width and exact translated full-text/font/scaler metrics determine the lazy
  viewport height. No arbitrary fixed height, truncation or new dependency.
  Text preparation remains linear and will be measured separately from mounts.
- Latest owner continuation: 'اكمل'. Root took over the exact Home/Profile Rx
  correction and remaining M7 counterpart lane after all three lane agents hit
  their account usage limit. Their worktrees remain intact; no foreign lock is
  adopted. Independent final review is pending, so original main is not advanced.
- Mounted Home and Profile regression reproduced visible minutes0 after a
  controller refresh to17. Both now preserve their observable containers;
  Profile statistics also subscribe through Obx. Root observed78/78 learning,
  cache, MyCourses/Notifications cases after correction. An initial invocation
  named a nonexistent notifications test; corrected to notifications_lifecycle.
- MyCourses/Notifications now use lazy rows with reactive refresh; MyCourses
  refreshes once on return from an owned course route, and closed/anonymous
  owners issue no protected read. Host400x700 tests cover0/1/20/100/1000 records
  with bounded mounted rows and last-row reachability. Device performance open.
- Recovered M7 certificate/meeting work observed49/49 cases in its worktree:
  bounded rows, retained session observers, stale/anonymous guards, atomic
  snapshots, notifier disposal and certificate action layout/callbacks across
  four locales, widths320/400 and scales1/2. AllCourses carousel remains pending.
- M7 shared CourseCarousel now virtualizes both AllCourses axes and Home current
  courses. Root observed18/18 actual-view/real-font cases, including full mixed
  Arabic/English titles at scale2 and widths320/400. An initial Unicode mock
  fixture used Latin1 response encoding; explicit UTF8 fixed the fixture before
  those claims. A rendered Arabic artifact was inspected after entrance timers.
- Independent re-review closed mounted Home/Profile statistics (3/3), quiz
  timeout/recovery, protected cache/session and counterpart session findings.
  It also reproduced an additional Notifications read/mutation race: old GET
  could restore unread2 after mark-all acknowledgement0. Correction1745a50
  retires pre-ack loads; root26/26 and reviewer10/10 including actual-locale
  reload prove the acknowledged count remains0. No backend fixture used.
- Performance reviewer measured first-pass carousel preparation separately:
 1000 short-title records originally p50/p95=31.260/34.742ms, reduced to
 16.112/19.327ms by exact repeated-label measurement reuse within one pass;
  mounted cards remain2. Retained rebuilds did not recompute height (0/31).
  These31-sample host-debug figures do not prove device frame readiness;
  first-pass text preparation remains O(N), and device P03 acceptance is open.
- M8 ownership: auth_lifecycle_fix owns only DataSourceParam constructor lint,
  RadioButtonX typed RadioGroup/equality migration, dropdown color APIs and
  focused tests in a fresh isolated worktree. Root owns shared ButtonX and
  ButtonStateX accessibility overflow, tests/integration/docs. Fresh independent
  button review owns read-only adversarial geometry/state checks. No overlaps.
- Button overflow reproduced at320w/scale2. Minimum heights plus flexible full
  labels repair the shared plain/state variants; root24 accessibility cases
  pass. Earlier full run447pass/8fail was launched before correcting a new test
  host's non-scrollable column at3x; no failed production assertions elsewhere.
  Final integrated suite must be repeated after all M8 source is integrated.
- iOS build started with pinned SDK, generic simulator destination and isolated
  derived output, simulator-only15.0/signing override. It is still running;
  plugin/Swift warnings and x86_64 command diagnostics are not a success result.
  SDK startup lock is held by its active assemble process; other queued checks
  wait without deleting locks or interrupting foreign processes.
- Additional counterpart inspection: Home LevelsProgressSection still eagerly
  builds every level badge/number in a fitted row. This P02 counterpart remains
  locally actionable; do not report whole-project list virtualization complete.
- Original shared SDK engine download blocked other Flutter startup commands;
  isolated APFS clones retain exact3.41.6/db50e20168 bytes and separate cache
  locks. No lock deletion/global SDK change occurred. Root validation clone:
  /private/tmp/mopa-validation-sdk-3.41.6. All package resolutions remain offline
  with the already resolved audit lock, excluded from commits.
- Integrated M8 ec80cbb as6e6ae2f after inspecting scoped source/tests: default
  RadioGroup selection uses actual value equality, legacy explicit mapping is
  retained, dropdown alpha/callbacks and explicit auth fallback policy tested.
  Root combined suite465/465 and strict full analyzer0 issues passed; CI now
  requires strict analyzer. This is configuration/local evidence, not remote CI.
- Independent button review reproduced two replacement regressions before merge:
  bounded Center expanded to700px, spinner state added2px. Both corrected; fresh
  30/30 replay and unchanged baseline golden pass, nominal states remain40px.
  Root persists27 accessibility/dimension/state interaction cases in its suite.
- Final reviewed carousel exact-value snapshots avoid lossy hash-only cache keys.
  Independent69 combined/28 supplemental cases and scoped analyzer pass.
  1000-course preparation p50/p95=15.036/16.786ms (31 host-debug samples with warm
  font cache),0/31 retained text remeasures,2 mounted cards. Device gap retained.
- Generic universal iOS attempt failed in Flutter unpacking both arch names as
  one string despite fat engine containing both. A command-only arm64/active-
  architecture retry built successfully, explicit exit0. No product minimum-OS
  file changed and no app was installed/launched. Plugin warnings remain.
- Android verification runs in detached /private/tmp/mopa-native-20261022 at
  6838419 with isolated output and copied resolved lock. Doctor reports current
  SDK licenses incomplete; no license accepted or SDK version changed. Build
  result pending. Root source/CI/test and native evidence remain distinct.
- Home level-track lane allocated to completion_fix in fresh isolated worktree:
  only levels_progress.dart and focused tests. Preserve existing symbols,
  completion ratio and few-level layout; lazy readable scroll for large sets.
- Additional L07 counterpart red2/2: remounting Home/Profile with retained
  controllers kept cached minutes17 when the next synthetic response was29.
  New visible view entries force one fresh read through retained FutureBuilder;
  Profile owned edit/course returns also refresh. Forced failures retain prior
  model/timestamp but reject for visible error/retry rather than imply success.
  Root56/56 learning/cache cases pass; independent re-review is pending.
- Radio M8 re-review found indicator-only check() invoked for card-only mode.
  Correction194bb9e restores0 predicate/hash calls while retaining selection.
  Root persistent case and independent25/25 + clean scoped analyzer pass.
- Home badge geometry preserves the pre-existing5px stagger and full fonts.
  With46px images,16px normal label,20px padding and2px border its natural height
  is89px. The old86px fit required hidden compression. Approved routine choice:
  retain symbols/stagger, measure natural height with86px minimum, grow at large
  text scales. No arbitrary height cap or fitted/cropped text is accepted.
- Android build at6838419 completed exit0 in527.2s and produced the debug APK
  in isolated native checkout. Kotlin daemon connection failures fell back to
  compilation; these warnings are not a clean native toolchain result. No
  license accepted, dependency/SDK version upgraded or device app launched.
- Root recovered level-track source/tests after worker quota interruption:
  integrated7e530c0 as232848c,33/33 root cases and clean scoped analyzer. Render
  evidence was regenerated after entrance timers (first normal capture blank).
  Independent review at232848c passed33 committed+6 supplemental+1 baseline
  comparison;1000 images→8, actual RTL drag/end reachability/cache invalidation.
  Label preparation1000 p50/p95=13.019/16.249ms, retained .010/.019ms with0/31
  remeasures. This remains host-debug O(N) preparation/device-profile gap.
- Clock rechecked after latest continuation:22:23Asia/Damascus. Existing review
  agents resumed after the earlier quota window; no gate was bypassed. M5
  review reproduced repeated Home/Profile taps losing the real return refresh
  (expected17/actual0), plus a retained-controller origin retiring during GET.
  Root reproduced the latter/Profile double-tap red2/2 before repair.
- Root added Home/Profile single-flight navigation, propagated optional owner
  leases through Home/Profile/MyCourses/AllCourses loaders, and keyed Home
  pending coalescing by owner identity. Successful cache remains controller-
  owned. Root108/108 focused cases and strict analyzer0 issues pass; independent
  recheck pending. Expected synthetic500 diagnostics are asserted by exact type/
  code, not used to swallow rendering failures. A duplicate Home probe was
  folded into the parameterized case before the final108-case replay.
- Catalog/history P02 lane allocated to app_audit in a fresh worktree: lazy
  Badges/ActivityPionts catalogs and MyAchievements grouped history, atomic
  owned personal reads and corresponding tests. Root retains all M5/shared
  services/source and documentation; no shared-file overlap is permitted.
- Final M5 source correction7868801 independently rechecked:108/108 equivalent
  root cases plus5/5 original/supplemental navigation/coalescing/cache probes.
  Both findings closed, no new scoped findings. Exact reviewed-file manifest:
  /private/tmp/mopa-owner-rereview-2li_iid8/reviewed-bytes.sha256. Root complete
  suite520/520 now passes and strict analyzer reports no issues. Latest Android
  debug rebuild at7868801 exit0 in19.6s, iOS incremental arm64 rebuild pending.
  Catalog/history work is not included in that520-case checkpoint.
