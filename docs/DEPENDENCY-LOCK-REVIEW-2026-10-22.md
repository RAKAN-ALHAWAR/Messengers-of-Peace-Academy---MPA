# Protected lock review

Status: proposed, unapproved adoption. This is evidence for the explicit Q01
owner decision, not permission to replace the foreign lock or upgrade packages.

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
No option has been selected by this document.

The isolated ios/Podfile.lock also remains excluded. Compared with the tracked
original Pod lock, it records open_file_ios pod0.0.1 to1.0.3 and seven changed
local plugin spec checksums (image_picker_ios, open_file_ios,
path_provider_foundation, pointer_interceptor_ios, url_launcher_ios,
video_player_avfoundation, webview_flutter_wkwebview). These are actual observed
lock differences, not approval to update CocoaPods dependencies. A later Q01
adoption must review and regenerate both locks consistently rather than commit
only the Dart lock or hand-edit generated checksums.

Separately, pub reports72 packages with newer versions outside current
constraints. That is an inventory signal, not an upgrade plan or approval to
change them. Dependency upgrades require their own staged changelog/security/
behavior checks and owner decision. Do not combine upgrades with this lock fix.

Q02 remains a separate minimum-OS decision: Runner declares13.0; Podfile's13.0
platform line is commented. Local successful simulator builds use a command-only
15.0 override. No permanent supported-OS change or dependency downgrade is
selected here; actual older-device support remains unverified.

Reproduced2026-10-22 with the same arm64 command in a fresh derived-data folder
and no deployment-target override: xcodebuild exits65 before compilation.
Installed Xcode27.1 rejects Runner13.0 and Pods9.0-13.0 because this simulator
SDK accepts15.0-27.1.x. The diagnostic establishes a local toolchain/target
incompatibility, not a server/plugin requirement to drop iOS13 support. Log:
/private/tmp/mopa-ios-declared-target-20261022.log. No source, Pod installation
or persistent build setting changed in this comparison.
