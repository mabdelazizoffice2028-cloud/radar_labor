# CLAUDE.md — Radar Labour V1 (رادار ليبور)

> **Required project context:** First read the repository-wide [`AGENTS.md`](AGENTS.md),
> then [`docs/README.md`](docs/README.md) and [`docs/DEVICE_AND_MODEL_HANDOFF.md`](docs/DEVICE_AND_MODEL_HANDOFF.md).
> Those files carry the current owner decisions, actual workstation state, and
> handoff evidence. This file preserves Claude-specific engineering conventions.
> If an older slice, cloud, or release instruction below conflicts with the
> latest explicit owner direction or dated handoff, follow the newer direction
> and update the docs. Current V1 is local-only; Supabase/sync are deferred.

Offline-first Android app (Flutter) that records where each worker is each day, so management sees "unknown" workers every morning. Not an attendance/payroll/GPS system.

You are the sole implementer. The owner is a software architect who reviews your work. **Code quality is the top priority. Token cost is not.** Never shorten, skip, or simplify work to save tokens. Do spend effort on reading the docs and verifying your work.

---

## 1. Document map and precedence

| File | Role | When to read |
|---|---|---|
| `docs/PRD.md` (Part 1 + Appendix) | WHAT to build: scope, data model, engine rules, sync, security, screens, acceptance criteria per slice | Always read the sections of the current slice |
| `docs/DECISIONS.md` | Locked product decisions + design tokens + decisions you made yourself | Read fully at session start |
| `docs/DESIGN.md` (if present) | Colors, typography, spacing, component rules | Before any UI work |
| `docs/WHY.md` | Rationale only | Only when you doubt a decision. Never re-litigate decisions from it |

**Precedence on conflict:** `DECISIONS.md` > `docs/PRD.md` Part 1 > PRD Appendix > this file's technical defaults. This file always wins on *process and code quality*. Items marked `[مقترح]` in the Appendix are proposals: treat them as accepted unless `DECISIONS.md` overrides them.

**Current owner overrides (2026-10-23):** complete the requested V1 as a local-first, fully usable offline app. Do not initialize or require Supabase/network at runtime; cloud sync is deferred. Support Arabic and English, bundle fonts/assets, and update `docs/WORKLOG.md`, `docs/BUGS.md`, `docs/ROADMAP.md`, and `docs/NEXT_AGENT.md` at every handoff so another model can continue safely.

Never paste or re-read the whole PRD. Read the sections for the current slice, and grep for the rest.

---

## 2. Autonomy policy (do not ask unless required)

**Decide yourself, then log it** (one line under "Agent decisions" in `docs/DECISIONS.md`: date, decision, reason) for anything the docs leave open:
colors, spacing, typography, icons, widget choice, naming, file placement, copy wording, empty/error/loading states, animations, minor UX, internal APIs, test structure, constants, validation messages, and any detail whose wrong choice is cheap to change later. Pick the most conventional, simplest, most consistent option with what already exists.

**Ask the owner only in these five cases:**
1. Two documents contradict each other and precedence in §1 does not settle it.
2. A choice risks data loss, data leakage, or weakens security/privacy.
3. You need to add/upgrade/remove a package, or change anything in PRD §2.
4. The work would go outside V1 scope or the current slice.
5. An irreversible action (deleting data or branches, rewriting history, destructive migration on existing data).

**How to ask:** one message, batched, each question with your recommended answer and the default you will use if not answered. Keep working on everything that does not depend on the answer. Never ask something the docs already answer; search them first.

---

## 3. Session workflow (one slice per session)

1. Read `DECISIONS.md`, the PRD sections for the slice, and its acceptance criteria (PRD §10).
2. State a short plan (files to create/change, tests to write). No long preamble.
3. **Tests first** for `core/status` and `core/sync` (write failing tests, then implement). For other code, tests alongside.
4. Implement in small, reviewable steps. Each step compiles.
5. Run, in order, and fix until clean: `dart format .` → `flutter analyze` (zero issues, no ignores without a justification comment) → `flutter test`. Run the build_runner only when Drift tables change.
6. Self-review against the checklist in §14.
7. Commit (§12). Update `DECISIONS.md` and any doc whose truth changed.
8. Final report (§13).

**Definition of done for a slice:** acceptance criteria in PRD §10 met, tests green, analyzer clean, no file over limits, no TODO left untracked, docs updated, committed.

Do not start the next slice in the same session.

---

## 4. Architecture (non-negotiable)

### 4.1 Layers and dependency direction
`presentation → (notifier/controller) → domain → data → core`. Dependencies point inward/downward only. Features depend on `core`, never on each other. `core/status` is pure Dart.

```
lib/
  main.dart
  app/                   bootstrap, router (go_router), theme, l10n wiring
  core/
    constants/           ALL magic values: durations, limits, keys, sizes
    database/            Drift tables, DAOs, migrations, encryption setup
    events/              EventRepository, device_seq, business_date
    status/              Pure Dart status engine (NO flutter/drift/riverpod imports)
    sync/                outbox, push, pull, scheduler
    supabase/            client init, rpc wrappers
    auth/                session, password hashing, app lock
    time/                Riyadh fixed UTC+3, injectable Clock
    ui/                  shared dumb widgets, RTL helpers, design tokens
    l10n/                single Arabic strings file
    errors/              typed failures (sealed)
  features/
    <feature>/           login, roster, housing_check, site_attendance, dashboard, ...
      data/              feature-only providers/queries
      domain/            feature-only rules (e.g. WhatsApp text), pure Dart
      presentation/
        state/           Notifier/AsyncNotifier + immutable state classes
        screens/         one screen per file
        widgets/         small dumb widgets
test/                    mirrors lib/
```

### 4.2 Dumb UI
Widgets only: `ref.watch(...)` ready-to-render state, draw it, and forward user actions to the notifier (`ref.read(provider.notifier).onXxx()`). Forbidden in widgets: computing values, filtering/sorting/mapping data, business conditions, date logic, database/Supabase/repository access, formatting rules beyond calling a formatter from core, navigation decisions based on data rules. If you feel an `if` about business meaning in `build()`, move it to the notifier or domain.

### 4.3 State management
Riverpod **manual**, no codegen: `Notifier`, `AsyncNotifier`, `StreamProvider`, `Provider`. Only notifiers talk to repositories and turn results into UI-ready state. State classes are immutable (`final` fields, `const` constructors, `copyWith`, value equality) and modeled with `sealed` classes when they have distinct variants (loading/data/error). Exhaustive `switch` on sealed types; no `default` that hides missing cases.

### 4.4 Data and event-sourcing invariants
- Drift/SQLite (encrypted, SQLite3MultipleCiphers) is the single source of truth for reads, via `watch()`.
- **Every write goes through `EventRepository.append()` in one transaction** (event + `device_seq`). No other write path exists, ever.
- Events are append-only: no update, no delete. Cancel = `action: clear` on the same key.
- State is **computed on read**, never stored.
- Ordering: `received_at`, then `device_seq`; never trust `device_time` for ordering.
- Late events are never rejected, only flagged `late`. A rejected event never blocks the rest of a batch.
- `ingest_events` and sync pushes must be idempotent by `event_id`.
- Business date = Riyadh fixed UTC+3 via the injectable clock in `core/time`. Never call `DateTime.now()` outside it.

### 4.5 Feature isolation
No imports between `features/*`. Anything shared moves to `core`. Add a lint/test (`test/architecture_test.dart`) that fails if a feature imports another feature, if `core/status` imports Flutter/Drift/Riverpod, or if any widget file imports `core/database` or `supabase`.

---

## 5. Code quality rules

- **One file = one responsibility** (usually one class). Target ≤ 200 lines, hard limit 300 (generated `*.g.dart` excluded). Over the limit → split immediately, do not defer.
- **Functions** ≤ 40 lines, ≤ 4 parameters (use a parameter object beyond that). **Nesting** ≤ 3 levels; use guard clauses and early returns. No nested ternaries.
- **Names** state intent in English: `HousingCheckNotifier`, not `HCController`. No abbreviations except universal ones (id, url). Booleans read as questions (`isLate`, `hasPendingEvents`). Enums and event types in English; Arabic only in the l10n file.
- **No magic values.** Numbers, durations, strings, keys, thresholds → named `const` in `core/constants` (or feature-local constants file). The SLA, day-cutoff, batch size, retry bounds, tap-target size, undo window all live there.
- **Types:** no `dynamic`, no unchecked casts, no `!` unless provably safe and commented. Prefer records/sealed classes/patterns (Dart 3.13) over loose maps. Parse JSON once at the boundary into typed models; never pass `Map<String, dynamic>` through the app.
- **Immutability:** `final` by default, `const` wherever possible, unmodifiable collections in state.
- **Comments** explain *why*, never *what*. Public APIs in `core` get a short `///` doc. Delete commented-out code. `TODO` must read `TODO(slice-Sx): ...` and be listed in the final report.
- **No dead code**, no unused params, no speculative generality. Abstract only on the third real duplication; do not create a use-case class per action.
- **Prefer small pure functions** in domain/core, trivially testable without Flutter.
- No `print`/`debugPrint`; use the `core` logger abstraction.

---

## 6. Error handling

- Never write an empty `catch`, never swallow exceptions, never catch `Error`. Catch the narrowest type, convert it to a typed `Failure` (sealed class in `core/errors`), and surface it as explicit error state the UI can render.
- Sync failures are data: record `reject_reason`/retry state; never lose an event because a call failed.
- Fail closed on security: if encryption is not active (`PRAGMA cipher` empty) the app must not open the database in release.
- User-facing messages come from the l10n file, short, in Arabic, actionable. Technical details go to the logger only.

---

## 7. Security and privacy

- No iqama/ID numbers or any `employee_identity` data on any phone. Supervisors download reference data without identity fields.
- Only the publishable key via `--dart-define`. The secret/service key never enters the app or the repo. No secrets in code, tests, fixtures, or logs.
- Never log names, codes, or other worker data; log ids and counts only.
- Password: Argon2id in an Isolate; never store or log plaintext.
- `allowBackup="false"`. Keys in `flutter_secure_storage`.
- Every RLS policy and the role checks in `ingest_events` get a test per role (admin, housing supervisor, site supervisor, observer).
- SQL: parameterized only. `SECURITY DEFINER` functions set `search_path` explicitly and validate the authenticated user.

---

## 8. UI rules

- Imports: `package:material_ui/material_ui.dart` only. Never `package:flutter/material.dart` or `cupertino.dart`. No third-party UI packages.
- Arabic RTL everywhere; test every screen in RTL. Tap targets ≥ 56dp. High contrast.
- **No hardcoded colors, text styles, spacing, radii, or strings in widgets.** All come from the theme/tokens (`core/ui`, values defined in `docs/DESIGN.md` / `DECISIONS.md`) and from the single l10n file.
- Semantic colors are fixed: green = on site, yellow = housing only, red = unknown, blue = justified.
- Every screen implements loading, empty, error, and offline states.
- `build()` is pure and cheap: no I/O, no heavy computation, no side effects. Use `const` widgets, `ListView.builder` for lists, `select` to limit rebuilds. Split big widgets into small classes (not helper methods returning widgets).
- Supervisor flow principle: open → mark → save → leave. More than three steps for a supervisor task is a design bug.
- Accessibility: semantic labels for icon-only buttons, no information conveyed by color alone (pair with icon/text).

---

## 9. Testing

- Table-driven tests for `core/status` covering every state and flag in PRD §6 and the Appendix test list (>25 cases). Tests double as the engine's specification.
- Sync tests per PRD §10 S2: mid-send cut, duplicate batch, lost reply, wrong phone clock, 1000 events, set-then-clear offline, rejected event does not block others, two devices one supervisor. No screen work before these pass.
- Inject the clock, the transport, and the database. No real network, no real time, no randomness in unit tests (seed or inject).
- Migration tests for every schema version. RLS tests against local Supabase.
- Test names describe behavior (`unknownWorker_afterJustification_becomesJustified`).
- **Never** weaken, skip, or delete a test to make it pass. A failing test means the code or the spec is wrong; fix the cause or report the conflict.
- Widget tests for each screen's states; keep them logic-free (logic is tested in notifiers/domain).

---

## 10. Dependencies, versions, environment

- Versions and packages are fixed by PRD §2. Never run `pub upgrade`, never add a package, never edit the version table without explicit owner approval (§2 case 3). Commit `pubspec.lock`.
- **Do not rely on memory for package APIs.** `material_ui`, `go_router` 18, `drift` 2.35, `sqlite3` 3.x, `riverpod` 3.x, `local_auth` 3, `flutter_secure_storage` 10 and `cryptography` are recent. Check the real API in the installed package source under the pub cache / `.dart_tool` and in `pubspec.lock` before using it. If a signature differs from what you expected, trust the source.
- The environment may be offline. Never run `flutter clean`. Do not run commands that need the network unless the owner says it is available.
- Keep the Flutter version pinned as in PRD §2.

---

## 11. Database and sync changes

- Any table change = new `schemaVersion` + migration + migration test, in the same commit.
- Cloud schema changes live in `supabase/migrations/` as ordered SQL files, never edited after being applied; add a new one.
- Local and cloud event columns stay aligned (PRD Appendix §2.2). Document any intentional difference.

---

## 12. Git

- One slice per branch (`slice/s2-sync`), small commits, each compiling and green.
- Conventional commits: `feat(sync): ...`, `fix(status): ...`, `test(...)`, `refactor(...)`, `docs(...)`, `chore(...)`.
- Never commit secrets, `.env`, build outputs, or local DB files. Never force-push or rewrite shared history.

---

## 13. Reporting (end of every session)

Be honest and exact. Short report:
1. What was completed (mapped to acceptance criteria).
2. What you actually ran (`analyze`, `test`, build) and the real results. If you could not run or verify something, say so; never claim green without running it.
3. Decisions you took (also logged in `DECISIONS.md`).
4. Open TODOs, risks, deviations from the PRD (with reason).
5. Questions that need the owner (only §2 cases), each with your recommended answer.
6. Next slice.

Do not pad the report. Do not praise your own work.

---

## 14. Pre-commit self-review checklist

- [ ] Any business logic left in a widget? Any widget touching DB/Supabase?
- [ ] Any write path other than `EventRepository.append()`?
- [ ] Any feature importing another feature? Any Flutter import in `core/status`?
- [ ] Any file > 300 lines, function > 40 lines, nesting > 3?
- [ ] Any magic number/string/color/size/hardcoded Arabic text?
- [ ] Any empty catch, swallowed error, `dynamic`, unjustified `!`?
- [ ] Any `DateTime.now()` outside `core/time`? Any PII in logs?
- [ ] State classes immutable? sealed + exhaustive switches?
- [ ] Tests written first for engine/sync; no test weakened?
- [ ] Analyzer clean, formatted, tests green, docs updated?
- [ ] Did I ask something the docs already answer?

---

## 15. Absolute prohibitions

Spaghetti, god files/classes, business logic in UI, cross-feature imports, a second write path, stored derived state, mutating or deleting events, silent catches, `flutter/material.dart` imports, codegen for Riverpod, adding or upgrading packages unasked, hardcoded colors/strings, secrets in the repo, worker data in logs, claiming unverified work is done.

