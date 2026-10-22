# Local audit reproduction

## Continuation checkpoint2026-10-22

Current execution lives in EXECUTION-2026-10-20.md. Original audit evidence below
is historical. Root worktree /private/tmp/mopa-urgent-fixes-20261018 uses pinned
Flutter3.41.6/db50e20168 (Dart3.11.4), with exact APFS validation copies when an
engine download holds the primary cache lock. No global SDK was changed.

Observed combined source gate at7868801:

```sh
/private/tmp/mopa-validation-sdk-3.41.6/bin/flutter test --no-pub
/private/tmp/mopa-validation-sdk-3.41.6/bin/flutter analyze --no-pub
```

520/520 tests passed; strict analyzer reported no issues. Logs are
/private/tmp/mopa-full-20261022-v3.log and
/private/tmp/mopa-entry-clean-analyze.log. This checkpoint includes level track
and entry/route refresh, and precedes the catalog/history counterpart slice.
An earlier run447pass/8fail exposed the new accessibility test's non-scrollable
host at scale3; correcting its host did not suppress app rendering errors.

Current native build command completed with explicit exit0 at6e6ae2f:

```sh
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/mopa-remediation-derived-20261022 ARCHS=arm64 ONLY_ACTIVE_ARCH=YES IPHONEOS_DEPLOYMENT_TARGET=15.0 CODE_SIGNING_ALLOWED=NO -quiet build
```

Log: /private/tmp/mopa-remediation-ios-arm64-20261022.log. Xcode27.1; simulator
arm64 build only, existing plugin warnings remain. No minimum-OS source change,
installation, launch or interactive/account QA. The prior generic universal
attempt failed Flutter's architecture unpack check, documented in execution.

Independent scoped reviews replayed mounted progress, uncertain-answer recovery,
notification mutation races, owned caches, full-font lazy lists and shared button
geometry/state callbacks. Carousel preparation at1000 records is still O(N):
host-debug31-sample p50/p95=15.036/16.786ms,2 mounted cards. Native profile-mode
decode/mapping/frame budgets and backend query/storage growth are unverified.

Android debug verification at7868801 completed exit0 in19.6s after its initial
cache-building527.2s attempt. Command and artifact (isolated checkout):

```sh
/private/tmp/mopa-validation-sdk-3.41.6/bin/flutter build apk --debug --no-pub
```

Worktree /private/tmp/mopa-native-20261022. Artifact:
build/app/outputs/flutter-apk/app-debug.apk (debug/unoptimized,157MB in the first
build). Log /private/tmp/mopa-android-final-20261022.log. Kotlin daemon fallback
and Android SDK XML warnings are retained; no toolchain upgrade, license
acceptance, emulator install or Android runtime scenario is claimed.

This is observed audit evidence, not a passing release checklist. Commands below
refer to the isolated checkout used on 2026-10-17. They do not modify servers.

## Baseline and original changes

- Source commit: `f338fa951b6d333b0057dc4253ca749922de33dd`.
- Original modified `pubspec.lock` SHA-256 before final documentation delivery:
  `9ad24bce6ed2b390ee55772a69c51798d36c313c016841a36c44fa24941ad9c7`.
- No application source files were edited. Generated native/package lock changes
  are isolated and not part of the documentation commit.

## Package and analyzer checks

Run in `/private/tmp/mopa-audit-20261017`:

```sh
flutter pub get
flutter analyze --no-pub
```

Pub added the missing open-file packages. Analyzer completed with 6 informational
findings and exit 1: two print calls, two deprecated Radio properties and two
deprecated opacity calls. There were no remaining compiler errors or warnings.

## iPhone build and launch

Ordinary run failed because the installed Xcode rejects old deployment targets:

```sh
flutter run --no-pub -d 1C4C054D-0C46-4762-8328-0B3E72617A48
```

This simulator-only command completed with exit 0. It does not adopt a new
minimum OS version for the shipped product:

```sh
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination id=1C4C054D-0C46-4762-8328-0B3E72617A48 -derivedDataPath /private/tmp/mopa-audit-derived IPHONEOS_DEPLOYMENT_TARGET=15.0 CODE_SIGNING_ALLOWED=NO -quiet build
```

Installation and launch both succeeded:

```sh
xcrun simctl install 1C4C054D-0C46-4762-8328-0B3E72617A48 /private/tmp/mopa-audit-derived/Build/Products/Debug-iphonesimulator/Runner.app
xcrun simctl launch 1C4C054D-0C46-4762-8328-0B3E72617A48 com.messengersofpeace.rakanalhawar
```

Screenshot `/private/tmp/mopa-launch-20261017.png` shows the Arabic login screen.
An image alone is not authenticated end-to-end verification.

The conventional Simulator.app was not present in this Xcode installation.
This existing application was located and launched, and Saker confirmed its
window became visible:

```sh
open /Applications/Xcode.app/Contents/Applications/DeviceHub.app
```

Computer Use returned `Computer Use was not approved to use Device Hub`.
No alternative input mechanism was used to bypass that restriction.

## Behavior probes

```sh
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/behavior_test.dart
```

Completed result: `00:00 +0 -7: Some tests failed.` All seven expectations failed
on the baseline. Six are application-behavior probes. The seventh is a standalone
Dart dynamic-dispatch demonstration with no active app call site established.
See the audit report for expected and actual values. These were intentionally
kept outside the repository's product test suite.

## Performance probes

```sh
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/performance_test.dart
```

Main-agent verification completed: `00:02 +4: All tests passed!` The tests check
current request/mount counts and report synthetic decode timings; passing them
does not establish acceptable product performance.

HTTP calls were intercepted through `http.runWithClient(MockClient(...))`.
A separate temporary Hive box used a synthetic token. Measurements: 21 warm
decode samples per payload; 800x600 leaderboard viewport without scrolling.

## Session/storage observations

Seven checks of actual endpoint/Hive logic with synthetic substitutes completed:

```text
PASS protected profile endpoint uses service credential without session
PASS persisted userid with missing token still uses service credential
PASS normal authenticated profile uses user credential
PASS endpoint getter sees changed user credential
PASS stored token is recoverable from plaintext Hive file bytes
PASS default token write has no local expiry
PASS logical token deletion leaves token bytes in Hive file
SUMMARY: 7 synthetic local checks passed, no network, no real credentials
```

The probe replaced the embedded credential with a sentinel before copying class
definitions into scratch. No real credential was exercised. An initial rerun
failed because its parent scratch folder was absent; it was created and the
reported completed verification above was run afresh.

## Source follow-up completed 2026-10-18

All commands below ran in the isolated audit checkout using synthetic Hive data
and intercepted HTTP. Passing observation tests assert existing defects, not
successful repairs. Application source and original lockfile were unchanged.

```sh
flutter test --no-pub --reporter expanded /private/tmp/mopa-security-http-probes/http_session_test.dart
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/source_followup_test.dart
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/lifecycle_app_test.dart
flutter test --no-pub --reporter expanded /private/tmp/mopa-audit-probes/toast_back_actual_app_test.dart /private/tmp/mopa-audit-probes/symptoms_controller_test.dart
flutter test --no-pub --reporter expanded --timeout 20s /private/tmp/mopa-security-http-probes/cross_session_profile_test.dart
```

Main independently completed all five commands:8,8,2,3,1 passing tests,
respectively. Details and exclusions: `SOURCE-FOLLOWUP-2026-10-18.md`.
Actual-MyApp urgent reproduction:

```text
CAPTURED FlutterError: No Overlay widget found.
TOAST route=/probe snackbarOpen=true visible=0
CAPTURED LateError: LateInitializationError: Field '_controller' has not been initialized.
AFTER_BACK route=/probe snackbarOpen=true errors=2
RESET_STAGES=[reset-success, login-failure] route=/reset state=failed loading=false
COMPLETE calls=0 loading=false state=normal countryToast=1
00:00 +3: All tests passed!
```

The randomized private field suffix is omitted. Controller-only probes add an
outer Overlay to isolate the controller path; actual-MyApp reproduction does
not add one. The current live reset error/stage remains unknown.

## Outstanding interactive verification

The user completed sign-in directly; a fresh screenshot shows authenticated
Home. Computer Use still denies Device Hub access. Course/quiz grading and
progression, file save/open, profile/notification/calendar scenarios, Android
runtime and backend contracts remain open. Earlier observations were baseline;
the urgent repairs below supersede their corresponding proposal-only status.

## Urgent repair verification, 2026-10-18

Final integrated suite in /private/tmp/mopa-urgent-fixes-20261018:

```sh
flutter test --no-pub --reporter expanded
flutter analyze --no-pub --no-fatal-infos
```

Main's completed summary: `00:02 +45: All tests passed!`. Independent reviewer
also completed45 tests in isolation. Analyzer exit0 with6 pre-existing infos,
0 errors/warnings; default analyzer still exits1 for infos. No lint suppression.
Final auth tests have no outer Overlay workaround. Actual MyApp tests verify
Toast/Back gestures; completion tests mount actual view/controller. All test
requests intercepted, with synthetic identities/session/files only.

Simulator build completed exit0, with existing CocoaPods/plugin warnings:

```sh
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination id=1C4C054D-0C46-4762-8328-0B3E72617A48 -derivedDataPath /private/tmp/mopa-urgent-derived IPHONEOS_DEPLOYMENT_TARGET=15.0 CODE_SIGNING_ALLOWED=NO -quiet build
```

Installed without uninstall/data clearing; launch returned PID75639. Product
deployment targets unchanged. /private/tmp/mopa-toast-ar.png is an inspected
widget render using synthetic screen content and real Arabic/Material icon
fonts, not a device screenshot. Device/account scenarios and remote CI remain
unverified. Scope, review and remaining defects: FIX-STATE.md.
