# Backend contract request

Status: proposed information request, not an adopted server specification.
Inspected frontend baseline: f338fa9. Backend source is unavailable to Saker;
an API description may be supplied later. No backend changes are requested by
this document and no message has been sent to a service owner.

Please supply sanitized successful/error examples and rules below. Use
synthetic identities such as user1001/course2001/topic3001/module4001/quiz5001/
attempt6001. Never include passwords, OTPs, real tokens or user records.

## Common transport and authorization

The app uses Moodle REST wsfunction/moodlewsrestformat=json, POST form fields,
Accept-Language and wstoken. Confirm each endpoint's identity binding, permitted
caller, status/error schema, HTTP codes, nullability and numeric types. Which
token-expiry errors should initiate reauthentication? Which failures are
retryable, and which mutations support idempotency?

A service credential is bundled in frontend source. Its privileges are not
established. Provide intended anonymous operations and ACL; coordinate removal/
rotation separately. Protected operations must derive authorized identity from
the user's credential, regardless of supplied userid/username.

## Authentication and the newly reported symptoms

Frontend reset sends username=email, otp and newpassword. Confirm actual field
names, password policy, OTP lifetime/consumption, reset acknowledgement and
behavior after a repeated request. Does reset invalidate existing tokens?

After reset, the frontend calls login then get_user_full_profile. Provide
separate response examples for each stage. An accepted reset must be
distinguishable from a subsequent login/profile failure; a retry should not
blindly repeat an already accepted reset.

Current frontend expectations, requiring confirmation:

| Operation | Inputs / currently consumed response |
| --- | --- |
| create_user | email/password/firstname/lastname/username/lang; expects userid |
| login_user | username/password; userid and token |
| Google login | ID token; userid and session token |
| verify_user | userid/otp; optional token currently accepted |
| resend_otp | username |
| logout_user | current token |
| get_user_full_profile | userid; user profile and custom fields |
| update_user_password | username/oldpassword/newpassword/confirmpassword; success status |

Specify unconfirmed-account behavior: must login return userid for verification,
and does verification return a usable token or require a subsequent login?
Successful authentication must not silently create a tokenless local session.

For update_user_profile, provide required custom fields, enum values and clear/
omit semantics. The frontend sends an age bucket rather than DOB, and its
completion default gender is 'Male' while radio values are 'male'/'female'.
Confirm accepted values rather than adopting either spelling from frontend.
Are country, native language, referral source and university truly required,
under which conditions? Confirm phone prefix/Unicode-digit normalization.
Document profile-picture upload response, maximum size and retry behavior.

## Learning endpoints: current frontend parsing

Names below use the local_otp_registration_ prefix unless otherwise noted.
These are observations of app parsing, not a guarantee of backend responses.

| Function | Inputs | Currently consumed keys |
| --- | --- | --- |
| get_user_statistics | userid | completed courses, minutes, points, certificates, quizzes |
| get_user_categories_summary | userid | levels; totalcourses/completedcourses/completion_percent/is_open/is_completed/courses |
| get_user_courses | userid | courseid/fullname/lang/image/total_sections/completed_sections/completion_percent/enrolled |
| get_course_details | userid/courseid | courseid/coursename/levelid/levelname/courseimage/completion_percent/completed_topics_total/activities |
| mark_page_completed | userid/cmid | message, followed by course refetch |
| get_quiz_info | userid/quizid | quiz_name/description/timelimit/attempts_allowed/last_attempt_status/can_start/total_questions/grade_total/grade_to_pass |
| start_or_get_quiz_attempt | userid/quizid | attemptid/state/status/total_questions/questions |
| mod_quiz_get_user_attempts | userid/quizid/status=all | attempts, state=inprogress, timestart Unix seconds |
| submit_quiz_question_answer | userid/quizid/attemptid/slot | answer[0][key]=answer; answer[0][value]=array-index string |
| submit_quiz_attempt | userid/attemptid | no typed acknowledgement currently parsed |
| get_quiz_result | userid/quizid | status/message/grade/maxgrade/gradepass/passed/feedback/answers |

Activity parsing uses literal keys topicid, 'Activity name', 'Topic name',
'Activity number', completion_percent, is_open, is_completed, video_url,
video_duration, download_url, cmid and quizid. Question parsing uses slot,
questionid, question_number, question_text and string-list answers. Result
answers use slot/questionname/right/response_summary/selected_answer_index.

Provide minimal examples for: quiz-only lesson, video-only lesson, file-only
lesson, mixed lesson, empty course, resumed attempt, missing/unanswered result,
duplicate answer labels and partially correct answer.

## Decisions that cannot be derived from frontend alone

- Counts: definition of level/course/topic/lesson/activity; explain the reported
  2 versus11 and quiz-only progress0/1 versus1/1 after passing.
- Minutes: measured content/runtime/watch time, collection endpoint, units,
  rounding, replays, background time and update latency. Define video_duration.
- Completion: accepted video completion criterion; file completion on download,
  open or explicit acknowledgement; actual endpoint/module identifier; ordering
  and unlocking rules; idempotent replay.
- Answers: stable answer IDs or index basis, shuffle stability, supported question
  types, duplicate labels, scoring/partial credit and selected-answer nullability.
- Attempts: deadline authority, timelimit=0, saved selections/position on resume,
  status vocabulary, authoritative passed value, finalization acknowledgement,
  race handling and which attempt get_quiz_result selects.
- Download: public/signed/token/cookie authentication, redirects and token
  expiration, MIME/size/Content-Disposition. Include a login-page HTML response
  example. Current downloader uses a separate Dio GET without app auth headers.
- Notifications: mark_notifications_read uses userid and notificationid='0' for
  mark-all. Confirm the sentinel and acknowledgement, pagination/unread counts.
- Complaint: send_complaint uses name/email/subject/message. Provide rejection,
  rate-limit and success schemas rather than relying on response text alone.

Frontend-only repairs (Toast/Back lifecycle, visible form validation, separating
reset stages, HTTP status handling, parsing and stale UI) can be reviewed without
guessing these policies. Server-side grading, minute accounting and unlock
requirements remain open until the actual contract is supplied.
