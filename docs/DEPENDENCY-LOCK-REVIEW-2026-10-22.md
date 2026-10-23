# Protected lock review

Status update2026-10-23: owner explicitly approved regenerating the matching
tested Dart/native lock resolution after backup/review/verification, and iOS15
as the supported minimum. Implementation is in the durable managed closeout
worktree; original main adoption remains gated on verification/review. The
comparison/options below record the prior proposal; no package-upgrade approval
is implied. Backup originals and SHA manifest:
/Users/saker/.codex/backups/mopa-20261023-locks.

Original checkout's foreign pubspec.lock SHA256 is
9ad24bce6ed2b390ee55772a69c51798d36c313c016841a36c44fa24941ad9c7.
It remains the only original-checkout modification after local integration.
The source already declares open_file; the resolved isolated lock includes its
platform implementations. No existing package version differs between these
two files. This is not the same comparison as git diff against the older tracked
lock, which can include other already-foreign changes.

Measured2026-10-22: original foreign lock131 packages, isolated resolved lock139.

The complete non-version delta also changes flutter_inappwebview from direct
main to transitive, consistent with the current pubspec declarations. The
generated SDK constraints change from Dart>=3.9.0-0 / Flutter>=3.29.0 to
Dart>=3.11.0 / Flutter>=3.41.0. Adopting this lock therefore records the higher
resolved SDK floor even though the existing package versions do not change.
The pinned verification toolchain is Flutter3.41.6 / Dart3.11.4. No older SDK
compatibility is claimed by these checks.

| Added resolution | Version |
| --- | --- |
| open_file | 3.5.11 |
| open_file_android | 1.1.0 |
| open_file_ios | 1.1.0 |
| open_file_linux | 0.0.5 |
| open_file_mac | 1.1.0 |
| open_file_platform_interface | 1.1.0 |
| open_file_web | 0.0.4 |
| open_file_windows | 0.0.3 |

Candidate A: approve generating/adopting this existing-dependency resolution
with pinned Flutter3.41.6 and review the complete resulting lock. This matches
the isolated520-case/native-build checkpoint and does not upgrade existing
package versions. Original ignored package metadata can then be regenerated
consistently. Candidate B: keep the foreign lock untouched and continue running
verification from the isolated worktree; release/CI reproducibility remains Q01.
Owner selected Candidate A on2026-10-23 after a plain-language clarification;
Candidate B was not selected. Generated Dart lock matches the prior605-case
resolution exactly (SHA2566d4f614da44fdd097bc6929b6fbed9581a7d4d17e7fd34fe080b8ab4c7ab1190).
The manifest now declares matching Dart>=3.11/Flutter>=3.41 minimums instead of
allowing an older SDK that cannot consume the tested graph. CI remains pinned
to the already-tested Flutter3.41.6; no existing Dart package version changed.

Historical pre-approval comparison: the isolated ios/Podfile.lock was excluded.
Compared with the tracked
original Pod lock, it records open_file_ios pod0.0.1 to1.0.3 and seven changed
local plugin spec checksums (image_picker_ios, open_file_ios,
path_provider_foundation, pointer_interceptor_ios, url_launcher_ios,
video_player_avfoundation, webview_flutter_wkwebview). These are actual observed
lock differences, not approval to update CocoaPods dependencies. Q01 adoption
was approved on2026-10-23 and both locks regenerated consistently, without
hand-edited checksums. The native delta retains the same observed pod/spec
changes plus the new Podfile SHA1 checksum68751f5719bba4ba89411ca6466fd12051e76cd8
for the approved iOS15 configuration. Both locks are included in17140ac and
remain under independent/native verification before original-main adoption.

Separately, pub reports72 packages with newer versions outside current
constraints. That is an inventory signal, not an upgrade plan or approval to
change them. Dependency upgrades require their own staged changelog/security/
behavior checks and owner decision. Do not combine upgrades with this lock fix.

Q02 historical proposal: Runner declared13.0; Podfile's13.0
platform line is commented. Local successful simulator builds use a command-only
15.0 override. No permanent supported-OS change or dependency downgrade is
selected here; actual older-device support remains unverified.

Owner approved iOS15 on2026-10-23. Runner Debug/Profile/Release and the Podfile
now declare15; post-install raises lower iOS pod/resource targets while
preserving higher declared dependency minimums. Actual generated project has
42 targets/19 resource bundles/126 configurations at15.0. Fresh simulator build
without a deployment-target override completed exit0; produced plist and Mach-O
both report15.0. Independent frozen-source/configuration review has no blocker;
Android debug also produces its APK. Detailed commands/logs are in
LOCAL-VERIFICATION.md and EXECUTION-2026-10-20.md. Earlier
iOS13 users are outside the newly approved supported range; no release shipped.

Reproduced2026-10-22 with the same arm64 command in a fresh derived-data folder
and no deployment-target override: xcodebuild exits65 before compilation.
Installed Xcode27.1 rejects Runner13.0 and Pods9.0-13.0 because this simulator
SDK accepts15.0-27.1.x. The diagnostic establishes a local toolchain/target
incompatibility, not a server/plugin requirement to drop iOS13 support. Log:
/private/tmp/mopa-ios-declared-target-20261022.log. No source, Pod installation
or persistent build setting changed in this comparison.
