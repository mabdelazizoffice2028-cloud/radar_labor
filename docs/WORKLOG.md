# Work log

Append one newest-first handoff entry for each model/session. Keep prior entries
so the next model can understand decisions and recoveries.

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
