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
- Device (account 1): Courses tab entry exam card shows 0/1 (evidence 17-entry-exam-card-0-of-1.png). Tapping that card did nothing and sent no request: haiku-locator tracing the tap chain. Home: an emoji next to "دورات أكملتها" (C7 bans emoji in UI; check if original).
- Account 1 (earlier note): owner says the password is unchanged. Maestro login returned invalidlogin twice (the password has a dollar sign; env interpolation, then a literal flow). Not resolved by automation; owner asked to sign in on the simulator himself.
- Owner killed the hung flutter_tester 16685 himself (A1 had asked the orchestrator to kill it; refused as permission laundering).
