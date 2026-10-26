# Work log

Append one dated handoff entry for each model/session. Keep prior entries so the
next model can understand decisions and recoveries. The newest handoff is at the
top of the log.

## 2026-10-23 — App icon and Android Release APK

- Replaced the default Flutter launcher mark with a Radar Labour icon: a hardhat
  over radar arcs, with a small amber signal point. Added Android adaptive icon
  resources and regenerated legacy launcher PNGs at mdpi through xxxhdpi.
- Built Release with `flutter build apk --release --no-pub` via the local
  `android-env.cmd` helper. Gradle completed successfully in 256.7 seconds.
- Copied the artifact to `outputs/Radar Labour.apk`: 68,077,931 bytes,
  SHA-256 `39007DAEF137228E3F3A873F0E25AC1C03659A21ADBEB8B2237F9C562040D630`.
- `aapt dump badging` confirmed package `com.example.radar_labor`, label
  `Radar Labour`, and INTERNET permission. `aapt dump resources` showed the
  adaptive foreground/background and launcher density resources in the APK.
- No phone install or runtime test was performed. Release signing remains the
  existing local debug signing configuration; this artifact is for testing.

## 2026-10-23 — Supabase client and RBAC foundation

- **Owner request:** configure the supplied Supabase project using the
  publishable key, preserve local startup, prepare role-based authorization,
  and record the SQL and file changes.
- Added `supabase_flutter ^2.18.3`, client configuration, and optional startup
  initialization after encrypted Drift opening. An initialization exception is
  reported by type and does not prevent local startup. Android main manifest
  allows INTERNET for cloud calls.
- Existing local auth/navigation already routes Project Manager/HR to admin
  tabs, Viewer to read-only dashboard, and supervisors to scoped operations.
  `OperationsController` filters and guards assigned team/housing access. No
  Drift schema or local business behavior changed.
- Added `supabase/migrations/20261023000100_radar_labor_rbac.sql` defining
  Auth-linked profiles, five roles, team/housing scopes, employees/events, and
  RLS policies. This migration is a reviewable artifact only; it has **not**
  been applied to the hosted project. Hosted Auth, PostgREST exposure, and
  remote account provisioning remain unverified; app login and sync are still
  local-only.
- **Files:** `pubspec.yaml`, `pubspec.lock`, `lib/app/radar_labor_app.dart`,
  `lib/core/constants/supabase_config.dart`,
  `android/app/src/main/AndroidManifest.xml`, the SQL migration, and Supabase
  status/handoff documents listed in `supabase_integration_log.md`.
- **Checks observed:** `flutter pub get` completed with exit code 0 and resolved
  `supabase_flutter 2.18.3`; `flutter analyze --no-pub` completed with
  `No issues found!`. Read-only `GET /auth/v1/health` with the publishable key
  returned HTTP 200. No tests, build, SQL deployment, or device validation were
  run.
- **Next bounded work:** review and apply SQL with authorized project access;
  then design and implement Supabase Auth/session management and safe local-first
  sync without storing an administrative key in the app.

## 2026-10-23 — إنجاز المرحلتين 2 و3: واجهة تسجيل الدخول، مستودع المصادقة، جداول AppUsers/UserScopes

### ما تم إنجازه

**المرحلة 2 — واجهة المصادقة:**
- إعادة كتابة `lib/app/auth_gate.dart` بالكامل: إزالة الـ `MaterialApp` المتداخل، اختيار الحساب من قائمة منسدلة بدون اختيار دور يدوي، دعم إظهار/إخفاء كلمة المرور، معالجة حالات التحميل والأخطاء، دعم تغيير كلمة المرور المؤقتة، شاشة إعداد أولي لاستيراد كشف العمال وإنشاء حساب مدير المشروع وHR.
- إنشاء `lib/app/widgets/auth_login_form.dart`: نموذج تسجيل الدخول التفاعلي مع أخطاء مضمّنة (176 سطراً).
- إنشاء `lib/app/widgets/auth_setup_view.dart`: واجهة الإعداد الأولي باستيراد القائمة واختيار المديرين (160 سطراً).
- إنشاء `lib/app/widgets/change_temporary_password_dialog.dart`: حوار استبدال كلمة المرور المؤقتة (120 سطراً).

**المرحلة 3 — مستودع المصادقة والمخطط:**
- إنشاء جداول `AppUsers` و`UserScopes` في Drift (`lib/core/database/tables/`).
- رفع `schemaVersion` إلى 4 مع ترحيل يحوّل حسابات JSON القديمة إلى الجدول الجديد.
- إضافة `PRAGMA foreign_keys = ON` في `beforeOpen` لتفعيل `ON DELETE CASCADE`.
- كتابة `lib/core/auth/local_auth_repository.dart` من جديد: تخزين `failedAttempts` و`lockedUntil` في قاعدة البيانات (يصمد عند إعادة التشغيل)، تأخير تدريجي (`5^n` ثوانٍ)، رفض كلمة المرور الافتراضية والمتطابقة مع القديمة، إنشاء حسابات ابتدائية بكلمة مرور مؤقتة `123456`.
- إنشاء `lib/core/auth/auth_session.dart`: جلسة آمنة للواجهة لا تحمل الهاش أو الملح.
- إنشاء `lib/core/auth/auth_exceptions.dart`: استثناءات مكتوبة (`AccountLockedException`, `AccountDeactivatedException`, `AuthConflictException`).
- إنشاء `lib/core/auth/password_hasher.dart`: لفّ Argon2id مع تخزين المعاملات مع الحساب.
- توسيع `test/core/auth/local_auth_repository_test.dart` إلى 6 اختبارات (تسجيل دخول ناجح، قفل بعد 5 محاولات، تعطيل الحساب، تغيير كلمة المرور، إنشاء أولي، تحديث النطاقات).

### إصلاح جلسة الاستمرار الحالية
- إصلاح قوس زائد في `auth_gate.dart` كان يغلق الـ class مبكراً ويسبب 68 خطأ.
- إضافة `library;` directive في `auth_exceptions.dart` لإصلاح تحذير `dangling_library_doc_comments`.

### التحقق
- `flutter analyze --no-pub`: **No issues found!** (0 issues).
- `flutter test --no-pub`: **94/94 اختباراً** — جميعها ناجحة.
- جميع الملفات الجديدة أقل من 300 سطر (`local_auth_repository.dart`: 283 سطراً).

---

## 2026-10-23 — إنجاز المرحلة 1: بنية الواجهة وتفكيك radar_labor_app وتوحيد Providers

### ما تم إنجازه

- **توحيد MaterialApp:** إزالة `MaterialApp` المتداخل و`Directionality` اليدوي من `AuthGate`، ودمج الثيم والألوان والتوطين (`localizationsDelegates`) في `MaterialApp` موحد في جذر التطبيق مع دعم اللغتين والـ RTL تلقائياً.
- **إدارة الحالة ومزودات Riverpod:**
  - إنشاء `lib/app/app_providers.dart` مع `Notifier` و`NotifierProvider` لإدارة اللغة (`appLocaleProvider`)، والجلسة الحالية (`currentSessionProvider`)، وتوفير مستودعات قاعدة البيانات والأحداث ولوحة المؤشرات عبر الـ DI النظيف.
- **استخراج توكنز التصميم ونصوص الترجمة:**
  - إنشاء `lib/core/ui/app_tokens.dart` بالقيم الدقيقة للألوان والمسافات وأهداف اللمس من `docs/DESIGN.md`.
  - إنشاء `lib/core/l10n/app_strings.dart` لتوحيد النصوص الثنائية للواجهات ومنع النصوص المباشرة (Magic Strings).
- **تفكيك `radar_labor_app.dart` (من 908 أسطر إلى ملفات أقل من 300 سطر):**
  - `lib/app/radar_labor_app.dart`: جذر التطبيق وفتح قاعدة البيانات وإدارة دورة الحياة (155 سطراً).
  - `lib/app/home_scaffold.dart`: شريط التنقل السفلي والتبويبات وتغيير كلمة المرور (248 سطراً).
  - `lib/app/screens/workers_screen.dart`: شاشة وعمليات العمال والبحث (271 سطراً).
  - `lib/app/screens/entities_screen.dart`: شاشة الفرق والسكن (144 سطراً).
  - `lib/app/screens/preferences_screen.dart`: شاشة الإعدادات واللغة والتحكم (97 سطراً).
- **إغلاق قاعدة البيانات:** إضافة معالج `dispose` في `RadarLaborApp` لإغلاق `AppDatabase` بأمان.

### التحقق
- `flutter analyze --no-pub`: نظيف تماماً (`No issues found!`).
- `flutter test --no-pub`: نجح بالكامل (**89/89 اختباراً**).
- فحص حجم الملفات: كافة الملفات الجديدة والمعدلة تحت سقف الـ 300 سطر بصرامة.

## 2026-10-23 — إنجاز المرحلة 0: الأساس والتثبيت (Phase 0: Baseline & Stabilization)

### ما تم إنجازه

- **توثيق قرار حسم التعارض (ADR-001):** أضيف في `docs/DECISIONS.md` لتثبيت أسبقية توجيه المالك الأحدث (مسودة 23 أكتوبر) على وثيقة PRD فيما يخص محليّة التطبيق (دون شبكة/Supabase/مزامنة)، واللغة الافتراضية، والجلسات المؤقتة، واستيراد القوى العاملة، مع إبقاء المعايير المعمارية للـ PRD وقواعد الكود ملزمة وتعليق بنود السحابة.
- **اعتماد حزمة `excel`:** سُجّل القرار الرسمي لموافقة المالك على الحزمة للاستيراد المحلي لملفات XLSX عبر Storage Access Framework دون أطراف خارجية.
- **اختبارات التوصيف لـ `EventRepository`:** أنشئ ملف `test/core/events/event_repository_test.dart` (205 أسطر) يغطي:
  1. الإضافة الفردية والذرية وتحديث أرقام التسلسل `deviceSeq` في جدول الإعدادات.
  2. تمييز الأحداث المتأخرة (`isLate`) بناءً على ساعة قطع يوم العمل (Cutoff hour).
  3. التراجع الذري الكامل في المعاملة (`appendBatch`) إذا تضمن أي حدث خطأ تحقق.
  4. استئناف التسلسل من القيمة المخزنة، واكتشاف تلف بيانات التسلسل ورمي `StateError`.
  5. التحقق من صيغة التاريخ YYYY-MM-DD واستخراج نوع التسوية `resolutionKind` من حمولة الـ JSON.
  6. تدفقات قراءة وبث الأحداث لتاريخ عمل محدد.
- **اختبارات التوصيف لـ `StatusEngine`:** أنشئ ملف `test/core/status/status_engine_characterization_test.dart` (250 أسطر) يغطي:
  1. فحص عمال متعددين في دفعة واحدة وعزل حالاتهم مع الحفاظ على الترتيب الأصلي.
  2. حدود مطابقة مساكن الفحص والغياب مع سكن العامل المسند.
  3. حدود فترات التوظيف (المنتهية، المستقبلية، السارية).
  4. حدود SLA الصفرية وكسر المهلة الزمني.
  5. تأثير تسوية `siteError` في إزالة أعلام التناقض.
- **عدم المساس بكود الإنتاج:** لم يُعدّل أي سطر من كود الإنتاج داخل `lib/` خلال هذه المرحلة حفاظاً على الاستقرار.

### التحقق

- `dart analyze`: نظيف تماماً (`No issues found!`).
- `flutter analyze --no-pub`: نظيف تماماً (`No issues found!`, 12.4s).
- `flutter test --no-pub`: نجح بالكامل (**89/89 اختباراً**، بارتفاع من 73 إلى 89 بعد إضافة 16 اختبار توصيف جديد).
- اختبارات المعمارية `architecture_test.dart`: نجحت بالكامل وأكدت عدم وجود استيرادات محظورة لـ `flutter/material` أو بين الميزات.
- **فحص ملفات النظام والأندرويد:**
  1. `AndroidManifest.xml`: التحقق من ضبط `allowBackup="false"`، وحذف أذونات الشبكة والإنترنت (`INTERNET`, `ACCESS_NETWORK_STATE`) نهائياً.
  2. كود Kotlin (`MainActivity.kt`): التحقق من قناة اختيار الملفات `radar_labor/workforce_files` باستخدام Storage Access Framework (`ACTION_OPEN_DOCUMENT`) مع حظر الملفات التي تتجاوز 25 ميجابايت وإغلاق التدفقات بشكل آمن.

## 2026-10-23 — اعتماد وتضمين القواعد الهندسية الصارمة (Engineering Rules & Guidelines)

### التوثيق الذي أضيف

- حُدّث ملف `AGENTS.md` ليتضمن القواعد الهندسية والإرشادية التفصيلية:
  1. **فصل المنطق عن الواجهة (Separation of Concerns):** واجهات Presentation غبية، وخالية تماماً من منطق الأعمال والاستعلامات في `build`، والاعتماد كلياً على Riverpod والطبقات المخصصة.
  2. **حجم الملفات والهيكلة (File Size & Modularization):** حد أقصى صارم 300 سطر لكل ملف كود `.dart` (مع استثناء ملفات الكود المولد `*.g.dart`).
  3. **الكود النظيف (Clean Code & Best Practices):** منع الـ Magic Numbers/Strings ونقلها إلى `core/constants` أو الترجمة، حظر الـ empty catch blocks نهائياً ومعالجة الاستثناءات بشكل آمن، وتجنب الـ unsafe null assertions (`!`).
  4. **إدارة الحالة والبيانات (Architecture & State Management):** الاعتماد الحصري على Riverpod، حصر `setState` بالحالات المؤقتة للأنيميشن فقط، وضمان ذرية عمليات Drift/SQLite عبر transactions مع عزلها عن الـ UI.
  5. **انضباط التنفيذ والسلامة (Execution Discipline & Safety):** حظر تعديل الـ schemas أو الـ dependencies دون توجيه صريح، اعتماد الإنجليزية في الكود مع دعم العربية/RTL في الواجهات، والالتزام الصارم بهذه القواعد في أي تعديل قادم.

### التحقق

- فُحص ملف `AGENTS.md` يدوياً بعد التحديث للتأكد من المحافظة على قيود بيئة العمل السابقة وسلامتها.
- لم يُعدّل أي كود في التطبيق ولم يُبنَ أي APK؛ الجلسة خاصة بضبط وتثبيت قواعد التطوير.

## 2026-10-23 — تعليمات الموديلات وتقرير البيئة

### التوثيق الذي أضيف

- أضيف `AGENTS.md` في جذر المشروع كتعليمات عامة للنماذج، مع ترتيب القراءة،
  وحدود المنتج، وقواعد الطبقات والخصوصية والتحقق والتسليم.
- أضيف `docs/DEVICE_AND_MODEL_HANDOFF.md` ليجمع حالة التطبيق التفصيلية، إعداد
  جهاز Windows، نتائج الفحوص والبناء، الأخطاء وأسبابها ومعالجتها، وما لم يُختبر.
- رُبط دليل التسليم من فهرس docs و`NEXT_AGENT.md`، وأضيفت إحالة إليه في
  `CLAUDE.md` حتى لا تتغلب تعليمات قديمة عن المزامنة على قرار V1 المحلي.
- سُجل B-009 الخاص برسالة التحقق عند كلمة مرور أقصر من الحد وB-010 الخاص بترميز
  CSV ضمن الأخطاء المفتوحة. لا تغيير على التطبيق بناءً على طلب المالك.
- عُدّل تقرير الحالة ليذكر أن GitHub مرفوع حسب تأكيد المالك، وأن توثيق هذه
  الجلسة لم يُرفع. المالك سيتولى المراجعة والـcommit والرفع.

### التحقق

- فُحصت ملفات التسليم وسجل الأخطاء وREADME وCLAUDE.md يدويًا.
- **لم تُشغّل اختبارات أو بناء APK**؛ لم يتغير كود التطبيق، وهذه جلسة توثيق.
- بقيت تغييرات التوثيق محلية، بلا commit أو push.

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

## 2026-10-23 — تفصيل سجل الجهاز وتسليم الموديلات

- أُضيف `DEVICE_AND_MODEL_HANDOFF.md` ليجمع وصفًا تفصيليًا للتطبيق والبنية والبيئة والأمان والأدوار والاستيراد، وسجل أسباب الأخطاء وطرق منع تكرارها.
- وُثق أن CSV المصدر كان بأعمدة سليمة لكنه Windows-1256 بدل UTF-8، وأُضيفت خطوات LibreOffice وملاحظة أن التصدير يقتصر على الورقة الحالية.
- وُثق حد كلمة المرور 8 أحرف، وأن الرفض الحالي لا يعرض feedback واضحًا. لم يبق تعديل كود؛ المالك طلب عدم التعديل وأفاد أن الدخول اشتغل.
- سُجل أن محاولة بناء APK بعد محاولة UX أُلغيت بطلب المالك، وأن النسخة المعتمدة تبقى `outputs/Radar Labour.apk` ببصمتها السابقة. لم يُعد تشغيل تحليل أو اختبارات لأن هذا التسليم توثيق فقط ولم يتغير كود التطبيق.
- فحص GitHub الأخير أظهر remote branch على commit `307025d04bf9e6e8c927db67982fb424f05299d7`، كما أكد المالك أنه رفع المشروع.


## 2026-10-25 — إكمال رادار ليبور V1.5 بالكامل (الجلسات 7 إلى 11 — المرحلة ب والتسليم النهائي)

- **الجلسة 7 (Role-First Login & Account Management):** إنشاء `AuthFlowStrings`, `AdminStrings`, `SyncStrings`, `RolePicker`, `LoginFlowNotifier`، وتحديث `AuthLoginForm`, `AuthGate` (BC-5: الدور -> الاسم -> كلمة المرور مع التحقق من الدور في `signIn`)، و `LocalAccountsScreen` (BC-6: السماح بإنشاء مشرف موقع بلا فريق مسند مبدئيًا، وإضافة إعادة تعيين كلمة المرور وتعطيل الحساب).
- **الجلسة 8 (Security & Sync Architecture Plan):** كتابة الخطة الأمنية والمعمارية الكاملة لربط الحسابات المحلية بـ Supabase Auth وسياسات RLS ودالة `ingest_event_batch` في `docs/SECURITY_AND_SYNC_PLAN_V1_5.md`.
- **الجلسة 9 (`schemaVersion=5`, Audit Log, & Roster Control):** ترقية قاعدة البيانات إلى `schemaVersion=5` (`AuditLogs` table -> `audit_log`، وجعل `AppUsers.employeeUid` اختياريًا لدعم حساب `viewer` بلا سجل عامل — BC-7، ومفتاح `roster_epoch`)، وإنشاء `AuditEntry`, `AuditLogRepository`, `RosterWipePlan`, `RosterAdminRepository`, وتبويب «سجل التغييرات» (`AuditLogTabView`) في `HistoryScreen`.
- **الجلسة 10 (Automatic Offline-First Sync):** إنشاء `OutboxRepository`, `RemoteSyncGateway` (`OfflineRemoteSyncGateway`), `SyncEngine` (مع دعم الرفع غير المكرر `Idempotent`، وتنزيل القوى والحسابات و `roster_epoch`، والتفعيل `ActivationRequired`، وإنهاء الجلسة بعد رفع ما لم يُرفع `SessionRevoked` — D-25)، ومؤشر المزامنة الهادئ `SyncStatusBadge` في `HomeScaffold`.
- **الجلسة 11 (Final Hardening & Release APK):**
  - التحقق من أن جميع ملفات `.dart` في `lib/` (باستثناء `*.g.dart`) لا تتجاوز 300 سطر بعد `dart format`.
  - `flutter analyze --no-pub`: **No issues found!** (0 issues).
  - `flutter test --no-pub`: **125/125 اختبارًا ناجحًا** (`All tests passed!`).
  - `flutter build apk --release --no-pub`: نجح البناء ونُسخ إلى `outputs/Radar Labour.apk` بحجم **69,521,599 بايت** وبصمة SHA-256: `5E7F5F7397B3C2C938FD36794C2F25AC58A032293083023AE12D2E54C9C19957`.
