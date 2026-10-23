# Agent Instructions — Radar Labour

This file is the project-wide starting point for any coding model or developer.
It applies to Codex, Claude, Gemini, Copilot, and other tools that support
repository instructions. If a tool does not discover `AGENTS.md` automatically,
open it manually or paste it into that tool's project instructions.

## Start every session here

1. Check `git status --short --branch` and the recent commits. Preserve existing
   user changes; never assume the working tree is disposable.
2. Read `docs/README.md`, `docs/NEXT_AGENT.md`, and
   `docs/DEVICE_AND_MODEL_HANDOFF.md`.
3. Read `docs/DECISIONS.md`, the relevant sections of `docs/PRD.md`,
   `docs/DESIGN.md`, `docs/ROADMAP.md`, `docs/BUGS.md`, and `docs/WORKLOG.md`
   before touching related code.
4. Treat the most recent owner decisions and the current handoff documents as
   the source of current project status. Older plans in `CLAUDE.md` or the PRD
   may describe superseded cloud or slice plans; do not revive them without a
   new owner request.

## Product boundaries

- Radar Labour V1 is a local-first Flutter Android workforce operations app.
- English is the first-install default; Arabic and RTL are supported.
- Runtime data, fonts, and UI assets are local. Do not add a network dependency,
  online asset, Supabase setup, or cloud sync unless the owner explicitly changes
  this product decision.
- Keep employee identity numbers, real rosters, passwords, signing keys, and
  other private data out of Git, logs, test fixtures, screenshots, and docs.
- WhatsApp text is generated locally for review/copy. Never send it
  automatically.
- The owner reported that password change now works and explicitly said not to
  modify anything at that time. The password dialog's missing validation
  feedback is documented as B-009. Do not change authentication behavior unless
  the owner requests it or reports a new failure.

## Engineering rules

- Keep business rules in `domain`, persistence and file access in `data`,
  orchestration in controllers/state, and rendering/input in `presentation`.
  Widgets must not own business logic or access database/repository internals.
- Follow existing feature boundaries, naming, localization, and test patterns.
  Inspect architecture tests before introducing dependencies between layers.
- Make the smallest coherent change for the requested outcome. Do not silently
  expand product scope, alter stored data semantics, or change credentials.
- Never run `flutter clean`, delete `.dart_tool`, remove Flutter/Pub/Gradle
  caches, or delete files under `work/`; the Windows workstation depends on
  these local assets for offline builds.
- Never run destructive Git commands (`reset --hard`, `clean`, force push,
  history rewrite) or replace/merge branches without explicit owner direction.
- Do not modify the app or rebuild APK when the task asks only for documentation.

## Verification and handoff

- Run only checks relevant to the change. Do not claim a test, build, phone
  install, offline-mode check, or GitHub push passed unless its result was
  observed.
- For code changes, use the local environment helper described in
  `docs/DEVICE_AND_MODEL_HANDOFF.md`; prefer `--no-pub` when using cached
  dependencies. Diagnose a Flutter lock or environment failure instead of
  deleting locks or caches.
- After meaningful work, update `docs/WORKLOG.md`. Record new defects and their
  status in `docs/BUGS.md`; update `docs/NEXT_AGENT.md`, `docs/ROADMAP.md`, and
  `docs/PROJECT_REPORT.md` whenever their stated status changes.
- Handoff notes must say what changed, what was actually checked, what failed
  and how it was addressed, what remains unverified, and the next bounded step.
  Never include private workforce data or secrets.

## Current source of truth

Read `docs/README.md` for the ordered document map. The detailed current state,
environment, known issues, and safe continuation steps are in
`docs/DEVICE_AND_MODEL_HANDOFF.md`. If those docs conflict with this file, use
the newer explicit owner decision, then the newest dated handoff/work log, and
record the discrepancy instead of guessing.
