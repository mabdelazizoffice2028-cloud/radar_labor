# Work log

Append one newest-first handoff entry for each model/session. Keep prior entries
so the next model can understand decisions and recoveries.

## 2026-10-23 — V1 local login, roster import, and release handoff

### Implemented

- Added mandatory local login with role-first/account-second selection. First
  run imports a local XLSX/CSV roster, then creates project-manager and HR
  accounts from selected roster entries. Their shared temporary password is
  `123456` and first login requires a new password of at least eight characters.
- Passwords are salted Argon2id hashes calculated in a Dart isolate and stored
  only in the encrypted database. Added logout, password change, account creation,
  and assignment of housing/team scopes. Viewer dashboards cannot change records;
  supervisor navigation and operation controller saves are scoped to assignments.
- Added Android document picker through Storage Access Framework without broad
  file permissions. The parser accepts XLSX/CSV, reads code/name/designation/
  supplier, ignores identity-number columns, rejects duplicate/invalid rows, and
  preserves existing team/housing assignment on update. Files over 25 MB fail.
- Added employee supplier column and Drift schema v3 migration from v2. Updated
  Android launcher display name to `Radar Labour`. English remains first-install
  default; saved language preference remains in effect.
- Added a Gemini handoff document at `docs/SUPABASE_HANDOFF_FOR_GEMINI.md` per
  owner request; it is guidance only and does not add cloud runtime or data sync.

### Verification and recovery

- `dart format lib test`: completed.
- `flutter analyze --no-pub`: **No issues found**.
- `flutter test --no-pub`: **73/73 passed**. First test run exposed two
  architecture violations (presentation imported repositories from another
  feature / Drift); moved the coordinator screens to the app composition layer.
  It also exposed supplier being added twice during the v1→v3 upgrade; migration
  now adds the column only for databases that started at v2, with a v2→v3 test.
- Earlier terminal failures: default Windows Temp blocked Flutter's test
  listener copy; using `work/flutter-profile/android-env.cmd` fixed file access.
  The sandbox then denied local loopback sockets; granting local test-runner
  access allowed the full suite to execute. No runtime network dependency was
  added to the app.
- `flutter build apk --release --no-pub` is running as of this entry; output,
  APK path, size, SHA-256, and package inspection must be recorded after it exits.
- No phone/ADB installation was performed in this environment; hand the owner
  the APK for actual device validation after a successful build.

## 2026-10-23 — Follow-up verification before phone handoff

### What changed and what was checked

- Moved the daily-operation value models from `data/` into `domain/` so both
  presentation and the repository use the same typed models.
- Added the `OperationsStore` domain contract and `OperationsController` under
  `presentation/state/`. Screens now call the controller for roster streams,
  Riyadh business dates, preparation, save, and undo; the data repository
  implements the contract. Screens no longer import or call the data layer.
- Moved Arabic/English worker selection, summary counts, confirmation text, and
  WhatsApp message composition to `features/operations/domain/attendance_summary.dart`.
  The widgets display the prepared text and handle the local copy action.
- Added the message labels to `core/l10n/attendance_message_strings.dart`; the
  domain formatter has no Flutter dependency. The selected worker IDs used for
  persistence now come from the same resolved summary as the displayed count,
  avoiding a mismatch if the live roster changes.
- Added focused unit cases for selected English attendance, zero-presence
  Arabic attendance, and zero-absence English housing summaries.
- Found an untracked `docs/database.csv` containing a workforce roster with
  identity-number and name columns. Removed that copied roster from `docs` and
  recorded the issue without retaining or logging worker values.
- The owner said the APK files were deleted from the output path. The previously
  recorded APK hash therefore does not describe a file currently available to
  transfer and must not be used as the current handoff artifact.
- `dart format` completed for all changed Dart files. Direct `dart analyze` —
  **No issues found**.
- A direct Dart smoke check of the pure domain formatter passed for a selected
  English site worker and verified the message count and persisted worker ID.
- Attempted the full Flutter test suite through the Flutter tool snapshot. It
  stopped at `Waiting for another flutter command to release the startup lock…`
  and was cancelled. No new test or APK build result is claimed for the latest
  domain/message changes. Earlier S6 results (66 tests and an APK build) remain
  historical evidence only.

### Errors encountered and fixed

- The first formatter run found a missing closing brace left while removing an
  old presentation-local formatter. Fixed the source structure.
- Analyzer then found that the new selected-worker records were passed through
  an old `List<String>` parameter. Changed the domain API to carry typed
  `(id, label)` records; the final analyzer run is clean. See B-006.

### Handoff

- Rebuild and rerun Flutter tests when the Flutter startup lock is available;
  then update this log, `BUGS.md`, `PROJECT_REPORT.md`, `ROADMAP.md`, and
  `NEXT_AGENT.md` with the observed results and actual APK hash/path.
- Keep S7 stopped until the owner tests the current S6 build and reviews the
  authentication/roles draft.

## 2026-10-23 — S6 completed and prepared for owner testing

### What changed

- Finished the dashboard date picker and date-scoped coverage warnings for active
  housing locations and teams without a submission. The most recent set/clear
  event determines coverage, and rejected events do not falsely count as
  submitted.
- Added local administrator justification and typed conflict resolution. A
  resolution only hides conflict flags when its kind is recognized; status
  calculation remains unchanged. Text controllers are disposed after sheets.
- Added the fifth dashboard status card, “Not recorded”, alongside on-site,
  housing-only, unknown, and justified.
- Switched the default locale to English for new installs. Existing saved locale
  preferences remain intact; users can switch to Arabic/RTL in Settings.
- Added a selectable, copyable WhatsApp summary after site attendance, showing
  team, business date, present count, and present names/codes. Zero-present
  submissions get an explicit empty message. Housing check already had an
  equivalent absence/no-absence summary. Copying is local; no auto-send or
  network is used.
- Added `docs/drafts/authentication-and-roles-prd-draft.md` per owner's request
  for the next phase. It defines local roles, the initial-password proposal,
  roster import boundaries, privacy constraints, UI flow, tests, and open
  decisions. No sign-in or role code was started in this S6 delivery.
- Reviewed the supplied workforce workbook structure without adding its data
  to the repository. The active-labour sheet includes an ID-number column and
  has no housing/team assignment column; the PRD draft explicitly excludes
  personal identity numbers and calls out the missing assignment source.
- Updated README in Arabic/English, PRD owner amendment, DECISIONS, ROADMAP,
  PROJECT_REPORT, NEXT_AGENT, and this log to reflect S6 and the required but
  not-yet-implemented local login roles.

### Verification

- `dart format` on changed Dart files completed. Dart CLI emitted a telemetry
  temp-file permission warning in this host, but formatting succeeded; Flutter
  commands run through `work/flutter-profile/android-env.cmd` avoid it.
- `flutter analyze --no-pub`: **No issues found**.
- `flutter test --no-pub`: **66 tests passed**, including two new dashboard
  repository tests for coverage transitions and locally persisted resolution/
  justification.
- `flutter build apk --release --no-pub`: succeeded in 86.3 s. APK is
  61,160,446 bytes; SHA-256
  `8478E3023A00493987ECEBA134938E6EC466DBB502D92F710166ABB8BFB18453`.
- Android `aapt` confirmed app label `رادار ليبور`, package
  `com.example.radar_labor`, and no INTERNET/ACCESS_NETWORK_STATE permissions.
  This is a debug-signed test APK, not a store release.
- Phone testing of this APK remains with the owner; existing screenshots only
  prove the previous APK opened.

### Errors encountered and fixed

- A dashboard file placed Dart `part` directives after a class; moved them
  before declarations, then formatter and analyzer ran clean.
- Analyzer found missing event-model import and several collection/control-flow
  lint issues. Added the import and fixed the lints; final analyzer has zero
  issues.
- New Drift companion test fixtures initially used `const` constructors that
  are not const. Removed `const`; both new tests passed and the full suite
  finished 66/66.
- An initial unconstrained test run was interrupted after the compilation
  failure; rerunning the focused tests and full suite succeeded. No product bug
  remains from these build/test issues.

### Handoff

- Stop at S6 and wait for the owner's phone-test feedback. Do not start the
  authentication/roles implementation until the owner has tested/reviewed the
  S6 APK and the draft. See `docs/NEXT_AGENT.md`.

## 2026-10-23 — Housing/site workflows, live status dashboard, and owner device check

### What changed

- Added `EventRepository.appendBatch()`: validates every draft before writing,
  reserves monotonically increasing device sequence values, and inserts all
  events plus the sequence update in one Drift transaction. Added `watchAll()`
  for consumers that need the append-only event ledger across dates.
- Added `features/operations/data/operations_repository.dart` as the boundary
  between operation screens and Drift. It maps database rows to display models,
  queries active housing/team workers, saves a complete daily check, and builds
  inverse-event undo operations without editing or deleting history.
- Added the daily operations screen with housing and site tabs. Housing checks
  support absent-worker marking, explicit confirmation, an explicit zero-absence
  save, eight-second undo, and a locally generated summary that can be copied
  for WhatsApp. Site attendance supports a team roster, a selected-present list,
  explicit zero-present submission, and append-only corrections/undo.
- Connected the home dashboard to the pure `StatusEngine` via
  `StatusSnapshotRepository`. It now calculates four worker status counts,
  unrecorded count, unknown-worker list, SLA warning, and event flags for the
  current Riyadh business date; it refreshes each minute and reacts to Drift
  streams.
- Updated bilingual README scope and roadmap to describe these workflows and
  explicitly disclose that Excel/CSV import does not exist yet.

### Owner evidence and status

- The owner confirmed the installed APK opens and provided six phone captures
  at 08:36–08:37 on 23 October. They show home, empty worker list, add-worker
  dialog with team/housing selectors, empty teams, empty housing, and settings.
  Empty reference lists are expected for a fresh local database. B-001 is moved
  to resolved based on these real-device captures.
- The captures predate the operations/dashboard code in this entry. The updated
  release APK below contains the new workflows; the owner was given its path to
  install and verify them.
- Owner asked whether CSV/Excel import was available. It is not currently
  implemented; worker entry is manual. PRD's original Excel import path used a
  server-side SQL function, but cloud use is deferred. A local file-picker
  workflow would need an added package, which `CLAUDE.md` requires the owner to
  approve first. Do not claim import exists.

### Verification and failures

- `dart format` completed on app, event repository, dashboard repository, new
  operation data/presentation files, and the new repository test.
- Whole-project `dart analyze`: **No issues found**.
- Full Flutter test suite: **61 tests passed** (architecture, encrypted DB and
  migration, status engine, business date, and new operations repository cases).
- First architecture run found operation widgets importing Drift; fixed by
  extracting queries/writes to `OperationsRepository`, after which all five
  architecture tests passed.
- First operation fixture attempted encryption on an in-memory SQLite DB;
  sqlite3mc correctly rejects `PRAGMA key` for temporary/in-memory DBs. The
  repository fixture now uses an in-memory DB without the encryption hook; the
  separate encrypted database suite still tests cipher activation, migration,
  and encrypted persistence. Full suite then passed.
- Initial test compile attempted to use the host's inaccessible Windows temp
  folder. Setting `TEMP`/`TMP` to the ignored project scratch path
  `work/flutter-profile/tmp` resolved it. This changes only the build/test
  process environment.
- A new release APK built successfully at 08:45:53 local:
  `build/app/outputs/flutter-apk/app-release.apk`, 60,242,354 bytes (57.5 MB),
  SHA-256 `2FE4C803D84FEFEDD7A5E6B9BB0F063D3DFF18BD9EEFA72889A8EAA5AD1`. The
  exact copyable path is `C:\my_apps\radar_labor\build\app\outputs\flutter-apk\app-release.apk`.
- `aapt dump badging` confirms label `رادار ليبور`, package
  `com.example.radar_labor`, and no `INTERNET` or `ACCESS_NETWORK_STATE`
  permissions. The APK remains debug-signed and the package id is still the
  Flutter placeholder; it is for owner testing, not store publishing.
- The owner had previously authorized publishing the project to GitHub.
  `git push origin main` failed because the Windows/MSYS Git Credential Manager
  child process could not start and Git had no terminal username prompt. I
  verified the authenticated GitHub connector had push permission, confirmed
  remote `main` was still at `a4708320801d085513863a0fd581b3e7ffb89dbb`, then
  published the reviewed source/docs snapshot to `main` through the GitHub
  Git-data API. No APK, local environment file, key, or build cache was
  included. The local `origin/main` tracking ref may still be stale; read
  `NEXT_AGENT.md` before further Git writes.
- A post-upload content comparison caught that the first Git CLI-to-API transfer
  had truncated the 599,548-byte Cairo font at the shell output limit. I
  reconstructed it in 67 bounded chunks, verified the complete Git blob SHA
  against the local file, then published a follow-up commit replacing the
  incomplete blob. Final GitHub `main` inspection reports the expected font blob
  SHA and exactly 599,548 bytes. The incomplete version was temporary and is not
  the current branch head.

### Still open

- Install and exercise the new housing/site screens, verify undo and persistence
  after relaunch, then run in airplane mode.
- CSV import is still missing. Confirm package approval before adding a file
  picker or CSV dependency.
- Dashboard still lacks arbitrary date selection, missing-housing/team banners,
  dedicated contradiction review/resolution/justification screens, and export.
- Continue reference-data editing/deactivation, employment periods, persistent
  backup/restore, identity/login and role workflows as scope decisions permit.
- Update `NEXT_AGENT.md` with exact artifact/check evidence.

## 2026-10-23 — Release build completed

- Fresh release APK built successfully after latest UI, Manifest, and VS Code
  setting changes: `build/app/outputs/flutter-apk/app-release.apk`.
- Size: 59,258,194 bytes (56.5 MB); timestamp 08:28:55 local. SHA-256:
  `A2489A13A36F96017D75385D6CF95526F027D7B867A01B47BA0508DFEF4AE3F3`.
- `aapt dump badging` confirms application label `رادار ليبور`, expected package,
  and absence of INTERNET and ACCESS_NETWORK_STATE in Release. Flutter's debug
  tooling can still request INTERNET in Debug.
- Build error chain and recovery: resolved duplicate Android preference
  variables; granted access to the cached Gradle lock, Flutter SDK/Git cwd and
  Pub jni CMake output; redirected Kotlin TEMP/TMP and `java.io.tmpdir` into
  project scratch after the sandbox's default temporary backup disappeared.
- Owner will install and check the app on a phone. ADB install and launch remain
  unverified here, so B-001 stays open pending the owner's result.
- Whole-project `dart analyze`: **No issues found**. Previous 50 core tests
  passed in an earlier session; tests were not rerun in this one.
- Added `.vscode/settings.json` with the owner's settings, plus autosave after
  1000 ms and Dart format-on-save.

## 2026-10-23 — Startup UI, local workflows, build recovery

- **Changed:** replaced the empty `MaterialApp(home: Scaffold())` with startup
  loading/error/retry states, a modern Material 3 dashboard, Arabic/English
  language switching, worker/team/housing screens, worker search and add, team
  and housing assignment, and local site/absence event capture. Startup obtains
  a random key from platform secure storage and opens the encrypted Drift DB in
  application support. Cairo and Material icons are packaged locally.
- **Local-only controls:** removed Supabase/connectivity dependencies earlier in
  this delivery. Updated Android Manifest to remove INTERNET and network-state
  permissions from release merging and set the launcher label to رادار ليبور.
  Debug Flutter builds still add INTERNET for the VM service.
- **Other source fix:** added the missing Drift import to the append-only event
  repository so generated `Value` and `OrderingTerm` APIs resolve.
- **README/docs:** rewrote README in Arabic and English to describe implemented
  capabilities and remaining scope; updated roadmap with actual partial state.
- **Checks:** Flutter `analyze` before the final worker-assignment change found
  no errors (only infos). After assignment changes, direct Dart analyzer on
  `lib/app/radar_labor_app.dart` found no compile errors. The owner then
  corrected VS Code/Dart squiggle notices in the dropdowns; I preserved those
  edits, added a `mounted` guard for the remaining async context, and reran
  whole-project `dart analyze`: **No issues found**. Previous session's 50
  core database/time/status tests passed; they were not rerun in this turn.
- **APK evidence:** APKs exist under `build/app/outputs/flutter-apk/` with
  2026-10-23 timestamps (debug 180,820,482 bytes; release 50,506,602 bytes).
  `aapt` confirmed the release package was built before the last UI assignment
  and Manifest edits: it still had the old `radar_labor` label and
  ACCESS_NETWORK_STATE. Treat it as stale. The release had no INTERNET
  permission; debug did include INTERNET (Flutter debug tooling).
- **Build error history:** first Gradle run found conflicting Android
  preference paths (`ANDROID_SDK_HOME` vs `ANDROID_USER_HOME`); removed the
  deprecated duplicate from the ignored local runner script. Then access to a
  cached Gradle lock file was denied; permission to the existing Gradle cache
  was granted. Later Gradle daemon/configuration attempts failed with
  `The settings are not yet available for build`; the updated APK is therefore
  **not confirmed built**. Keep old APKs untouched; do not claim them as final.
- **Device install:** still unverified; ADB cannot initialize its `.android`
  home in the sandbox. No screenshot/runtime evidence exists from a phone.
- **Current next actions:** diagnose Gradle build invocation on the actual
  `android` root, produce and inspect a fresh release APK, then finish PRD
  workflows and update defect/roadmap/report records. Do not run `flutter
  clean`, upgrade dependencies, or remove caches.

## 2026-10-23 — Offline completion request

- **Request:** finish the application after the owner installed it and saw a
  blank screen; make it modern, Arabic/English, offline/local, and bundle fonts
  and icons. Maintain durable model handoffs and defect history in `docs/`.
- **What I found:** `lib/app/radar_labor_app.dart` returns a `MaterialApp` whose
  home is an empty `Scaffold`; this is the direct cause of the blank screen.
  S0 is present, while employee/event tables and all workflow screens are not.
- **Owner scope change:** local-only operation supersedes the cloud-required S2
  plan for the current delivery. See `DECISIONS.md` and the amendment at the top
  of `PRD.md`.
- **Environment:** Flutter 3.47.7 and Dart 3.13.5 were verified in the previous
  session. The project is connected to `origin/main` on GitHub.
- **Assets:** Cairo was not found in the project, Pub cache, or Windows font
  directory. A search of the owner-provided setup/tools directories found no
  Cairo TTF. Network was authorized to fetch a bundled licensed font asset; the
  font has not yet been added at this checkpoint.
- **Verification this session:** read-only repository inspection only. No
  application tests/build were run in this session yet.
- **Current next step:** implement S1 pure-Dart status rules with tests first,
  then atomic local event persistence. Replace the empty root with an explicit
  localized startup/loading/failure flow before installing a new APK.
- **Open risk:** ADB currently reports that its default `\.android` directory
  cannot be created in this execution environment. This is a host/sandbox issue,
  not yet evidence of an app defect. Do not claim a device install was verified.

## 2026-10-23 — V1 release verification and handoff

- **Test result:** `flutter test --no-pub` passed **73/73** (exit 0). This includes local auth/password handling, roster parser/duplicate rejection, schema migration, attendance summaries, and architecture checks. An earlier run had 3 failures; the causes were the migration adding `supplier` twice on the v1→v3 path and presentation imports crossing feature/database boundaries. Both were fixed, a migration fixture was corrected to include Settings, and the full suite then passed.
- **Static analysis:** `flutter analyze --no-pub` returned `No issues found!` (exit 0).
- **Release:** `flutter build apk --release --no-pub` completed (exit 0). Copy: `outputs/Radar Labour.apk`; size 62,815,890 bytes; SHA-256 `B8822F50D0BC9546BDD1D0EB3B101B1316AC03F177D1C64654DB6A6AE878AC41`.
- **Package inspection:** `aapt` confirms label `Radar Labour`, application id `com.example.radar_labor`, version `1.0.0`. No INTERNET or ACCESS_NETWORK_STATE permission is present. APK stays local and is ignored by Git.
- **Device check:** no install/runtime test on the owner's phone was performed in this session. The owner should install the handoff APK and test role access, roster import, persistence after restart, and airplane-mode operation.
- **GitHub:** source/docs push is the remaining handoff action for this session; do not include APKs, employee roster data, local credentials, or signing files.
