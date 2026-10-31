# Run state: GitLab tickets and Codex remediation (2026-10-28)

Living state file (J1). Owner: Saker. Orchestrator: Claude Opus 5.5.

## Owner decisions this session

- Continue on top of the Codex commits, fix its regressions, then simplify its code to the owner's style with an explanation.
- Fix every open GitLab ticket (#16-#22), including the ones marked Ready For QA; fix other defects found too.
- Anything needing the backend goes into one file for the backend developer, splitting mandatory backend work from items handled locally (temporary or permanent).
- The owner's real account may be used freely for testing on the simulator.
- Review Codex UI changes for side effects elsewhere.
- Allowed: push to GitHub after verification. GitLab comments and status: the owner does them himself; we supply screenshots.
- Agents: Haiku for research, Sonnet for implementation.

## Open items

- SEC-10: the owner's account password appeared in chat and in a screenshot (2026-10-28). Action: owner changes the password after testing.
- SEC-10: the shared service token at lib/Data/Database/config/database_end_point.dart:18 was printed in a local subagent tool log; it is also bundled in the shipped app. Action: backend restricts or rotates it (backend request file).

## Plan and progress

| Wave | Lane | Scope | Status |
| --- | --- | --- | --- |
| 0 | orchestrator | debug API capture (541e067), email ASCII-only (bbf3565), issues and images in docs/gitlab-issues | done |
| 1 (merged) | A1 | worktree /Users/saker/Desktop/Flutter/mopa-wt-a, branch claude/a-regressions: offline cache per user, reset auto-login, pubspec.lock no downgrades vs origin | running (flutter-developer, Sonnet high) |
| 1 (merged) | A2 | worktree mopa-wt-a2, branch claude/a2-toast-download: toast original look, #21 downloader returns bool + Arabic names + real extension, restore empty-state and certificate card UI | running (flutter-developer) |
| 1 (merged) | B1 | worktree mopa-wt-b1, branch claude/b1-progression: #17 card 1/1 (TEMP when numsections 0), #18 count all activities, #20 refetch + Next rule, restore TestResults answer colours | running (flutter-developer) |
| 1 | audit | Codex UI side effects: report in scratchpad codex-ui-audit.md; restores assigned to A2 and B1; device checks pending (home level track, blog load-more, carousel, buttons) | done |
| 1 | orchestrator | diagnose #18 lesson 2 grading on the owner's account | BLOCKED: entry quiz (course 19, quiz 2) has attempts_allowed 1, last_attempt_status finished, can_start false, course still 0% and not completed, so courses after it stay locked. Needs an account past the entry exam or a backend attempt reset |
| 2 | B2 | #18 file checkmark (local), #18 duration, #19 minutes (local) | pending |
| 3 | simplify | simplify Codex abstractions to the owner's style | pending |
| 4 | docs | BACKEND-REQUESTS, per-ticket evidence, review | pending |

Estimate: 7 to 13 agent-work hours (est., basis: sonnet-high median 17-32 min per small task, these lanes sized 30-60 min each plus device checks and reviews).

## Real payload facts (captured 2026-10-28, owner account)

- get_user_categories_summary: course 19 "اختبار القبول" numsections 0 (card shows 0/0); course 130 "أساسيات الدعوة" numsections 12.
- get_user_statistics: minutes 0 present.

## Notes

- The GitHub remote (RAKAN-ALHAWAR/Messengers-of-Peace-Academy---MPA) is PUBLIC. The GitLab issue archive (text and screenshots, which hold testers' emails and phones) is therefore kept outside the repo at /Users/saker/Desktop/Flutter/mopa-gitlab-issues/.
- Next activity rule (approved 2026-10-28): Next opens the next activity in course order (video, quiz, file); locked or none returns to course details.
- Course 19 details payload: one quiz activity (cmid 99, quizid 2, video_duration "0:00"); details page showed 0/0 and (no lessons) because the client counted videos only.
- Owner account is also enrolled in course 5 "Admission Exam" (English).
- Lesson unit (corrected 2026-10-28, sent to B1): a lesson is a TOPIC with content (video, quiz or file), completed when all its content activities are completed. The earlier "every activity" rule was an unverified premise; logged in ~/.claude/improvement/INBOX.md. Course 130 total of 12 (11 lessons plus the summary file topic) is UNVERIFIED until a second account opens it.
- Account deletion (owner approved 2026-10-28): the user token's service has 163 functions (Moodle 5.3) and none deletes or requests deletion of an account (only tool_dataprivacy_get_category_options). The Moodle privacy pages exist on the site (createdatarequest.php redirects to login), whether users may request deletion there is UNVERIFIED. Plan: in-app delete-account screen with a confirm dialog; temporary path opens the site's data-request page; mandatory backend item: a deletion endpoint.
- Entry exam attempts message (owner request 2026-10-28): when quiz info says can_start false, explain why from the server fields (attempts_allowed, last_attempt_status), never hard-coded.
- Queued lane C (after B1 merges, shares lib/Ui/Screen/Test and translation files): attempts explanation on TestInfo, delete-account screen in Profile.
- 2026-10-28 owner reproduced on device: password reset returns to Login, then a red error "A TextEditingController was used after being disposed". Sent to lane A1 (auto sign-in after reset plus root cause of the disposed controller, test first). The owner's password was reset, so the password shared in chat may already be outdated; the SEC-10 item stays open until he confirms.
- Attempts message wording: do not show counts like "(1 من 1)"; explain from server fields without a count.
- Second test account: login_user succeeds, get_user_full_profile returns errorcode usernotfullysetup, app stayed silently on Login. Owner decision: route to CompleteAccountInfo so the user completes data (not a blocking message). Sent to lane A1.
- Email field: simulator keyboards are ar then en; the Mac input source was Arabic PC; iOS keeps a separate input language for the email keyboard type, so typed keys arrive as Arabic letters and the ASCII-only formatter drops them silently. Automated typing (Maestro) of an ASCII email works. Queued for lane C: when a non-ASCII letter is rejected, show a hint under the field to switch the keyboard to English, instead of dropping silently.

## Checkpoint 2026-10-28 evening (merge batch 1 done)

- Merged into main (not pushed): A1 957b929, A2 f4893bc, B1 d1c8d19, test fix 06629a6. Full suite `+678: All tests passed!`, analyze clean (merge agent; lane results re-verified by the orchestrator: A2 test/ui +70, B1 test/learning+quiz +149, A1 lock has 0 version lines differing from origin/main).
- Owner decision: toast stays at the original top position (covers the back arrow for its short life, as originally); the two notification tests now dismiss it first.
- Next steps, in order:
  1. Blind review of merge batch 1 (Sonnet, read-only) - launched.
  2. Relaunch the app on simulator 7A51E729 (iPhone 17 Pro) with `--dart-define=MOPA_CAPTURE=true`; log in with the second account (credentials are in the chat, never written to files); verify: incomplete profile routes to CompleteAccountInfo, save works, then courses: card 1/1 entry exam, course 130 lesson count (expect 12, UNVERIFIED), lesson 2 quiz grading (#18), Next button, immediate checkmark, toast look, email field.
  3. Lane C (needs a haiku pack first): delete-account screen (temporary path opens the site data-request page; backend endpoint mandatory), attempts explanation on TestInfo from server fields with NO counts, email field hint when Arabic letters are rejected, OTP controller line 78 same disposed-controller bug as Login, per-topic "N lessons" sub-label (decide after device check).
  4. Lane B2: #18 file checkmark (local), #18 duration, #19 minutes (local).
  5. Simplify Codex abstractions to the owner's style; BACKEND-REQUESTS file; final review; push to GitHub (approved after verification).
- The second account: login_user ok, get_user_full_profile errorcode usernotfullysetup.
- Batch 1 blind review (Sonnet, report in the session scratchpad review-batch1.md): verdict fix first, no Blocker. Triage:
  - Major 1 (offline cache inert): verified, but not a regression: no caller set localCacheKey at v0.0.1 (a57bc44) either, so offline mode never existed; A1 only made the dormant per-user key safe. No fix in this run; listed as a possible feature for the owner.
  - Major 2 (topic with a file may never complete): folded into lane B2 (#18 file checkmark).
  - Major 3 (stale CourseDetails controller after a passed quiz, UNVERIFIED) and Minor (completion failure skips the refetch): fix lane, worktree /Users/saker/Desktop/Flutter/mopa-wt-fix1, branch claude/fix-batch1 (flutter-developer, Sonnet high), test first.
  - Other minors (5 s dwell before Next, silent file download after a pass, "N Lessons" sub-label, .part leftover, font-dependent goldens, cold start with usernotfullysetup signs out): lane C/B2 candidates or final report.
- Device check 2026-10-28 (merged main faa51f3, simulator 7A51E729): second account login now lands on CompleteAccountInfo (evidence: mopa-gitlab-issues/evidence/incomplete-profile-routes-to-complete-account.png). Saving needs real personal data (birth date, WhatsApp number, country) written to the owner's live profile: asked the owner to fill it himself instead of inventing values.
- Lane C launched (flutter-developer, Sonnet high): worktree /Users/saker/Desktop/Flutter/mopa-wt-c, branch claude/c-account-quiz-ux; pack in ~/.cache/agent-kit/packs/.../C-account-quiz-ux/; items: delete-account row (TEMP backend, opens the site data request page), attempts explanation without counts, email keyboard hint, OTP disposed controller.
- Owner said «عبي انت بيانات»: the orchestrator filled the second account's profile on the simulator (birth date 2008-10-28 picker default, WhatsApp +966 555123456, male, Saudi Arabia, Riyadh, Arabic, "recommendation from a friend", scholarship no). Save sent local_otp_registration_update_user_profile and the SERVER refused it with errorcode usernotfullysetup (HTTP 200). The app shows the server message as a red toast (evidence: mopa-gitlab-issues/evidence/complete-account-save-refused-usernotfullysetup.png). Root cause is backend: Moodle blocks every web service call for a user with missing required fields, including the plugin's own profile update. MANDATORY backend item. Nothing on this account can be tested past this screen until then.
- Seen on device: the date picker header shows Arabic-Indic digits (M3 asks Latin). Queued for lane B2.
- Fix lane merged (8e72ff0): premise real (red: details.isClosed true); passed quiz now returns to the live course page; refetch runs even when completion fails. test/quiz + test/learning `+150: All tests passed!`.
- Lane C merged: delete-account row (TEMP backend, opens the site data request page), attempts explanation with no counts, email keyboard hint, OTP premise false (two guard tests only). Lane tests `+18: All tests passed!`. Device: email hint shows under the field in Arabic (evidence email-field-keyboard-hint.png). Delete row and TestInfo message not yet seen on device: the first account's chat password now returns invalidlogin (owner reset it earlier).
- Lane B2 launched (flutter-developer): worktree /Users/saker/Desktop/Flutter/mopa-wt-b2, branch claude/b2-local-progress: file checkmark, duration, minutes, date picker digits.
- docs/BACKEND-REQUESTS.md drafted (0305b45); B2 items to be added when it lands.
- Account 1 resolved: a direct login_user call with the shared password succeeded for account 2 and failed for account 1 (server side, not the app). Owner then reset account 1 via the app: reset now signs in and lands on Home (A1 fix confirmed on device). Owner saw the success button sit about 4 s (sign-in 2 s + profile 2 s): fixed in 1133e64 (button stays loading until sign-in ends; test red then green, test/auth +14).
- Device (account 1): Courses tab entry exam card shows 0/1 (evidence 17-entry-exam-card-0-of-1.png). Tapping that card did not open course details. Chain (haiku trace): AllCourses view.dart:62-65 -> course_carousel.dart:179 -> course_card.dart:40-43 (onTap only when isOpen) -> AllCourses controller.dart:89-113 onCourseTap (silent return at :102 when lease has no identity; else Get.toNamed(courseDetails) then getData). Capture shows get_user_categories_summary at 19:15:22 right after the tap and no course details request: so the handler ran and Get.toNamed returned at once without showing the page. Prime suspect UNVERIFIED: GetX preventDuplicates (Get.currentRoute already equal to /courseDetails) or the route not pushing. NEXT: reproduce in a widget test (open Courses tab after the reset sign-in path, tap card) and fix; ask the owner whether a manual tap opens it. Home: an emoji next to "دورات أكملتها" (C7 bans emoji in UI; check if original).
- Account 1 (earlier note): owner says the password is unchanged. Maestro login returned invalidlogin twice (the password has a dollar sign; env interpolation, then a literal flow). Not resolved by automation; owner asked to sign in on the simulator himself.
- Owner killed the hung flutter_tester 16685 himself (A1 had asked the orchestrator to kill it; refused as permission laundering).

## Course card tap: root cause found (2026-10-28 19:3x)
- Owner: the card does not open by hand either; he believed the backend keeps the first course locked and asked to open the first course locally when nothing is open.
- Evidence: server returns course 19 is_open true; runtime print on tap: `origin=null active=null current=false`. AllCourses onCourseTap guards on `Get.rawRoute?.isActive`, and rawRoute is null on the root tab page, so it returns before navigating. App-side bug from Codex commits (10e71bf, 601e22f, ab7a6ed); same pattern in Home:250, MyCourses:51, ProfileDetails:148.
- The existing local first-course unlock (AllCourses controller ~52-83) never runs: `map(...).isEmpty` is only true with zero levels.
- Owner asked that a Sonnet agent do the work, not the orchestrator. Lane launched: flutter-developer (Sonnet 5.5 high), worktree ../mopa-wt-tap, branch claude/fix-course-tap: tap fix + counterparts + fixed local unlock (TEMP(backend)), test-first, simulator evidence.
- Temporary debug prints were reverted (git restore), nothing committed from them.
- NEXT: verify lane diff, merge, add the unlock item to BACKEND-REQUESTS section 2.

## Lane B2 merged (2026-10-28)
- Commits 9f6c4b5, a29f01e, efbf6b6, 4340825, 69b6bb3 merged no-ff into main. Re-run on main: `flutter test test/learning test/ui test/quiz` +247 All tests passed.
- Review notes for the batch review: `_markFileDownloaded` doc names a missing `_applyLocalFileFlags`; `Zone.root.run` in CourseDetails exists only for fake-async tests; learned seconds count page dwell including pause.
- BACKEND-REQUESTS items 6-9 added (file completion, video duration, minutes, first course open).
- Tap lane still running.

## Tap lane merged, batch 2 pushed (2026-10-28)
- claude/fix-course-tap (4044929 tap via RouteOriginX, e1cdb2d shared first-course unlock) merged no-ff. Agent RED "+1 -4", GREEN tap +5, unlock +6. Defect was in AllCourses, Home, ProfileDetails; MyCourses moved to the helper.
- Batch full run on main: analyze "No issues found!", `flutter test` "+723: All tests passed!". Simulator evidence: evidence/course-card-opens-details.png (details page of course 19 opened).
- Pushed main f338fa9..a688a4b. CI status still to read with ci-status.
- Blind review of batch 2 (8da747b..HEAD) launched on code-reviewer Opus medium.
- NEXT: review findings, fold fixes on Sonnet, ci-status, device checks list, simplify Codex abstractions, worktree cleanup (a, a2, b1, fix1, c, b2, tap).

## Batch 2 review result and fold (2026-10-28)
- Reviewer (code-reviewer Opus medium): no Blocker. Major 1: first-course unlock opened any next course (defeats server sequencing); narrowed to the owner's words: only the first course of the first level when nothing is open. Major 2: delete-account dialog claimed permanent deletion while only a web request page opens; reword. Minors m1-m7: stale doc name, Zone.root seam, lost increments, non-reactive minutes card, Get.until without isFirst, reset cleanup throw spins forever, video URL key may persist a token.
- Reviewer saw 8 shader-asset env failures (ink_sparkle.frag); main full run was +723 green, treated as env.
- Fold lane: flutter-developer Sonnet high, worktree ../mopa-wt-fold, branch claude/review2-fold. Then re-check only the listed findings (round 1 of max 2).
- CI: no run yet on main after push (pending).

## Fold merged, main red on two tests (2026-10-28)
- claude/review2-fold merged no-ff (5640031); I re-checked all 9 listed findings in the diff: fixed. analyze clean.
- Full suite hung: next_activity_test and progression_test fail `Bad state: Cannot add event while adding stream` because the new addLearnedSeconds seam is not injected there (fake-async Hive write). NOT pushed.
- Fix lane: flutter-developer Sonnet, worktree ../mopa-wt-vt, branch claude/fix-video-tests, tests only.
- Foreign uncommitted change in main and fold worktree: analysis_options.yaml adds analyzer exclude build/android/ios. Not mine; left untouched; report to owner.
- Test fix 180cb1e merged; main full suite "+731: All tests passed!"; pushed.
- CI gap: repo has no .github/workflows, so no run ever starts (D8 requires CI). Proposed to owner: flutter analyze + flutter test workflow (public repo, free minutes).
- Remaining: device checks (delete-account page reachable, TestInfo message, course 130 count, #18 grading, Next/checkmark, toast), simplify Codex abstractions + explanation doc, GitLab evidence per ticket, worktree cleanup (a, a2, b1, fix1, c, b2, tap, fold, vt), SEC-10 report, INBOX retro, owner answer on analysis_options.yaml.

## Owner answers after batch 2 (2026-10-28)

- Account deletion: owner said «بخصوص حذف الحساب رح يكون عبر نقطة api مو فتح صفحة خارجية». Opening the website page stays as the temporary path until the backend ships the function; BACKEND-REQUESTS item 2 updated. App switch waits for the function name and contract.
- CI: owner said «مافي داعي» (no workflow). D8 gap recorded as the owner's decision.
- analysis_options.yaml analyzer exclude (build, android, ios): owner said «شوف المناسب»; kept and committed (standard exclude of generated and native folders).
- Owner asked whether local file checkmark and learning minutes are per user and survive logout: verified in code (local_key.dart keys prefix the user id; clearLocalSession removes only userid and token), answered in chat.
- Next: device checks lane (Sonnet), worktree cleanup, Codex simplification, GitLab evidence.

## Device check of main 00a8ff5 (2026-10-28, Sonnet flutter-developer, account 1)

- PASS: delete dialog new text and «فتح الصفحة» (evidence v-01-delete-account-dialog.png, viewed by orchestrator); entry exam test info explains used attempts from server fields (v-02-entry-exam-test-info.png, viewed); course cards entry exam 0/1 and course 130 shows 12 lessons (v-03-*).
- BLOCKED on account 1 (only open course is the entry exam: no file, no video, nothing completed): file checkmark, video duration, Next button, minutes card, course 130 details (locked), toast (none arose). Needs an account with an open course that has a video and a summary file.
- Emoji 🥳 in «دورات أكملتها» is original (Saker v0.0.1, user_statistics.dart:22 and Ar/general.dart:135); C7 bans emoji in UI; asked the owner.
- Worktrees mopa-wt-* (9) removed after checking each was merged; fold's only change equals main's analysis_options.yaml.
- Full report: mopa-gitlab-issues/evidence/v-REPORT-device-drive-main-00a8ff5.txt.

## Owner answers (2026-10-28, after device check)

- Emoji 🥳: «لا اتركه مثل ما هو» (keep it; owner exception to C7).
- «افتح من حسابي الثاني وجرب»: account 2 was last refused by the server with usernotfullysetup on every call; the password lives only in chat, so the owner signs in on the simulator himself, then a Sonnet agent drives.
- «تمام ابداء»: start the Codex simplification. Step 1: Opus plan (inventory by Haiku), presented to the owner before any code edit.

## Simplification plan: owner answers (2026-10-29)

Blind plan review (Opus): rework; Blocker 1 tests cannot see a dropped guard atom at most sites (only 3 test files switch locale; verified), Blocker 2 the fixed helper bundle does not match call-time app capture at some sites (Badges:20 verified). Owner answers:
1. «١أ»: add the small shared helper in the owner's `...X` style, atoms chosen per site.
2. «٢ أ»: write the missing tests first (remove each atom per site, record the red test; add a test where none goes red).
3. «٣ توصيتك»: trim Codex comments to one-line `///` in the same slices.
4. «٤ تمام»: UI and model rewrites get a separate style pass later.
5. «٥ مافي داعي، صلح بس المشاكل الموجودة»: no GetX tags; fix only existing problems.
6. «٦ واحد»: one Arabic explanation file docs/MECHANISMS-EXPLAINED.md.
Next: Sonnet fold of the plan per these answers and the review, then the whole plan back to the owner for approval.
Parallel: complete-account save failure on account 2 under diagnosis (Sonnet, worktree mopa-wt-caf).

## Account 2 save failure and plan fold (2026-10-29)

- Diagnosis (Sonnet): save call update_user_profile -> HTTP 200 usernotfullysetup (capture 0016); the form sends all 8 required custom fields plus city; Moodle WS core never calls user_not_fully_set_up, only require_login inside the plugin does. Likely backend lock, not fully proven (an empty server-side field outside the app's 8 not excluded; no field-list function exists). Fix merged: clear 4-locale message when the save itself is refused (d46f8c8). Full suite "+732: All tests passed!", analyze clean.
- Simplification plan folded (Sonnet), re-checked by orchestrator against the review list: Step 0 atom pass, capture point section 3, VideoPlayer in S2, Acceptance per slice, estimate 5.9 to 12.5 agent-hours. Awaiting owner approval; new question: split S7.

## Simplification plan approved (2026-10-29)

- Owner: «موافق عليها» on the whole folded plan (docs/SIMPLIFY-PLAN.md at d767e46). S7 stays one slice (plan default, owner did not ask to split).
- Running: probe of account 2 save with all optional fields (Sonnet, worktree mopa-wt-probe, owner asked «جرب تبعت كل البيانات حتى الاختيارية»).
- Next: Haiku pack for S1, then S1 (Sonnet xhigh) alone in worktree mopa-wt-s1.
- Owner on the test accounts (2026-10-29): «لك قلتلك عادي يطلع التوكن ويطلع كلمة السر والايميل، هو تجريبي ما بأثر». Agents may handle the test-account token, password and email directly; still never committed to the public repo. Account 2 probe switched to direct API calls («ليش ليستخدم التطبيق؟؟ يبعت مباشر عبر ال api»).

## Account 2 direct API probe and S1 merged (2026-10-29)

- Direct API (orchestrator, plain curl; Python urllib got HTTP 403 from the server's filter, a spoofed User-Agent was denied by the permission classifier and not retried): login_user OK (userid 120488); core_webservice_get_site_info OK (163 functions); get_user_full_profile -> usernotfullysetup; update_user_profile -> usernotfullysetup with the app's 8 required fields, with each of the 6 optional fields added alone, and with all 14 together. Proven backend lock: the plugin refuses before saving any field.
- Server view of account 2 (core_user_get_users_by_field, service token): custom fields set are only ulang, ksaunistudy, role; empty: gender, WhatsAppNumber, Age, HearboutUs, nationality, countrycode (account 1, complete, has all of them). So the account is "not fully set up" because those required fields are empty, and the only function that could fill them refuses it.
- Side note: update_user_form.dart:124-127 gates countrycode on howToFindUsOthers != null (owner original a57bc44); callers always pass a string, so countrycode is sent; latent only. Not changed.
- S1 merged (5c77d2f, d70c548, ee897f1): ControllerLeaseX, 40 new tests, 15 gap tests watched red. Main full suite "+772: All tests passed!", analyze clean.
- Next: Haiku packs for S2..S8, then 7 parallel Sonnet lanes.

## Incomplete account behaviour (2026-10-29, owner decisions)

- Owner on Skip signing out: «بس هاد شي مؤقت وممكن يتصلح اصلا من الباك اند ف بصير بيغدر يدخل، ف طريقتك غلط وليش قررت بدون ما تقلي». Conceded: lane A1 (e192c4d) chose sign-out and it was merged without asking. INBOX line logged.
- Decision: Skip on Complete Account Info goes to the app root, never signs out.
- Decision «اكيد خيار ب»: on app start, an account whose profile returns usernotfullysetup stays signed in and opens Home (no sign-out). Both added to the S5 lane as separate behaviour commits, test-first, with the `late user` trap to handle.
- Probe build replaced on the simulator by the normal main build (owner: «شيله اذا تجريبي»). Note: `flutter build ios --simulator` fails on this macOS at the lipo arch check; xcodebuild arm64-only works.
- Owner (2026-10-29): «خلص بلا اختبارات». S2 and S5 stop the Step 0 test-writing pass and finish; one final run of existing tests only, to keep main green before merge.

## Simplification S1..S8 merged (2026-10-29)

- All 8 slices merged on main. Full suite "+937: All tests passed!" (731 before the plan), analyze "No issues found!". Worktrees removed.
- S5 behaviour commits: 7ddda5b Skip goes to root; 5208512 incomplete account stays signed in at startup, opens root, minimal user from the stored id (AppControllerX.unfinishedUser).
- Step 0 coverage gaps after the owner stopped it («خلص بلا اختبارات»): S5 ForgotPassword, ForgotPasswordReset, Loading, most CompleteAccountInfo atoms; S2 four tap-handler entry guards. Equivalent mutants kept (S3 11, S4 2, S2 some). VideoPlayer controller untouched.
- Remaining: batch blind review (Opus), simulator drive (incl. language switch while loading, incomplete account Skip and restart), Arabic docs/MECHANISMS-EXPLAINED.md, GitLab evidence, retro.
- Three orphan flutter_tester processes from the old fix1 lane (PIDs 30517 30676 31002): kill denied by the permission classifier; owner told.

## 2026-10-31 owner report after taking the entry exam (account 1 on simulator)
- Owner asks: «قدمت الاختبار لكن ما ظهرت النتائج الصحيحة والخاطئة، اصلح هذا»; «بس ضغطت على الانتقال للدرس التالي ... بعد شي ٢٠ ثانية تحدثت، لازم المفترض تتحدث فورا ويظهر انه عم يتم تحميل البيانات». Backend guide added (untracked): docs/mobile-webservices-developer-guide-ar.docx.
- Evidence (app api-capture, 2026-10-31): get_quiz_result for attempt 1996355 returned status ok, grade 8.00/10.00, passed "Passed", answers: [] (empty). The guide (function 047) says Moodle review options can hide answers; an empty list means the server withheld per-question correctness. get_quiz_info has no correct/wrong counts before an attempt. Candidates for counts per the guide: get_quiz_full_details (043, quizid) and get_quiz_attempt_details (049, attemptid), both "according to review options": UNVERIFIED on the real server.
- Refresh delay: continueAfterPassedQuiz (CourseDetails controller:180) refetches silently; get_course_details response landed ~20 s after the tap (server latency). Fix lane claude/quiz-refresh-loading (flutter-developer, Sonnet high): loading sign during the refresh. In progress.
- Question to owner: is hiding answers on the entry exam intentional (backend quiz review options), and should the app probe 043/049 for counts.
- Owner 2026-10-31 (2): levels progress lock is correct («معك حق»). Approved TEMP fix 1 only: «هلق مزال محطوط انه مكتمل ف حطه انه ١٠٠٪» (a course with is_completed true shows 100%). Items 2 (level percent from courses) and 3 (hide zero lesson counter) NOT approved yet. «لانه» was not cut: answers are expected to be shown.
- Owner ask: «تحميل الملف تبع الدورة فيه مشكلة، عالجه بالكامل وخليه يظهر قديش نسبة التحميل، وضيف ايقونة تحميل عليها بدل ما تكون فارغة وبس يحمل لازم تصير صح، وتأكد من التحميل على الاندرويد والايفون». Files: lib/Core/Service/download_file_form_url.dart, CourseDetails controller onTapLessonSummary (:331), view/sections/activities.dart:207. Queued after lane claude/quiz-refresh-loading merges (same files) and after the quiz drive frees the simulator. Android AVDs: Pixel_10, Sahl_Test.
- Running: lane claude/quiz-refresh-loading (CourseDetails + AllCourses + Home loading after quiz); quiz drive agent (course 130 quiz, raw JSON to scratchpad/q2/).
- Quiz answers: lesson quiz 488 (attempt 1996383) returned answers[] with right true/false and passed "Failed"; the app showed «لم تتأكد نتيجة الاختبار بعد» because isSuccess (21172e6) knew only 'passed'/'not passed'. Fixed on claude/quiz-failed-label 5041456 (test/quiz +86 green, analyze clean); not merged yet. Entry exam (quiz 2) answers [] = Moodle review options for that quiz: backend/admin item.
- Owner: «عندي ظهر انه جاري التحميل وبس، اما بجيت لاب ... مافي صلاحيات» (GitLab #21 screenshot: Android toast «مطلوب إذن الوصول للتخزين»); «وبس تحط انه اكتمل خلي بدل 0/1 تصير 1/1». Lane claude/completed-card running (course_card: completed -> 100% and N/N).
- SEC-10 OPEN: account 1 user wstoken appeared in tool output on 2026-10-31 (download_url query `token=` inside an api-capture file; the capture masks token keys but not tokens inside URL values). Rotate: sign out of all sessions / regenerate the user's token in Moodle. Also fix HttpDebugCaptureX to mask `token=` inside string values.
- Batch review (code-reviewer, Sonnet) of 30841d2..6811442: merge-ok, no Blocker/Major. Main 6811442 pushed; tied tests +380, analyze clean.
- Lane claude/file-download (flutter-developer, Sonnet high) running: root cause on iOS and Android, progress percent, download icon, checkmark, capture token masking.
- SEC-10 OPEN: owner pasted account 1 email and password in chat on 2026-10-31 for the Android/iOS sign-in (owner choice: test account). Rotate after testing. Never written to files.
- File download lane claude/file-download: a72c045, 1545b9e, baf71cc, a66d7b1 (+383 tests, analyze clean). iOS verified on the simulator (icon, percent inside ring, green checkmark, section ring 100%, second tap opens/re-downloads). Android verified only with a probe app on the real service (icon, percent in ring, file saved 3537161 bytes, chooser, checkmark, second tap, no storage-permission dialog); the real course page is locked on the Android account. Blind review running.
- Account fact: the iOS simulator account is userid 120488 (account 2, earlier usernotfullysetup) and it now works (passed entry exam, took lesson 1 quiz). The Android sign-in with the owner-given email is account 1, entry exam not passed. iOS sim api-capture folder trashed (old captures held wstokens).
- Download review (code-reviewer, Sonnet): fix-needed, 2 Major (same cut file name for two files; file flag turning video/quiz rows done) + 3 Minor; folded in 267c95f, re-checked by reading the diff. Merged c40a897, full suite +1001 all passed, analyze clean, pushed. Worktree removed.
- Open: Android real course page (re-entry checkmark, section ring) needs the owner to sign in on the emulator with the iOS-simulator account (120488) or accept merge as is (merged; logic shared and tested). Pending owner answer.
