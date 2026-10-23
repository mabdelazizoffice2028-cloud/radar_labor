# Supabase integration log — 2026-10-23

## Connection and startup

- Target project: [Radar Labour Supabase](https://supabase.com/dashboard/project/tifmobthyunnxqboyaoo), URL `https://tifmobthyunnxqboyaoo.supabase.co`.
- The Flutter client uses the supplied **publishable key** from `lib/core/constants/supabase_config.dart`. No secret/service-role key is present in the mobile code.
- `supabase_flutter` `^2.18.3` is a direct dependency and is locked in `pubspec.lock`.
- Startup opens and seeds the encrypted local Drift database first. It then initializes the optional Supabase client. A Supabase setup exception is logged by type and does not prevent local app startup.
- Android release now has the `INTERNET` permission so the configured client can make requests. Offline workflows continue to use the local database.
- Supabase initialization is **not** sync: no local event upload, download, conflict resolution, or remote authentication is wired into the current local login flow.
- A read-only `GET /auth/v1/health` request using the supplied publishable key returned **HTTP 200** and the GoTrue health response. This verifies that the configured project's Auth endpoint is reachable. Auth settings, PostgREST schema exposure, SQL execution, RLS behavior, and device connectivity remain unverified. A successful local `Supabase.initialize()` itself only constructs the SDK client; it does not prove server connectivity.

## Role and authorization model

The app already has local role-aware login and navigation. Project Manager and HR receive the admin interface; housing supervisors see housing operations, site supervisors see site operations, and Viewer sees the dashboard in read-only mode. `OperationsController` filters housing/team data by assigned local scope and guards save/undo operations. Existing local supervisor account creation, activation, and scope assignment is exposed through admin-only screens. No local Drift schema or data semantics were changed in this integration.

The SQL migration at `supabase/migrations/20261023000100_radar_labor_rbac.sql` defines hosted tables and RLS:

- `attendance.users`: Auth-linked profile, with `admin`, `hr`, `housing_supervisor`, `site_supervisor`, and `viewer` role values; newly created Auth users default to inactive `viewer`.
- `attendance.teams`, `attendance.housings`, `attendance.user_scopes`: team/housing references and explicit account assignments.
- `attendance.employees`: workforce rows with optional team and housing scope links; no identity-number columns.
- `attendance.events`: attendance/housing events, constrained by RLS to admin writes or supervisor writes inside the assigned scope. Viewer access is read-only.
- RLS policies allow admin/HR to manage profiles, scopes, teams, housings, and employees. Supervisors can read matching assigned scope rows and insert scoped events only. Viewer can read dashboard source rows and cannot mutate them.
- An Auth trigger creates every new profile as inactive `viewer`; it does not trust metadata for role or activation.

Apply the migration in the Supabase SQL editor or with an authorized Supabase CLI session after review. Keep public sign-ups disabled and configure `attendance` as an exposed API schema if it will be queried through PostgREST. Provision the first admin out of band using the SQL editor and the intended Auth user's UUID. Never put a service-role key in the app.

**The migration has not been applied to the hosted project.** The supplied project URL and publishable key cannot execute administrative SQL or create/activate Auth accounts. Existing app login remains local; Supabase Auth and remote account-management calls are not wired into its screens.

## Files changed

- `pubspec.yaml`, `pubspec.lock` — added/locked `supabase_flutter`.
- `linux/flutter/generated_plugin_registrant.cc`,
  `linux/flutter/generated_plugins.cmake`,
  `macos/Flutter/GeneratedPluginRegistrant.swift`,
  `windows/flutter/generated_plugin_registrant.cc`,
  `windows/flutter/generated_plugins.cmake` — generated plugin registration.
- `README.md` — corrected the current cloud configuration status.
- `lib/core/constants/supabase_config.dart` — public project URL and publishable key.
- `lib/app/radar_labor_app.dart` — optional Supabase initialization after local DB startup, with local-startup fallback.
- `android/app/src/main/AndroidManifest.xml` — allow Internet access for Supabase requests.
- `supabase/migrations/20261023000100_radar_labor_rbac.sql` — hosted schema and RLS baseline; not applied.
- `docs/supabase_integration_log.md` — this session record.
- `docs/DECISIONS.md`, `docs/PRD.md`, `docs/ROADMAP.md`, `docs/NEXT_AGENT.md`, `docs/DEVICE_AND_MODEL_HANDOFF.md`, `docs/PROJECT_REPORT.md`, `docs/WORKLOG.md` — owner direction and status handoff.

## Verification and next step

- `flutter pub get` completed successfully and resolved `supabase_flutter 2.18.3`.
- `flutter analyze --no-pub` completed successfully: `No issues found!`.
- The project's Auth health endpoint returned HTTP 200. No data was written.
- No tests, Android build, hosted SQL apply, or phone check were run in this session.
- Next bounded step: review/apply the SQL in the intended Supabase project, provision an initial admin securely, then implement the separately scoped Auth/session and sync integration while preserving local-first behavior.
