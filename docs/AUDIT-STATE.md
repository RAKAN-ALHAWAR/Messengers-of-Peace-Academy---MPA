# Mopa audit state

Updated: 2026-10-18 (Asia/Damascus).

## Authorized scope

Run the existing Flutter application on an iPhone simulator, explore its code,
analyze GitLab issues 16 through 22, and audit the rest of the application for
defects before preparing corrections. Saker authorized using his own account for
testing in this session. He will enter any credentials directly in the simulator.
No server edits, deployment, credential rotation, GitLab writes, or remote push
are authorized by this audit.

Latest user direction (2026-10-17): defer interactive simulator access and
continue analyzing the code itself. The backend source is not available to
Saker; he may supply an API description later. Do not request simulator access
again during this source-analysis pass. No product implementation is approved
by this direction; produce verified findings and a backend-contract checklist.

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

Next: review proposed frontend fixes, then implement with regression tests in
an isolated lane. Backend-dependent semantics remain open; concrete requested
contracts are in BACKEND-CONTRACT-REQUEST.md. No product fix, upgrade or remote
push has occurred in this analysis pass.

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
