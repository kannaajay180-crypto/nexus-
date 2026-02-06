## Summary
**Goal:** Build a responsive Campus Companion web app with secure Internet Identity login + role-based access, and four core modules: Live Mess Menu, Email Summarizer (on-platform), Travel Pool Cab, and Live Timetable.

**Planned changes:**
- Implement Internet Identity authentication and RBAC (Student/Admin), persisting user profiles in the Motoko backend and enforcing admin-only write operations (including a first-admin bootstrap approach).
- Create a responsive UI shell with mobile/desktop navigation and routes for the four modules, each with clear titles and empty states.
- Live Mess Menu: backend CRUD by date; frontend view for today/upcoming days; admin-only add/edit UI; persistent storage.
- Email Summarizer: accept pasted email text (optional subject/date) and generate deterministic outputs (summary, category, priority, sentiment, deadlines); store items in a searchable archive; spam marking + hide/show; user-managed interest keywords and relevance sorting with matched-keyword explanations.
- Travel Pool Cab: create/browse/filter trips (destination, pickup, date/time, seats, notes); join-request flow with owner accept/decline and seat updates; cost-splitting calculator; emergency contacts; shareable trip details view; report-issue flow with admin report list; post-trip participant ratings with aggregation on profiles; optional carbon estimate using fixed emission factors; “real-time” list refresh via polling (React Query) with a basic toggle to reduce/disable polling.
- Live Timetable: personal schedule CRUD; semesters and switching; admin update notices for cancellations/room changes with prominent display for affected users; exams + countdowns; free-period finder; conflict detection; smart in-app reminders; ICS export; optional office hours fields; manual room occupancy status with timestamp and role-controlled writes.
- Add developer-facing documentation of backend candid methods with authorization rules and example request/response shapes by module.
- Add responsible data handling: privacy page, consent messaging where user content is stored, delete-my-data controls, minimized PII with restricted access to sensitive fields (e.g., emergency contacts), and admin audit logging with an admin-viewable log.
- Apply a coherent, distinctive visual theme (not default blue/purple) across navigation, pages, cards, and forms, with accessible contrast.
- Add and use generated static visual assets (logo + module icons) from `frontend/public/assets/generated` in header and module navigation.

**User-visible outcome:** Users can sign in with Internet Identity, navigate a mobile/desktop-friendly campus utility app, view mess menus, summarize and search stored emails with relevance ranking, create/join/rate carpool trips with safety features and polling-based refresh, and manage a live timetable with admin notices—within a consistent themed UI and with privacy/data controls.
