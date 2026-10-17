# Urgent repair ledger

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

- Approved repair scope recorded; no application code edited yet.
- Next: introduce tested Toast presenter, implement auth lane, add visible
  completion validation, review combined diff and verify local application build.
