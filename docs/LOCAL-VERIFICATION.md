# Local audit reproduction

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

## Outstanding runtime verification

Account sign-in, course/quiz grading and progression, file save/open, complete
profile/notification/calendar scenarios, Android/device behavior and backend
contracts remain open. All corrections described in the report are proposals.
