# Complete defect remediation plan

Date: 2026-10-18. Source checkpoint: dce8750.
Status: PROPOSED FOR SAKER'S REVIEW. Request: 'اعمل خطة لمعالجة الاخطاء كلها'.
This authorizes planning, not adoption of the choices or new implementation.
No backend/production change, remote push, dependency upgrade or credential
rotation is authorized by this document. Previously completed urgent repairs
remain accepted local work with their own outstanding device acceptance.

## 1. Outcome and scope

Resolve every actionable finding in both audit reports, verify all seven GitLab
requirements, and leave a reproducible tested iOS/Android application. A finding
is closed only with its post-change acceptance evidence. Missing backend source
does not prevent frontend repairs, but contract-dependent work stays explicitly
open until the actual contract and authorized test scenario exist.

Included dimensions: correctness/data integrity, auth/session isolation, transport
and file handling, quiz/progress requirements, async ownership, performance,
profile/calendar/notifications, localization/accessibility, build/dependencies,
CI, platform parity and failure/offline verification.

Not established by this plan: server authorization/scalability/security audit,
production load or device-frame performance results, backend implementation,
legal/education-policy approval, web implementation or deployment approval.
Backend/web counterparts get recorded handoff tasks, not presumed fixes.

Sources: AUDIT-2026-10-17.md, SOURCE-FOLLOWUP-2026-10-18.md, FIX-STATE.md,
LOCAL-VERIFICATION.md, PROJECT-MAP.source.md, PARITY-LEDGER.md and
BACKEND-CONTRACT-REQUEST.md. Historical report line numbers refer to their
baseline; recheck exact current locations before editing. No secret values here.

## 2. Preserve what already works

The urgent repair baseline has 45 committed passing tests and an iOS simulator
build using a target override. Independently reviewed source is in main through
31a6cfe; dce8750 records integration. Keep these regressions in every batch.

| Finding | Current status | Remaining acceptance |
| --- | --- | --- |
| U01 Toast/Back | Locally repaired | Actual iOS/Android gestures, all languages, active keyboard and repeated messages |
| U02 completion feedback | Locally repaired | Real form submission/validation against confirmed profile contract |
| U03 reset/sign-in conflation | Locally repaired | Actual reset rejection/success acknowledgement; original account failure stage remains unknown |
| H01 empty HTTP errors | Locally repaired | Endpoint controls plus device failure scenarios; preserve legitimate empty 2xx |
| C01 abandoned forgot-password route | Locally repaired | Retain disposed-request/delay regressions; do not count it as still unfixed |
| B01 import case | Source corrected | Clean case-sensitive checkout and green CI runner |
| A08 photo failure | Completion fixed, EditProfile open | Honest partial success and retry on both paths |
| Original issues16/20/21/22 | Earlier fixes exist in source | Do not reopen/reimplement blindly or close without their acceptance scenarios |

## 3. Working rules and dependency order

Use small vertical slices: reproduce, specify the request/state boundary, fix,
run targeted red/green regression, review, scoped commit, update the ledger.
One owner per shared file; separate worktrees and synthetic resources. Merge
only green slices, then one integrated suite. Sensitive auth/data changes need
security review; list/network changes need measured performance review.

No broad rewrite, UI redesign or package upgrade is implied. Prefer existing
GetX/controllers/data facade with explicit service seams. Introduce only shared
mechanisms needed to remove repeated root causes. Capture old behavior/blame
before changing conditions. Prove replacements before deleting old code.

Dependency order:

```text
M0 reproducible verification + contract requests (start together)
  -> M1 session/request ownership -> M2 profile/uploads
  -> M3 shared parsing/future lifecycle -> M4 quiz -> M5 learning/progress
  -> M6 calendar/notifications/localization
  -> M7 bounded lists/parsing performance
M1 ownership applies across M2-M7; M3 parsing precedes quiz/count conclusions.
Backend descriptions unblock their named slices, not the whole project.
M8 device/contract acceptance integrates every completed slice.
```

M0 and M1 are deliberately split gates: M0-local keeps isolated checks running
while lock/minimum-OS decisions wait; M1A is local request/operation ownership
and known-HTTP-expiry handling, and M1B is credential boundary/storage migration
plus backend-specific verification. M2 and M4 depend on M1A, not completion of
M1B. M3 can start beside M1A, but account-scoped cache integration waits for it.
Each milestone may close its local slice while its contract slice remains open.

The sequence prioritizes wrong-account writes and misleading grades/completion.
Independent local items may run in parallel after shared owners are assigned;
quiz/question/result files stay in one lane. No unreliable calendar estimate is
given before the missing contracts and platform-support choices are resolved.

## 4. Milestones with acceptance and commands

Commands naming new test files below are PLANNED acceptance commands, not
existing tests or evidence they pass today. Existing tests remain under test/.

### M0. Reproducible baseline and tracked coverage

Owner: main/integration. No blocking backend dependency for local checks.

- Preserve original foreign pubspec.lock byte-for-byte. Compare the current
  pubspec, foreign lock and resolved audit lock; show the exact proposed lock
  delta for approval before touching that file. Do not hide this with manual
  package_config edits or silently commit a different dependency set.
- Capture current toolchain, package resolution and native configuration in a
  clean isolated checkout. Keep the 45 tests and move useful scratch probes into
  committed regressions as their owning defects are repaired.
- Resolve supported minimum iOS with Saker before changing deployment targets.
  Current Xcode needs15 for this build; that alone does not authorize dropping
  support for older users. If older support is required, choose a compatible
  supported toolchain rather than silently raising the product minimum.
- Record Android minimum/target SDK and actual plugin requirements. Check clean
  Linux imports and the existing GitLab CI job. Runner availability and actual
  remote execution need access/authorization, not a claimed green result.
- Open per-finding rows using the inventory below: owner, status, dependency,
  commit, exact acceptance command, observed result and remaining platform gap.

Acceptance: independently resolvable checkout, unchanged foreign user files,
all45 baseline tests green, and explicit native/CI gaps. Package upgrades are a
separate one-package reviewed change after approval, not a bulk 'fix'.

```sh
flutter test --no-pub --reporter expanded
flutter analyze --no-pub --no-fatal-infos
git diff --check
```

### M1. Session identity and abandoned asynchronous operations

Owner: auth/session lane. Findings S01-S03, H02, C02, A02 and counterparts.
M1A: shared ownership and known-HTTP auth recovery, locally actionable.
M1B: public/protected token policy, secure storage and verification payloads,
gated separately by contract/migration decisions. Do not block M2 on M1B.

- Add one shared session/operation ownership mechanism. Capture initiating
  account and session generation; invalidate on login/logout/account replacement.
  Every follow-up request, shared state write and navigation must verify its
  ownership after awaits. A stale result must never run under the next account.
- Sweep login/password/Google/OTP/signup/profile/events/download callbacks for
  the same lifetime error. Keep the already fixed forgot/reset/completion tests.
  Cancel supported in-flight operations and all owned timers/listeners.
- Remove raw user/result model dumps and redact credentials/OTP/passwords and
  authenticated URLs at the logging boundary before further account testing.
  Assertions report synthetic stage/count metadata, never Request objects.
- Protected requests must require a nonempty user token and never silently
  adopt a bundled shared identity. Public auth/reference functions need their
  own explicit contract. Login success with userid but no valid token must not
  create an authenticated session. Obtain authoritative userid for verification;
  never send an empty ID or force-unwrap one on unconfirmed-account paths.
- Normalize confirmed auth-expiry signals, coordinate one expiry transition and
  clear identity safely. Ordinary offline/timeouts and every403 must not cause
  logout. Preserve the failed action for an explicit retry after sign-in where
  safe; do not automatically replay mutations after an ambiguous response.
- Specify OS-protected credential storage behind a session-store interface.
  Any new dependency needs selection/review approval. Migration must be staged:
  secure write, read-back, switch readers, verify restart, then retire legacy
  token storage. Alternatively propose a one-time reauthentication migration.
  Both choices need Saker's decision before changing existing sessions.
- Legacy plaintext bytes/backups cannot be declared erased by Hive key deletion
  or a build variable. Coordinate server revocation/rotation where required.
  Rollback must retain secure storage or require sign-in, never restore plaintext.
- S01 backend handoff: inventory intended public functions/ACL without exercising
  the embedded key, design an appropriate public boundary, verify replacements,
  then arrange owner-authorized rotation/removal. Never just move a privileged
  shipped secret to a build-time environment variable and call it secure.

Acceptance: delayed A request -> logout/loginB -> no A follow-up/photo/state in
B; same-account re-login also invalidates old work. Missing token sends no
protected request. Concurrent expiry causes one transition; offline preserves
session. Secure migration survives restart/interruption and has no silent data
loss or plaintext fallback. Actual ACL/OTP/revocation controls remain backend QA.

```sh
flutter test --no-pub --reporter expanded test/auth/session_lifecycle_test.dart test/auth/session_store_test.dart test/auth/verification_test.dart
```

### M2. Profile data integrity and bounded uploads

Owner: profile lane after M1A. Findings F01, C02, H03, A07-A09 and malformed phone.

- Retain the user's existing country/language/phone prefix when reference data
  fails. Loading/error/unknown is distinct from a user selection; never substitute
  +966 into unchanged non-Saudi data. Represent legacy unknown selections safely.
- Apply shared ownership to EditProfile before a follow-up upload, profile
  refresh, success navigation or delayed reset. Keep CompleteAccountInfo parity.
- Cover upload headers AND body with a bounded deadline/cancellation; enforce
  a documented response budget. Snapshot the selected image and request identity.
  Never retry a mutation automatically without its idempotency contract.
- Report text-profile success/photo failure separately and preserve retry data.
  A retry should not needlessly repeat an already acknowledged text mutation.
- Distinguish unchanged, set and explicitly cleared optional fields. Confirm
  Moodle clear/null/empty semantics before changing wire serialization.
- Compute exact age using month/day and test all bucket boundaries. Preserve
  current18+ policy; obtain any ambiguous leap-birthday interpretation before
  declaring it authoritative. Do not replace the backend's age bucket with DOB
  or invent a mandatory-field policy without a contract.
- Parse short/malformed legacy phone values without RangeError or silently
  overwriting them. Unicode phone-digit normalization needs server confirmation;
  show an actionable validation state rather than fabricating a number.

Acceptance: reference503 + unrelated edit preserves full original phone;
partial photo failure is honest and retryable; stalled response body releases
the form within its budget; account switch causes zero subsequent wrong-owner
requests; birthday bucket tests pass before/on/after the boundary. Optional
clearing is verified through a confirmed server fixture and read-back.

```sh
flutter test --no-pub --reporter expanded test/profile/profile_integrity_test.dart test/profile/upload_lifecycle_test.dart test/data/profile_serialization_test.dart test/auth/complete_account_info_test.dart
```

### M3. Shared model conversion and stable request lifecycle

Owner: shared-data lane. Findings D01/D03 and conditional short blog tag.

- Correct string/numeric/default conversion order. Test ints, doubles, numeric
  strings, null, invalid/nonfinite input and explicit defaults. Preserve typed
  semantics; do not turn a missing critical ID/grade into a valid-looking value.
- Give FutureBuilderX a retained Future and explicit reload/input identity.
  Callback object identity alone is not a stable request key on rebuild.
  Retry/refresh reloads once; account/course/filter changes invalidate correctly;
  loading/success/error callbacks run once per transition, not on every build.
- Check every caller: completion, profile, Home, lists, tests, course details,
  meetings, articles and certificates. Retain successful data/field entries;
  do not retain accountA cache forB. Avoid nested setState refresh behavior.
- Prevent a one-character blog tag from throwing and dropping the whole article.
  Audit permissive list parsing: preserve missing-result placeholders where
  identity/order matters and surface sanitized partial-data diagnostics.

Acceptance: '11' remains11 and '75.5' remains75.5; unchanged parent rebuild makes
one request, explicit retry makes exactly one new request, changed key fetches
new data, disposed completion cannot invoke UI callbacks. Short/empty tags do
not discard otherwise valid articles.

```sh
flutter test --no-pub --reporter expanded test/core/conversion_test.dart test/ui/future_builder_test.dart test/data/blog_parsing_test.dart
```

### M4. Complete quiz attempt and result integrity

Owner: one quiz lane after M1A/M3. Findings L01-L03/L08-L10 and issue17/18 links.

- Preserve unanswered/null entries and render by stable question slot, never
  index a shortened/reordered answer array as if complete. Missing details get
  an explicit state, without invented correctness or a crash.
- Select answers by position/identifier internally, not display-text indexOf.
  Preserve current wire semantics until index basis/IDs/shuffle are confirmed.
  Duplicate labels and non-Latin labels must remain distinct choices.
- Use an explicit authoritative pass result; 'Not passed' must never match
  'passed'. Obtain actual passed/status/grade payloads; unknown status means
  unresolved, not guessed success or failure.
- Model answer save, timeout, finalization and result loading as one coordinated
  operation with one finalization guard. Confirm server deadline, timelimit0,
  acknowledgement, retry/idempotency and result-attempt identity.
- Never mark _isSubmitted or show final success after explicit endpoint failure.
  On an ambiguous timeout inspect authoritative attempt state before retrying
  finalization. A hanging answer must not create unbounded waiting or double submit.
- Restore authoritative selections/position/time when resuming. Add a recovery
  view if required fields are absent; do not pretend a resumed attempt is fresh.

Acceptance fixtures: zero/one/many questions, unanswered/null/reordered result,
duplicate answers, pass/fail/unknown, saved/resumed attempt, exhausted attempts,
offline during answer, late answer after deadline, double submit and delayed
finalization response. One finalization and one result transition per attempt;
score/correctness agrees with confirmed backend fixtures, not client guesses.

```sh
flutter test --no-pub --reporter expanded test/quiz/answer_identity_test.dart test/quiz/result_integrity_test.dart test/quiz/attempt_lifecycle_test.dart
```

### M5. Learning completion, navigation, statistics and downloads

Owner: learning lane after M1A/M3, quiz acceptance after M4. M1B only gates its
contract/storage-dependent acceptance. L04-L07/L11-L12,
V01, S04, A10 and GitLab17-21. Control binding/empty states can proceed locally
while contract-dependent metric/completion slices wait.

- Bind player controls to actual position/playback notifier; progress/seek/
  play/pause update immediately. Dispose listeners on source change and close.
- Replace wall-clock route dwell with the approved playback completion rule.
  Paused/loading/background time and seeking must follow that documented rule.
  Remove fabricated local persisted success after a failed completion request;
  preserve retry and don't silently disable completion to hide the defect.
- Define course/topic/activity units once from the contract. Cover quiz-only,
  file-only, mixed and empty courses; avoid zero denominators and '2 vs11'
  ambiguity. Empty levels render a valid empty state, never levels.first crash.
- Use authoritative completion acknowledgements, then invalidate Home, MyCourses,
  course lists, detail checkmarks and counters immediately without losing cache
  ownership. Define Next as the next eligible activity or confirmed end state;
  do not assume returning to details satisfies the reported Next requirement.
- Establish the file completion trigger (save/open/explicit), endpoint and module
  ID; do not send file IDs to mark-page-completed without evidence it supports it.
- Learning minutes/durations come from confirmed fields/accounting rules.
  Do not estimate minutes from a 5-second dwell or sum video lengths as learning.
- Unlocking stays backend-authoritative. Fix map(predicate).isEmpty only after
  confirming what client fallback, if any, is permitted.
- Display actual assessment grades, or obtain approval to relabel progress;
  completionPercent must not silently stand in for a grade.
- Download policy: confirmed HTTPS origins and redirect/auth behavior, response
  MIME/size/time budgets, cancellation and safe filenames/Content-Disposition.
  Enforce size while streaming even without Content-Length; scope partial-file
  cleanup to the current download. Reject path traversal in filenames and never
  forward credentials to an unapproved redirect origin. Verify valid CDN cases.
  Do not save a200 HTML sign-in page as a document. Retain legitimate authorized
  media; remove broad ATS allowances only after equivalent flows work.
- Preserve the earlier Android storage-permission fix; test app documents,
  save/open, offline/partial download, expired URLs, denial and Arabic filenames.

Acceptance: real playback controls react; failed completion/download never shows
persisted success; successful lesson/quiz/file completion updates all surfaces;
quiz-only entry1/1 and count/minute fixtures match backend definitions; Next and
unlock follow approved order; empty account safe; downloads obey bounded policy.

```sh
flutter test --no-pub --reporter expanded test/learning/player_controls_test.dart test/learning/progression_test.dart test/learning/statistics_test.dart test/download/download_policy_test.dart
```

### M6. Remaining app flows, calendar and localization

Owner: app-flows lane. Findings A01/A03-A06 and minor inventory X01-X06 below.

- Give calendar->meeting navigation one typed contract. Resolve the actual
  calendar/meeting ID mapping before inventing a lookup or passing event.id to
  a MeetingX-only controller. Test both calendar and meeting-list entry.
- Meeting start is not end. Confirm end/status/timezone semantics before the
  Join visibility change. Cover upcoming/live/ended and boundary instants.
- Funnel date picker, day taps and week arrows through one selection/filter
  operation; cover midnight/noon and local/server timezone conversions.
- Validate repeat intervals/counts against the event contract, with positive
  values when repetition is enabled. Successful deletion removes the record,
  closes its stale detail and refreshes calendar; failed deletion retains it.
- Compute unread count at Back time or invalidate/refetch, not a captured0.
  Mark-one/all changes only after acknowledgement; failure preserves unread.
- Migrate UI locale ph->fil with stored-preference mapping and separate backend
  language mapping if required. Test dates in ar/en/es/fil; use current locale
  for blog dates and correct12PM/12AM. Preserve Latin digits in Arabic output.
- Verify human-name Unicode/Spanish-accent expectations with backend validation;
  align old-password/login length handling with documented legacy policy rather
  than choosing a new password rule. Keep the earlier old-password relaxation.
- Sweep translated errors/empty/loading states, RTL, text scaling/keyboard,
  VoiceOver/TalkBack focus and meaningful labels for changed components. Record
  broader accessibility behavior as verified or open, not presumed compliant.

Acceptance: calendar and meeting entries reach correct record; selected day
matches its events; Join state matches contract; notifications return accurate
count; delete/failure/repeat cases behave; all four languages open dated screens
without locale errors and retain input/focus. Public-name/password-policy tests
use backend-approved fixtures, not an invented validation rewrite.

```sh
flutter test --no-pub --reporter expanded test/calendar/calendar_meeting_test.dart test/notifications/unread_state_test.dart test/localization/locale_migration_test.dart test/profile/input_policy_test.dart
```

### M7. Bounded lists, network cost and decoding

Owner: performance lane after M3; independent screens can run beside M4-M6.
Findings P01-P03 and all shared list counterparts.

- Fetch/present the first blog page immediately; load later pages on demand,
  correct final-page detection, deduplicate and support retry without discarding
  loaded records. Do not recursively fetch all1000 articles before first paint.
- Use builder/sliver lists and bounded image work for leaderboard, then audit
  blog/notifications/courses/certificates for the same eager pattern.
- Verify backend pagination/limit/cursor before claiming bounded retrieval for
  endpoints that currently return full lists. Client virtualization alone does
  not reduce server response size.
- Paginate first, then measure decode AND mapping in profile mode on device.
  Move sufficiently large work to an isolate with a tested threshold; account
  for transfer/memory cost. Host17.8MB synthetic results are not iPhone jank proof.
- Benchmark fixed viewport/fixtures at0/1/20/100/1000 records, cold/warm paths,
  initial requests, mounted rows/images, memory, p50/p95 and frame trace. Judge
  growth beyond today's data; document unsupported backend load conclusions.

Acceptance: initial archive fetch is one page (no101-call chain for1000 records),
initial mounted images scale with viewport+cache rather than list length, no
duplicate page on rebuild, and bounded-memory cancellation/error behavior.
Set device timing/frame budgets from a measured baseline before claiming gains.

```sh
flutter test --no-pub --reporter expanded test/performance/pagination_test.dart test/performance/list_mount_test.dart test/performance/response_decode_test.dart
```

### M8. Platform acceptance, clean gates and issue closure

Owner: integration/QA after completed slices, coordinated backend owner as needed.

- Resolve the6 existing analyzer infos in their owning layers: remove sensitive/
  unnecessary model prints in M1A, migrate radio APIs with interaction checks, preserve
  opacity/color behavior using supported Flutter APIs. No blanket ignore rules.
  Then make CI's analyzer strict instead of leaving --no-fatal-infos as final gate.
- Run a clean checkout with the approved lock/toolchain; actual GitLab runner
  checks, tests, native iOS/Android builds. Preserve offline tests and fail on
  leaked credentials/log payloads. No CI-green claim before the remote run.
- Test minimum supported and current supported OS versions on both platforms,
  plus representative physical-device media/download/background behavior.
  Native plugin/camera/photo permissions and secure storage require device proof.
- Exercise account lifecycle, edit/clear/photo, all quiz/progression states,
  downloads, events/meetings, notifications, complaints and all languages.
  Include offline, slow/empty/malformed response, expired token, repeat taps,
  Back/close/background and account replacement at each async boundary.
- Prefer staging/test account with resettable course/attempt fixtures. Existing
  personal-account authorization is not a fabricated rollback mechanism for
  permanent grades/progress. Confirm specific irreversible scenarios and their
  reset/rollback route before executing them; keep safe reads announced.
- Never close GitLab16-22 from unit/source/build evidence alone. Record expected
  behavior, observed post-change result, build/commit, platform and backend
  fixture. GitLab writes, remote push and any deployment need their own scope.
- Update PARITY-LEDGER with every unverified platform/backend/web counterpart.
  Deployment decision, remaining gaps and rollback are presented separately.

Acceptance: no open actionable defect in this plan without an explicit owner
decision/blocked-contract label; all issue acceptance scenarios observed;
strict analyzer and tests green, actual CI green, declared native matrix passed.
Any outstanding contract or device gap prevents 'everything works' or release-
ready language. This is a closure criterion, not a promise of defect-free code.

```sh
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
flutter build ios --simulator --debug --no-pub
flutter build apk --debug --no-pub
```

## 5. Exhaustive finding-to-milestone ledger

Evidence: R=reproduced locally in audit; S=source finding; C=contract-dependent;
V=verification gap. 'Ready' means can be specified/tested locally after plan
approval, not that a fix is already implemented. Priority is repair order, not
proof of backend compromise. References use original audit IDs.

| ID | Remaining item | Evidence | Owner milestone / prerequisite |
| --- | --- | --- | --- |
| S01 | Bundled shared credential/rotation | S,C | M1 backend public boundary/ACL and owner-authorized replacement |
| S02 | Protected-token fallback; tokenless login | R,C | M1 local token requirement + public/verification contract |
| S03 | Plaintext token/legacy residual bytes | R | M1 storage/migration decision and platform proof |
| S04 | Unbounded/unrestricted downloader, ATS | S,C | M5 origins/auth/MIME/size and native tests |
| D01 | Numeric strings become defaults | R | M3 ready |
| D02 | Dynamic extension dispatch suspicion | Excluded | No active receiver established; regression/caveat, not open app bug |
| D03 | FutureBuilder refetches on rebuild | R | M3 ready; completion-specific cache already repaired |
| L01 | Dropped/unordered unanswered results | R,S | M4 ready for safe slot/null handling |
| L02 | 'Not passed' recognized as pass | R,C | M4 safe explicit parsing + authoritative status fixtures |
| L03 | Finalization status bypass/false submitted | S,C | M4 endpoint acknowledgement/idempotence |
| L04 | Route dwell/fabricated completion | S,C | M5 acknowledgement fix + approved playback rule |
| L05 | File completion/checkmark missing | S,C | M5 resource endpoint/trigger |
| L06 | Incompatible totals/zero denominator | S,C | M5 unit definitions |
| L07 | Stale originating progress screens | S | M5 ready once authoritative success is identified |
| L08 | Duplicate answer labels select first | S,C | M4 local identity fix; preserve confirmed wire mapping |
| L09 | Resume loses choices/position | S,C | M4 authoritative attempt payload |
| L10 | Timeout versus answer-save race | S,C | M4 state coordination + deadline/idempotency |
| L11 | Unlock predicate checks list length | S,C | M5 policy/authority before behavior change |
| L12 | Home crashes on empty levels | S | M5 ready |
| A01 | Calendar passes ID where MeetingX expected | S,C | M6 typed route + authoritative ID mapping |
| A02 | Unconfirmed login lacks userid | S,C | M1 verification contract; never send empty ID |
| A03 | Invalid Filipino date locale | R,C | M6 UI migration; backend language mapping |
| A04 | Join hidden when meeting starts | S,C | M6 end/status contract |
| A05 | Date picker does not filter events | S | M6 ready |
| A06 | Stale unread badge on Back | S | M6 ready; mutation acknowledgement verified |
| A07 | Optional clear is omitted | S,C | M2 clear/omit contract |
| A08 | Avatar failure reported as full success | S | M2 EditProfile open; completion local fix retained |
| A09 | Age bucket before birthday wrong | R,S | M2 ready; ambiguous policy boundaries require decision |
| A10 | Completion shown as grade | S,C | M5 real grade field or approved relabel |
| B01 | Import filename case | Source fixed,V | M0/M8 Linux CI acceptance, retain regression |
| P01 | Whole blog archive before display | R | M7 ready, pagination interface verified |
| P02 | Eager offscreen rows/images | R,S | M7 ready, sweep counterparts |
| P03 | Large decode on UI isolate | R,C | M7 device measurement/threshold; no claimed current device jank |
| U01, U02, U03 | Urgent Toast/form/reset repairs | Local fixed,V | M8 account/native acceptance, retain45 baseline tests |
| H01 | Empty failed HTTP treated as success | Local fixed,V | M8 endpoint/native controls |
| H02 | No expired-session recovery | R,C | M1 confirmed auth errors |
| H03 | Upload timeout misses response body | R | M2 ready |
| F01 | Failed phone-code list changes phone | R | M2 ready |
| V01 | Player controls ignore notifier | R | M5 ready |
| C01 | Abandoned forgot screen routes later | Local fixed | Retain auth lifetime regressions; sweep counterparts M1 |
| C02 | Old profile upload uses next account | R | M1 shared ownership, M2 integration |
| I01 | Short malformed stored phone throws | R,conditional | M2 defensive parsing; no claim real accounts malformed |
| I02 | One-character blog tag drops article | R,conditional | M3 safe tag handling |
| I03 | Country-code serialization gated by howFoundUs | Inactive,C | M2 serializer characterization; current callers nonnull, no fabricated active bug |
| I04 | Arabic digits accepted but not normalized | C | M2 confirmed server normalization policy |
| X01 | Noon labelled AM in event views | S | M6 shared formatting, not the refuted time-picker suspicion |
| X02 | Blog dates hardcode Arabic | S | M6 current locale |
| X03 | Old-password/login minimum differs | S,C | M6 legacy policy; do not undo issue22 fix |
| X04 | Supported Spanish names reject accents | S,C | M6 confirmed name policy |
| X05 | Repeat accepts invalid count/interval | S,C | M6 event contract and conditional validation |
| X06 | Deleted event detail stays visible | S | M6 acknowledged delete/invalidation |
| Q01 | Original lock/package config stale | V | M0 owner review of foreign lock; no overwrites |
| Q02 | Build needs ad-hoc iOS target override | V | M0 supported OS/toolchain decision |
| Q03 | Remote CI and Android/device flows unrun | V | M8 authorization/runner/device matrix |
| Q04 | Six analyzer infos | S | M8 owning-layer fixes, strict final gate |

Excluded suspicions: unused permissive HttpOverrides is not active TLS bypass;
time picker correctly displays noon/decrements; Ahem overflow was a test-host
artifact; multi-attempt multipart retry/cache poisoning has no active configured
caller. Characterize/reassess only if those features become active. Do not pad
the defect count or repair list with these rejected allegations.

## 6. GitLab acceptance map

| Issue | Owning work | Required post-change observation |
| --- | --- | --- |
| 16 | M2/M8 | Future/under18 blocked; chosen DOB and serialized age bucket correct before/on birthday |
| 17 | M4/M5/M8 | Identify reported screen; pass entry quiz, confirm finalization/result/completion, return and see1/1 |
| 18 | M3/M4/M5/M8 | Confirm11-unit definition; file checkmark; lesson2 known-answer fixture scored correctly; durations/minutes as contracted |
| 19 | M5/backend/M8 | Known learning event changes authoritative minutes by agreed rule; app shows updated total |
| 20 | M5/M8 | Checkmark/unlock/Next immediate on success across screens; failed request preserves retry without false completion |
| 21 | M5/M8 | Authorized file save/open on supported iOS/Android without unnecessary permission block; error/Arabic filename cases |
| 22 | M6/M8 | Arabic complaint and mark-all success, correct failure feedback, valid legacy old password accepted by agreed policy |

U03's local repair does not establish which server stage rejected Saker's earlier
password attempt. Preserve a sanitized stage/error code in an authorized repro;
never capture password/OTP/token/raw authenticated URL in test or support logs.

## 7. Backend handoffs and decisions before dependent slices

Use BACKEND-CONTRACT-REQUEST.md, updated against current fixes at implementation
time. Required outputs are sanitized schemas/success/error fixtures and explicit
rules, not raw production credentials or a guess based on endpoint names.

1. Public auth/ACL, user-token requirements, unconfirmed userid/token flow,
   expiry codes, logout/revocation and service-key replacement/rotation route.
2. Reset acknowledgement, OTP consumption/expiry/rate limiting/replay and the
   original failure stage. New app intentionally does not auto-login after reset.
3. Required profile/custom enums, clear semantics, phone digits, upload limits,
   legacy passwords/names and age-policy ambiguities. Completion now defaults
   'male', matching existing radio values; old 'Male' is historical, not current.
4. Quiz answer mapping, question types, result slots/pass statuses, attempt ID,
   deadline/resume/finalization/idempotency and grading fixture.
5. Course/topic/activity units, progression/unlocking/Next, file endpoint,
   playback completion and authoritative minute/duration accounting.
6. Download origins/auth/redirect/MIME/size; event/meeting ID/status/timezone and
   repeat policy; notification mark-all sentinel; available list pagination.

Owner decisions before changing existing data/platform support: secure-session
migration or forced sign-in, supported minimum iOS/toolchain, protected foreign
lock delta, any dependency addition/upgrade, grade relabel if no grade endpoint,
and authorized resettable account/fixture for irreversible QA. Other local
mechanical/correctness slices can proceed after plan approval while these wait.

## 8. Completion evidence and rollback

Per slice record: finding IDs, failing baseline, exact request/state expectation,
fix commit, passing test count, review stamp, observed platform behavior, backend
fixture version and open counterpart. Mark 'local fixed / device pending' where
appropriate. A missing backend answer stays BLOCKED-CONTRACT, not DONE.

Use mock/intercepted endpoints and synthetic session identities for automated
tests; assertions/logs must redact token-bearing URLs and request bodies. Never
print Request objects or repeat the embedded credential. Keep real identities,
screenshots and OTPs outside git. Persist tests/fixtures safely, not only /tmp
probes. Store secrets only in ignored environment/OS-secure storage as applicable.

Scope each revert independently. Keep native target/lock changes separate from
behavior repairs. State/data migration rollback must be designed before rollout,
with no downgrade to plaintext credentials. Do not auto-retry submitted grades
or permanent progress as if they were harmless reads. Production actions require
their own reviewed change, explicit current authorization and reversible plan.

Deliverables: complete finding ledger, tested commits, confirmed API fixtures,
native/platform acceptance evidence, strict green CI, updated parity ledger and
explicit unresolved owner decisions. Final release decision is separate.

Planning method: engineering:testing-strategy applied to the acceptance design;
fresh read-only plan review completed with no blockers. Its M5 dependency
clarification was applied: local work depends on M1A, not all of M1B. Review
covered document/source consistency, not new runtime/server verification.
No external-library
selection or new current-version recommendation was made in this source-based
plan, so external comparative research is not applicable here. Verify actual
SDK/package docs, changelogs and security/licensing before any approved upgrade.
