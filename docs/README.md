# Project documentation

This folder is the durable handoff point for every coding model working on
Radar Labor. Read these files before changing the application:

1. [Current handoff](NEXT_AGENT.md) — exact current state, constraints, and next
   steps.
2. [Roadmap](ROADMAP.md) — scope and completion status by slice.
3. [Work log](WORKLOG.md) — dated record of what each model changed and
   verified.
4. [Bug register](BUGS.md) — symptoms, causes, fixes, and verification.
5. [Decisions](DECISIONS.md) — owner decisions and technical decisions.
6. [Product requirements](PRD.md) and [design system](DESIGN.md).

For a post-S6 proposal on local authentication, role permissions, starter
passwords, and safe workforce spreadsheet use, see the
[authentication and roles draft](drafts/authentication-and-roles-prd-draft.md).

## Handoff rules for every model

- Read `NEXT_AGENT.md`, `DECISIONS.md`, and the relevant roadmap and PRD sections
  before editing.
- Append a dated entry to `WORKLOG.md` after meaningful work. Record what
  changed, what was discovered, what commands actually passed, and what remains.
- For each new defect, add an entry to `BUGS.md` with a stable ID, reproduction
  symptom, root cause, fix, and verification. Update it when the defect changes
  state; do not erase resolved history.
- Update `NEXT_AGENT.md` and `ROADMAP.md` before handing off. State the exact
  files and behavior that are complete, any open risks, and the next bounded
  task. Never say a check passed unless it was run and its result observed.
- Update `DECISIONS.md` whenever implementation resolves an open choice.
- Do not delete caches or generated native assets on this offline workstation.
- Do not add any online-only behavior or remotely fetched app asset. Cloud sync
  remains deferred until the owner asks for it.
