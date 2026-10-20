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
