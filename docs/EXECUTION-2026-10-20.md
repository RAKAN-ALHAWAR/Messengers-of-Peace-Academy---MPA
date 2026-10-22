# Remediation execution

Owner instruction: 'اكمل', 2026-10-20. Plan: REMEDIATION-PLAN-2026-10-18.md.
Base:23827e2. Original foreign lock SHA256 remains
9ad24bce6ed2b390ee55772a69c51798d36c313c016841a36c44fa24941ad9c7.

## Active coordination

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
