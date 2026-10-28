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
| 1 | A1 | worktree /Users/saker/Desktop/Flutter/mopa-wt-a, branch claude/a-regressions: offline cache per user, reset auto-login, pubspec.lock no downgrades vs origin | running (flutter-developer, Sonnet high) |
| 1 | A2 | worktree mopa-wt-a2, branch claude/a2-toast-download: toast original look, #21 downloader returns bool + Arabic names + real extension, restore empty-state and certificate card UI | running (flutter-developer) |
| 1 | B1 | worktree mopa-wt-b1, branch claude/b1-progression: #17 card 1/1 (TEMP when numsections 0), #18 count all activities, #20 refetch + Next rule, restore TestResults answer colours | running (flutter-developer) |
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
