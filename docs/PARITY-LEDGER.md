# Platform verification ledger

Updated: 2026-10-18.

| Surface | Status | Evidence / remaining work |
| --- | --- | --- |
| Shared Flutter code | Audit in progress | Course, quiz, authentication and other screens are shared. |
| iOS | Build, boot and user sign-in observed | iPhone 17 Pro / iOS 26.5; scenario navigation blocked by denied Device Hub Computer Use access. |
| Android | Source inspection only | Download permissions and manifest inspected; no runtime result yet. |
| Moodle backend | Not verified | No backend source/schema in the app repository. Account testing was authorized, server administration was not. |
| Web counterpart | Not located | No web implementation is present in this repository. |
| Toast/Back and auth form flows | Shared-code defects reproduced locally | Actual MyApp widget test proves invisible snackbar/blocked Back; synthetic controller tests prove silent completion validation and reset/login failure conflation. iOS/Android interactive retests remain open. No implementation made. |

All remaining gaps must be presented before any deployment. No deployment is
part of this audit.
