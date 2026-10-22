# Urgent repair ledger

## Continuation checkpoint2026-10-22

The urgent batch below is historical. Approved comprehensive remediation now
continues in codex/mopa-remediation-20261020, isolated from original main.
Current ownership, exact local evidence and remaining work are in
EXECUTION-2026-10-20.md; contract/platform gaps remain in REMEDIATION-PLAN and
PARITY-LEDGER. The original foreign pubspec.lock is excluded and unchanged.
Do not infer live/server/device/CI acceptance from host tests or native builds.

Updated: 2026-10-18. Authorization: Saker's 'طيب ابداء بالاصلاح', following
the three diagnosed symptom groups. Backend source remains unavailable.

## Contract and acceptance

1. Shared Toast presentation: preserve current top position, colors, translations,
   icon and dismiss affordance. Use the root Navigator's actual OverlayState,
   own bounded notification lifetime, and dismiss without navigation. Repeated
   errors, success/info, timeout, explicit dismissal and Back during a message
   must work. No dependency upgrade or new UI design.
2. CompleteAccountInfo: preserve existing required-field policy; give visible
   field errors for semantic selections and DOB, scroll to first invalid field,
   send no request for invalid input, retain user entries after failure. Extend
   shared DropdownX with optional FormField validation without changing existing
   optional callers. Keep reference-data future stable during form rebuilds.
3. Password reset: distinguish accepted reset from sign-in. After an acknowledged
   reset, show success and return to sign-in rather than repeating reset if an
   automatic login/profile request fails. Preserve exact request fields/password
   policy, prevent double submission, ignore abandoned continuations. HTTP error
   statuses must be rejected even with empty bodies before accepting a reset.

All requests in automated checks are intercepted with synthetic data. Do not
exercise bundled service credentials. No live password reset/account edits,
production changes, remote writes or deployment are part of implementation.

## Coordination

- Main: codex/mopa-urgent-fixes-20261018, worktree
  /private/tmp/mopa-urgent-fixes-20261018. Owns Toast presenter/adapter, completion
  controller/view, shared validation widgets, translations, tests, CI and docs.
- Auth worker: codex/mopa-password-fix-20261018, worktree
  /private/tmp/mopa-password-fix-20261018. Owns ForgotPassword and
  ForgotPasswordReset controllers, HTTP response status handling, and matching
  tests only. No translation/shared widget edits. Main integrates after review.
- A fresh read-only security/correctness reviewer checks the merged batch before
  original-checkout integration. Separate branches and synthetic test resources.
- Original modified pubspec.lock is foreign and must remain byte-identical.

## Verification commands

```sh
flutter test --no-pub --reporter expanded
flutter analyze --no-pub
```

Required observations: original reproductions fail their old defect assertions
and new regression expectations pass; read completed test count. Build iOS with
the already verified simulator-only target override. Interactive Device Hub
control remains deliberately deferred, so local widget/build evidence must not
be presented as device end-to-end or server verification. CI remote execution
cannot be claimed without a remote run; configure checks for the actual host.

## Progress

- Toast/Back: replacement implemented with one owned OverlayEntry/timer. Error,
  success and info render under actual MyApp; real Back arrow pops while a
  message remains visible, and close/timeout never pop the page. Top messages
  sit below the toolbar so their pointer area does not cover Back. Repeated
  messages replace the old one; missing/disposed overlay is safe.
- Fresh regression run: test/ui/toast_navigation_test.dart, 3 passed. Baseline
  run before replacement: 1 passed/2 failed, including the original Overlay
  exception. A first replacement's notification covered Back physically;
  moving below the toolbar fixed that additional failed gesture assertion.
- Expanded notification run:4 passed, additionally proving a superseded timer
  cannot dismiss the new message and swipe dismissal never pops the page.
  Fresh read-only reviewer independently repeated the initial3 tests with no
  blockers. Arabic visual snapshot rendered with bundled text/Material icon
  fonts at /private/tmp/mopa-toast-ar.png and inspected; its screen content is
  synthetic, not device/account evidence. One visual probe passed. First render
  lacked loaded Material icon fonts in the test host; fixed only in the harness.
- Analyzer: 0 errors/warnings, 6 existing informational findings; default exits1.
  No claim of clean analyzer or completed device scenario yet.
- Auth/completion lanes integrated after inspecting actual diffs. Original
  lockfile remains protected. No live requests, upgrades or remote changes.
- During a baseline auth-test failure, a Request assertion exposed the existing
  bundled service credential again in local logs. The assertion was changed to
  compare counts only. Value omitted; owner-coordinated removal/rotation remains
  OPEN, not performed or claimed fixed by this batch.
- Auth acceptance: HTTP12 + controller10 tests passed independently after merge.
  An accepted reset makes one request, preserves session data and returns to
  sign-in. Rejection permits retry; duplicate and closed-screen work is ignored.
  Final auth host no longer includes the old outer-Overlay isolation workaround;
  its10 tests passed again using the repaired Toast transport directly.
- Completion acceptance:15 completion +4 shared validation tests, all included
  in main's completed45-test suite. Empty choices and DOB show inline errors;
  first invalid field is revealed; entries/reference data survive rebuild and
  request failure; conditional fields, retry and session ownership are covered.
  Separate baseline failures: missing language error, and expected3 reference
  calls versus9 after rebuild. No backend-required-field policy was invented.
- Read-only fresh security/correctness review: no blockers in
  cc92b52..bfe8fa2; reviewer independently ran45 tests and analyzer with6 existing
  infos. Its one hygiene finding (CRLF dropdown added-line whitespace) was fixed
  by LF normalization. Final test-host cleanup is test-only, no product change.
- iOS simulator build completed exit0 with the previously verified command-line
  IPHONEOS_DEPLOYMENT_TARGET=15.0 / CODE_SIGNING_ALLOWED=NO override. Product
  deployment-target files were not changed. CocoaPods/plugin warnings remain;
  not a clean-warning or device-flow claim. Log: /private/tmp/mopa-urgent-build.log.
- Agents used separate worktrees and inherited parent model settings, without
  overrides. House-named Sonnet/Opus variants were unavailable to the runtime.
  Handoffs: /private/tmp/mopa-auth-handoff.md and
  /private/tmp/mopa-completion-handoff.md. Their tests were independently rerun.
- Final integrated run after removing auth outer-Overlay scaffolding:45 passed
  (/private/tmp/mopa-urgent-final-tests.log). Diff whitespace check passes.
- Updated simulator app installed without uninstalling or clearing account data;
  launch succeeded, PID75639 on iPhone17Pro/iOS26.5 UUID
  1C4C054D-0C46-4762-8328-0B3E72617A48. Launch announced because startup can
  fetch account data. Process evidence only, not a form/account interaction pass.
  Rollback build: /private/tmp/mopa-audit-derived/Build/Products/Debug-iphonesimulator/Runner.app.
- Integrated by fast-forward into original main at31a6cfe after final review.
  Original pubspec.lock SHA256 remains
  9ad24bce6ed2b390ee55772a69c51798d36c313c016841a36c44fa24941ad9c7;
  it is the only pre-existing original-checkout modification. No push.
- Reviewer rechecked the sole hygiene finding and test-host cleanup: resolved,
  no introduced findings, final stamp cc92b52..31a6cfe. Simulator process75639
  remained present in launchctl with exit-status0 after launch.
- Package resolution/build/testing occurred in the isolated worktree. Original
  ignored package configuration is stale and its foreign lock lacks open_file;
  it was deliberately not rewritten. Run the recorded checks in the resolved
  worktree, or perform a normal dependency resolution when the owner is ready to
  update that lock. This is not a source/compiler failure introduced by repairs.

## Remaining audit work

Full proposed sequence and finding-to-acceptance mapping now lives in
REMEDIATION-PLAN-2026-10-18.md. It was requested for review, not adopted as new
implementation authority. This file remains the evidence ledger for repairs.

First urgent batch, not completion of the full-project audit. Quiz/result
parsing, video/progress, broader session recovery, EditProfile ownership and
reference-data defects and list cost remain open in the audit reports.
Backend minutes/completion/unlocking/grading/token ACL need the real contract.
Interactive device/account flows and remote CI remain unverified.

## Retrospective

Worked: baseline failures became committed regressions;45 pass after integration.
Correction: removed old Overlay test workaround; normalized CRLF patches and
replaced Request-object assertions that exposed credential-bearing URLs.
Open: backend contracts, interactive platforms, CI and credential rotation;
no remote writes/deployment performed.

### CI preparation

The project remote is GitLab, so `.gitlab-ci.yml` runs the analyzer (existing
infos remain visible/nonfatal) and all tests. It bootstraps official Flutter
tag3.41.6 and verifies the exact installed SDK commit. No deploy credentials or
deployment job. Three source URI case mismatches were corrected for Linux;
two touched CRLF files were normalized to LF for whitespace-clean patches.
CI has not run remotely; no push is authorized, and local Docker daemon is not
running. Do not claim green CI or verified runner configuration.

Source verification used the deep-research skill for the narrow CI-source
check. Primary references: https://docs.gitlab.com/ci/yaml/ (pipeline syntax)
and https://github.com/cirruslabs/docker-images-flutter (rejected image source:
maintainer says updates stop May1,2026). No comparative tool research/adoption
claim. Official SDK source: https://github.com/flutter/flutter/tree/3.41.6.
