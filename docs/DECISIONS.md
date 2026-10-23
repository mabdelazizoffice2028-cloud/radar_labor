# DECISIONS — Radar Labor V1

## Locked product decisions
None supplied yet. Owner: paste the locked decisions here (app name,
applicationId, SLA, day cutoff, inspection time, buildings/supervisors).

## Agent decisions
- 2026-10-23 — Drift + SQLite3MultipleCiphers, not sqflite. Reason: PRD §2/§8
  (encryption, watch() streams, migrations). Owner's chat message mentioned sqflite; PRD wins.
- 2026-10-23 — Encryption is verified in every build mode, not only release.
  Reason: simpler, stricter, and tests catch a missing hook early.
- 2026-10-23 — DB file location is injected into `openEncryptedDatabase`.
  Reason: path_provider is not in PRD §2; adding it needs owner approval (CLAUDE.md §2 case 3).
- 2026-10-23 — Defaults used until owner decides: SLA 120 min, day cutoff 03:00 (PRD §5/§6).
- 2026-10-23 — Raw hex key via `PRAGMA key = '<hex>'`. Reason: matches drift docs; hex-only keeps interpolation safe.
- 2026-10-23 — Drift schema export stored in `lib/core/database/schemas/`. Reason: keep versioned schema history beside the database implementation.
- 2026-10-23 — Open Drift on a background isolate and normalize `DriftRemoteException` at the startup boundary. Reason: Drift 2.35 wraps setup exceptions; the UI must receive typed database failures.
- 2026-10-23 — Track the Gradle wrapper scripts and JAR. Reason: fresh clones need the pinned Gradle 9.3.1 launcher to build.
