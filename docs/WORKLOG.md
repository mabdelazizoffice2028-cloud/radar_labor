# Work log

Append one dated handoff entry for each model/session. Keep prior entries so the
next model can understand decisions and recoveries. The newest handoff is at the
top of the log.

## 2026-10-30 — Surgical Deep Audit Fixes (10 Critical Vulnerabilities Resolved)

- **Status & Verification:**
  - lutter analyze --no-pub: No issues found! (0 errors, 0 warnings, 0 infos).
  - lutter test --no-pub: 234 / 234 tests passed (100% success rate, +8 new tests in 	est/features/operations/surgical_audit_fixes_test.dart).
  - Micro-modularization: Every touched / created .dart file in lib/ strictly <= 80 lines.
  - Zero external network dependencies, 100% offline-first.

- **Resolved Vulnerabilities & Architectural Refactoring:**
  1. **Rental Workers & Equipment Operators WhatsApp Report Fix:**
     - In operations_housing_workers_loader.dart, operations_repository.dart, site_attendance_row_builder.dart, and history_repository.dart, explicitly passed employmentType & jobCategory to WorkerOption.
     - In history_site_section_builder.dart & history_housing_section_builder.dart, passed both fields to WhatsappWorkerItem.
     - In operations_controller.dart & operations_housing_coordinator.dart, updated prepareHousingCheck to call store.getHousingWorkers(housing.id, date: date) to filter on-leave workers.
  2. **Housing 'No Absences Today' Safety & Completeness:**
     - Refactored housing_check_no_absences_handler.dart: prepares check via controller.prepareHousingCheck, prompts via OperationConfirmSyncDialog, copies WhatsApp summary to Clipboard, triggers background sync, displays AppSnackBar.showSuccess with undo action, and pops view safely.
  3. **Supervisor Task Badge Resolver:**
     - Fixed draft condition in supervisor_task_badge_resolver.dart for housing supervisor to only trigger on housingState.hasDraftSaved || housingState.hasUnsavedChanges, removing false positive trigger unreviewedCount < totalCount.
  4. **Sync Gateway, Outbox Repository, & Batch Uploader:**
     - SupabaseSyncGateway.uploadBatch: Restricted accepted IDs to ccepted when 
es is List, fallback to all only when 
es == null. Modularized SupabaseSnapshotFetcher.fetch to throw OperationException(DatabaseBusy()) on server failure instead of resetting 
osterEpoch.
     - SyncBatchUploader.upload: Replaced single-batch limit with while (true) loop uploading 500 items per batch until outbox is empty with progress safeguard.
     - OutboxRepository: Optimized 
eadPendingCount() with fast Drift count() queries on events and uditLogs. Merged reactive streams in watchPendingCount(). Modularized into OutboxSyncMarker and OutboxPendingReader.
  5. **StatusSnapshotRepository Performance Optimization:**
     - Refactored StatusSnapshotRepository.watch to subscribe to events.watchBusinessDate(targetDate) instead of database-wide watchAll(), re-subscribing on day change during 1-minute ticker. Modularized parseOnLeave into StatusSnapshotWorkerBuilder.
  6. **Audit Trail & Memory Leak Closures:**
     - worker_add_dialog.dart: Validates 10-digit iqama (RegExp(r'^\d{10}$')), disposes controllers in inally, records to workerHistory and AuditLogRepository, and catches errors with AppStrings.workerSaveFailed.
     - dashboard_resolution_sheet.dart & dashboard_justification_sheet.dart: Controllers now internal with automatic dispose(). Removed memory leaks and direct SystemClock calls in dashboard_screen.dart.
     - worker_leave_dialog.dart: Added _noteController.dispose() and injected clock support.
     - ccounts_admin_controller.dart: Audits account creation ('account_created'), update ('account_updated'), password reset ('password_reset'), and deactivation ('account_deactivated').

## 2026-10-30 — Surgical V2.7 Upgrade: Bottom Nav User Manager, Frictionless VIP Viewer, High-Visibility Contrast & Professional Localization

- **Release Artifact:** `outputs/Radar Labour.apk`
- **File Size:** 25,079,776 bytes (23.92 MB)
- **SHA-256:** `1F44B1F6265C6BF6FFC2D1350E8741B1A71659331EAA2DE535146511BF93CA5F`
- **Architectural Verification:**
  - Micro-modularization: Every touched `.dart` file in `lib/` strictly `<= 80` lines (range: 24 to 79 lines).
  - Dumb UI & Layer Isolation: Zero direct Flutter Material imports (`material_ui/material_ui.dart` only). Zero external network calls.
  - Static Analysis (`flutter analyze --no-pub`): `No issues found!`.
  - Full Test Suite (`flutter test --no-pub`): 221 / 221 tests passed (100% success rate).

- **Key Upgrades Executed:**
  1. **Phase 1: Bottom Navigation Bar Overhaul (User Manager for Admins):**
     - Replaced `AppSection.teams` with `AppSection.users` in `RoleCapabilities` and `adminRoleCapabilities.sections`.
     - Mapped `AppSection.users` to `Icons.manage_accounts_outlined` and localized labels (`'المستخدمين'` / `'Users'`).
     - Routed `AppSection.users` directly to `LocalAccountsScreen(database: database, arabic: ar)` in `HomeScaffoldPageRouter`.
     - Removed redundant "Manage Users" ListTile from `PreferencesAdminSection`.
  2. **Phase 2: Frictionless "View Only" Account (VIP Access):**
     - Updated `AccountFormFields` to hide worker autocomplete search field (`AccountWorkerSearchField`) when role is `AuthRole.viewer`, enabling manual display name entry without tying to an employee in the database.
     - Updated `AccountFormSubmitter` and `AccountFormDialog` to pass `employeeUid: null` for viewers.
     - Updated `LocalAuthAccountMutator.insertUser`: set `mustChange: Value(role != AuthRole.viewer)` so Viewers log in seamlessly without being forced to change their password.
  3. **Phase 3: Color Contrast & High-Visibility UI (Pure White & Bold):**
     - Updated `AuthLanguageButton`: explicitly styled text and icon with `AppTokens.surface` (Pure White) and `FontWeight.w900` for high contrast against the blue AppBar.
     - Updated `AuthLoginScaffold`: guaranteed pure white AppBar foreground (`foregroundColor: AppTokens.surface`).
  4. **Phase 4: Professional Localization Rewrite ("About App"):**
     - Replaced literal translation "الكامبوس" in `AboutAppContentData` (`ar`) with professional standard Arabic ("سكن العمال" / "المجمعات السكنية").
     - Updated overview, supervisor roles, and daily lockout descriptions in corporate Arabic.

## 2026-10-30 — Surgical V2.6 Upgrade: Roster Import Decoupling, Batch Supervisor Activation, Atomic Dual-Write & Multi-Team Wizard Support

- **Release Artifact:** `outputs/Radar Labour.apk`
- **File Size:** 25,145,360 bytes (24.0 MB)
- **SHA-256:** `685812DD32E4EFF7F6E36E9C36D7BE91700D21A8BC8385A69B47EAFE3419463E`
- **Architectural Verification:**
  - Micro-modularization: All 28 created/modified `.dart` files inside `lib/` are strictly `<= 80` lines.
  - Dumb UI & Layer Isolation: Zero direct Flutter Material imports (`material_ui/material_ui.dart` only). Zero database/drift/supabase imports in presentation/UI. Pure DateTime inside `lib/core/time/`.
  - Static Analysis (`flutter analyze --no-pub`): `No issues found!`.
  - Full Test Suite (`flutter test --no-pub`): 215 / 215 tests passed (100% success rate).

- **Key Upgrades Executed:**
  1. **Phase 1: Decouple CSV/Excel Import from Supervisor/Team Creation + Decouple Employment Type from Supplier:**
     - Updated `WorkforceRow` with `employmentType` defaulting to `'company'`.
     - Extracted `WorkforceTabularReader` (`lib/features/roster/domain/workforce_tabular_reader.dart`, 53 lines) to read raw CSV and XLSX rows.
     - Refactored `WorkforceImportParser` (`lib/features/roster/domain/workforce_import_parser.dart`, 48 lines) to parse normalized headers for `'employmenttype'`, `'type'`, `'affiliation'`, `'نوعالتبعية'`, `'التبعية'`, supporting explicit `'company'`/`'شركة'` and `'rental'`/`'ايجار'`/`'إيجار'` independently of supplier presence.
     - Updated `WorkforceImportRepository` (`lib/features/roster/data/workforce_import_repository.dart`, 56 lines): removed `AccountProvisioningRepository` and `_seeds(...)` entirely. Roster import only populates and updates `employees` and `worker_history`, returning `accountsCreated: 0`.
     - Updated `AdminUserStrings` and `AdminStrings`: localized `importReviewBody`, `importDone`, `noNamesHint`, and added `assignTeamRequired`, `selectSiteSupervisors`, `selectCampusSupervisors`, and `batchActivated`.
     - Documented unequivocally that Iqama number (10 digits, `employees.iqama_no`) is the primary local key for matching and uniqueness in the encrypted SQLite store, but is never disclosed in public WhatsApp reports.

  2. **Phase 2: One-Tap Batch Supervisor Activation:**
     - Added `batchActivateSupervisors({required List<Employee> selectedEmployees, required AuthRole role})` in `AccountsAdminController` and `AccountProvisioningRepository`.
     - Created `BatchSupervisorDialog` (`lib/app/accounts/batch_supervisor_dialog.dart`, 69 lines) enabling Project Managers to search active workers by name/Iqama, view job title/category, and multi-select workers to activate as supervisors in bulk.
     - Created `BatchActivationBar` (`lib/app/accounts/batch_activation_bar.dart`, 49 lines) with quick-action buttons "Select Site Supervisors" and "Select CAMPOS Supervisor", integrated into `LocalAccountsList`.
     - Activating CAMPOS supervisor automatically binds `main_campus` (`HousingConstants.defaultHousingId`).

  3. **Phase 3: Atomic Dual-Write Synchronization for Supervisor and Team Scopes:**
     - Created `TeamScopeSync` (`lib/core/auth/team_scope_sync.dart`, 35 lines) executing atomic transactions to clear `supervisorUserId` on previously assigned teams, claim `teams.supervisorUserId` on newly assigned teams, clear conflicting assignments from other supervisors in `user_scopes`, and insert new scopes.
     - Updated `LocalAuthAccountMutator` (`lib/core/auth/local_auth_account_mutator.dart`, 73 lines): integrated `TeamScopeSync` into `updateScopes`, `insertUser`, and `deactivateAccount` (clearing `teams.supervisorUserId` when a user account is deactivated).
     - Refactored `SupervisorAccountProvisioner` (`lib/core/auth/supervisor_account_provisioner.dart`, 46 lines): removed string-based team creation (`_findOrCreateTeam`). Supervisor provisioning creates accounts without generating arbitrary teams.

  4. **Phase 4: Clean up Admin UI & Permissions + Multi-Team Wizard Support for Site Supervisors:**
     - Removed empty `AppSection.housing` from `RoleCapabilities`, `HomeScaffoldPageRouter`, and `HomeScaffoldSectionMeta`.
     - Removed manual team creation FAB and dialog from Project Manager `EntitiesScreen`, converting it to a read-only list for monitoring active teams. Deleted unused `lib/app/screens/entities_add_dialog.dart`.
     - Enforced mandatory team assignment in `AccountFormDialog` when saving a site supervisor if teams exist (`widget.teams.isNotEmpty && _teams.isEmpty`).
     - Added `createNewTeam` action in `SiteAttendanceMoreMenu` when `canEditTeam`/`canSetupTeam` is available, wired through `SiteAttendanceTeamRow`, `SiteAttendanceHeader`, `SiteAttendanceBody`, and `SiteAttendanceScreen` allowing site supervisors to launch `TeamWizardScreen` to create additional teams anytime.
     - Extracted `SiteWorkerSearchBar` (`lib/features/operations/presentation/widgets/site_worker_search_bar.dart`, 41 lines) to keep `SiteAttendanceBody` strictly under 80 lines (57 lines).

## 2026-10-30 — Field & Admin Refinements: Admin Unification, CAMPOS Terminology, 4-8 Password Policy, Direct Workforce Import & Supervisor Activation

- **Tasks executed:**
  1. **Task 1: Complete Eradication of "HR" -> Unify as "Admin":**
     - Updated `lib/core/constants/app_constants.dart`: set `AuthConstants.defaultHrName = 'Admin'`.
     - Updated `lib/core/auth/account_provisioning_repository.dart`: `ensureAdminAccounts()` now provisions `'Admin'` and automatically updates any existing accounts where `role == 'hr' && displayName == 'HR'` to `'Admin'`, preventing database wipe needs.
     - Updated localized strings across `lib/core/l10n/about_app_content_data.dart` and `auth_flow_strings.dart` ensuring no user-facing UI displays "HR" or "الموارد البشرية".
  2. **Task 2: Standardize Terminology to "CAMPOS" (Camp + Boss):**
     - Updated `lib/core/constants/app_constants.dart`: set `HousingConstants.defaultHousingName = 'Main CAMPOS'`.
     - Standardized English strings to `CAMPOS` and Arabic to `الكامبوس` across:
       - `auth_flow_strings.dart`: `housingSupervisorRole` -> `'CAMPOS'` / `'الكامبوس'`
       - `app_auth_strings.dart`: `housingTab` -> `'CAMPOS'` / `'الكامبوس'`
       - `app_entities_strings.dart`: `'Current CAMPOS'`, `'No CAMPOS'`, `'Add CAMPOS'`, `'team and CAMPOS'`
       - `admin_user_strings.dart` & `admin_strings.dart`: `'Assigned CAMPOS'`, `'CAMPOS created/updated/deactivated'`, `'scopeHousingCount'`
       - `operations_actions_strings.dart`: `'Select CAMPOS'`, `'Add a CAMPOS to start a check'`, `'Confirm CAMPOS check'`, `'CAMPOS check saved locally'`, `'CAMPOS check'`, `'Record CAMPOS Absences'`
       - `dashboard_strings.dart`, `dashboard_dialog_strings.dart`, `history_strings.dart`, `housing_review_strings.dart`, `about_app_content_data.dart`, `attendance_message_strings.dart`.
  3. **Task 3: Flexible Password Policy (4 to 8 Characters — Digits or Letters):**
     - Updated `AuthConstants.minPasswordLength = 4` and added `AuthConstants.maxPasswordLength = 8`.
     - Refactored `lib/core/auth/` into clean micro-modular single-responsibility components (`local_auth_account_reader.dart`, `local_auth_password_service.dart`, `local_auth_signer.dart`, `local_auth_account_mutator.dart`, and facade `local_auth_repository.dart`), each `<= 80` lines.
     - Enforced 4-8 characters in `changePassword(...)`, throwing `ArgumentError('Password must be between 4 and 8 characters')` and rejecting temporary password `123456`.
     - Updated `ChangeTemporaryPasswordDialog`, `HomePasswordChanger`, `ChangeTemporaryPasswordFields`, and `UserPasswordChangeDialog` with 4-8 validation and `maxLength: 8`.
     - Updated localization strings in `auth_flow_strings.dart` and `app_auth_strings.dart`.
  4. **Task 4: Direct Excel/CSV Import Card in Admin Settings:**
     - Created `lib/app/screens/preferences_import_card.dart` (`<= 80` lines) with `Icons.upload_file_outlined` and localized import workforce action.
     - Integrated `PreferencesImportCard` directly into `PreferencesAdminSection` above `Manage Users`. Hidden from supervisors since `PreferencesAdminSection` only renders for Admin and Project Manager.
  5. **Task 5: Streamlined One-Time Supervisor & CAMPOS Activation:**
     - Broadened `SupervisorRoleResolver` to auto-detect `'campos'` and `'كامبوس'`, immediately provisioning rows with these designations as `AuthRole.housingSupervisor` with `main_campus` scope.
     - Modularized `AccountFormDialog` into `account_form_dialog.dart`, `account_form_fields.dart`, `account_worker_search_field.dart`, `account_team_scope_tile.dart`, and `account_form_submitter.dart` (all `<= 80` lines).
     - Added searchable worker picker via `Autocomplete<ScopeOption>` auto-filling employee display name.
     - Selecting `AuthRole.housingSupervisor` automatically binds `HousingConstants.defaultHousingId` (`main_campus`) behind the scenes as a 1-tap activation without requiring manual campus box checking.
  6. **Task 6: Verification, Testing & Production Release APK:**
     - Verified all 31 created/modified `.dart` files in `lib/` are strictly `<= 80` lines.
     - Static analysis (`flutter analyze --no-pub`): `No issues found!`.
     - Unit/Widget test suite (`flutter test --no-pub`): 213/213 tests passed (100%).
     - Built ARM64 production release APK via `flutter build apk --target-platform android-arm64 --release --no-pub`.
     - Copied APK to `outputs/Radar Labour.apk`:
       - Exact Size: 25,079,728 bytes (~23.92 MB)
       - SHA-256: `81F413178116152920067BB22BEA8D12782AAA14986AA7F37880120A3D34CB20`

## 2026-10-30 — Task 6 Completed: Friday Overtime Exception & Zero-Absence Rule (استثناء يوم الجمعة والعمل الإضافي)

- **Owner request:**
  تنفيذ المهمة السادسة (Task 6) من الخطة الشاملة V2.5: استثناء يوم الجمعة والعمل الإضافي وضمان صفر غيابات في كافة أقسام التطبيق مع الالتزام الصارم بقاعدة الـ 80 سطراً (Micro-modularization <= 80 lines) وهندسة الواجهات النظيفة:

  1. **محدد يوم الجمعة (FridayResolver):**
     - إنشاء الملف النقي `lib/core/time/friday_resolver.dart` للتحقق من يوم الجمعة عبر `FridayResolver.isFriday(businessDate)`.
     - ربطه مع `lib/core/time/business_date.dart` مع الحفاظ على التوافقية الكاملة.

  2. **محرك الحالات وقاعدة صفر غيابات يوم الجمعة (StatusEngine & Zero-Absence Guarantee):**
     - تحديث `StatusEngineWorkerEvaluator` لضمان:
       - أي عامل مسجل في الموقع يوم الجمعة يحصل على حالة `WorkerStatus.onSite` (يُعامل كعمل إضافي).
       - العمال غير المسجلين يحصلون على حالة `WorkerStatus.notRecorded` (في راحة الجمعة ولا يُحتسب لهم أي غياب).
       - تجاهل أي أحداث غياب كامبوس مسجلة خطأً يوم الجمعة لضمان أن إجمالي الغياب = 0 دائماً.
       - تعطيل التحضير التلقائي للكادر الإداري والفني (`StaffCategoryResolver`) يوم الجمعة.
       - تعطيل مهلة المتابعة وتنبيهات SLA يوم الجمعة.
     - تحديث `WorkerSummaryCalculator` لاحتساب حضور الجمعة كيوم عمل إضافي مع منع زيادة عداد الغياب نهائياً يوم الجمعة.

  3. **واجهات تحضير الموقع والرسائل التنبيهية (Site Attendance Screen & Dialogs):**
     - إنشاء المكون `SiteFridayBanner` في `lib/features/operations/presentation/widgets/site_friday_banner.dart` لإظهار شريط تنبيهي متباين بلون عنبري يوضح وضع العمل الإضافي.
     - تحديث شريط الحفظ `AttendanceCounterBar` لإظهار عداد إضافي الجمعة وتغيير نص زر الحفظ إلى "تأكيد العمل الإضافي" / "Confirm Overtime".
     - تحديث نافذة التأكيد `OperationConfirmSyncDialog` لعرض نص تأكيد إضافي الجمعة `OperationsStrings.fridaySaveConfirm`.

  4. **لوحة التحكم وتقارير الواتساب (Dashboard & WhatsApp Overtime Report):**
     - مواءمة بطاقات لوحة التحكم `DashboardStatusCards` لإظهار بطاقتي "إضافي الجمعة" و"في راحة الجمعة" وإخفاء بطاقة الغياب بالكامل.
     - تحديث مولد تقرير الواتساب `DailyReportGenerator` ليكون العنوان في يوم الجمعة `📋 *تقرير العمل الإضافي — يوم الجمعة*` / `📋 *Friday Overtime Report*` وتفصيل `إجمالي عمالة الإضافي` واستبعاد سطر إجمالي الغياب كلياً.

  5. **التحقق والاختبار والبناء (Verification, Tests & Release Build):**
     - إضافة حزمة اختبارات شاملة في `test/core/status/friday_overtime_and_zero_absence_test.dart`.
     - جميع الملفات البرمجية الجديدة والمعدلة `<= 80 سطراً` بدون أي استثناء.
     - اجتياز اختبارات المعمارية بنسبة 100%.
     - تشغيل حزمة الاختبارات بالكامل: 203/203 اختبار نجح بنسبة 100%.
     - التحليل الساكن للكود (`flutter analyze --no-pub`): `No issues found!`.
     - بناء نسخة الإنتاج الرسمية وحفظها في `outputs/Radar Labour.apk`.

## 2026-10-30 — Master Execution Plan V2.5 Completed (Tasks 1-5, Micro-Modularization & Guardrails)

- **Owner request:**
  تنفيذ حزمة التطوير V2.5 المعمارية الشاملة لتطبيق Radar Labour عبر 5 مهام تكاملية مع الالتزام التام بقاعدة الـ 80 سطراً (Micro-modularization <= 80 lines) وهندسة الواجهات النظيفة (Dumb UI / Pure Dart):

  1. **Task 1: زر تحديد الفرقة المعتادة بنقرة واحدة (Default Crew One-Tap Button):**
     - إضافة زر `selectDefaultCrew` في واجهة تحضير الموقع بجانب "تحديد الكل".
     - تنفيذ منطق `SiteAttendanceNotifier.selectDefaultCrew()` الذي يحدد تلقائياً فقط أعضاء الفريق النظاميين (`WorkerRowOrigin.member`) غير المقفلين مع الحفاظ على صفوف الضيوف والمقفلين.
     - تقسيم شريط التحكم العلوي إلى `SiteAttendanceHeader`, `SiteAttendanceTeamRow`, `SiteAttendanceActionRow` لضمان أن كل ملف برمجي <= 80 سطراً.

  2. **Task 2: الحضور التلقائي للكادر الإداري والفني (Auto-Attendance for Non-Labor Staff):**
     - إنشاء محدد الفئات النقي `StaffCategoryResolver` في `lib/core/status/staff_category_resolver.dart` للتعرف على المهندسين ومسؤولي السلامة والإداريين ومدراء المشاريع والمراقبين بالعربية والإنجليزية.
     - تمرير `jobCategory` إلى `WorkerProfile` عبر `StatusSnapshotWorkerBuilder`.
     - تحديث محرك الحالات `StatusEngineWorkerEvaluator` لاحتساب الكادر الإداري والفني كـ "حاضر بالموقع تلقائياً" (`WorkerStatus.onSite`) في الأيام العادية دون الحاجة لتحضيرهم من قِبل المشرف، مع إمكانية تسجيل غيابهم يدوياً من قِبل الإدارة.

  3. **Task 3: إدارة الإجازات المرنة والتاريخية (Flexible Leave Management - Admin & HR):**
     - بناء نموذج البيانات النقي `WorkerLeave` ومستودع `LeaveRepository` لتسجيل الإجازات من تاريخ بداية إلى تاريخ نهاية (سواء كانت سابقة بأثر رجعي أو مستقبلية).
     - تخزين الإجازات بأمان عبر مفتاح `AppSettingKeys.workerLeaves = 'worker_leaves_v1'` في `LocalSettingsRepository` وتسجيل عمليات الإنشاء والحذف في `AuditLogRepository` مع تفادي الحاجة لأي ترحيل لقاعدة البيانات.
     - استثناء العمال المجازين فورياً من كافة العمليات:
       - مسار تحضير الموقع (`SiteAttendanceLoader`): استبعاد العامل المجاز من القائمة النشطة للفريق.
       - مسار فحص الكامبوس (`OperationsHousingWorkersLoader`): منع تسجيل غياب العامل المجاز.
       - مسار لوحة التحكم ومحرك الحالات (`StatusSnapshotRepository` & `StatusEngine`): اعتبار العامل غير مؤهل (`isEligible = false`) بحيث يصبح `Absent = 0` خلال فترة الإجازة حتى عند إدخال الإجازة بأثر رجعي.

  4. **Task 4: بطاقة سجل العامل وإدارة الإجازات (Worker History Card & Actions Sheet):**
     - بناء حاسبة نقية `WorkerSummaryCalculator` لحساب:
       1. إجمالي أيام العمل (`totalDaysWorked`): تشمل أيام الحضور بالموقع، والغياب المبرر (وفق القاعدة الذهبية: أي غياب مبرر يحتسب كيوم عمل)، وعمل الكادر الإداري التلقائي.
       2. إجمالي أيام الغياب الفعلي (`totalDaysAbsent`): استبعاد الإجازات والغياب المبرر وأيام الجمعة.
       3. سجل العمل مع الفرق (`teamHistory`): تفصيل أسماء الفرق وأيام العمل مع كل فريق مرتبة تنازلياً.
     - ربط النقر على أي عامل في `WorkersScreen` لفتح ورقة الإجراءات السفلية `WorkerSummarySheet` والتي تتضمن:
       - بطاقات المؤشرات الرئيسية الثلاث (`WorkerSummaryKpiCards`).
       - قسم إدارة الإجازات وإضافتها وحذفها مع نافذة منتقي التواريخ `WorkerLeaveDialog`.
       - زر سريع للإدارة لتسجيل أو إلغاء غياب اليوم (`WorkerSummaryHeader`).

  5. **Task 5: تعديل مسمى دور HR إلى Admin:**
     - تحديث `AuthFlowStrings.hrRole` ليعيد 'Admin' بالإنجليزية و'الإداري' بالعربية مع الحفاظ التام على الـ enum الداخلي `AuthRole.hr`.

- **Verification:**
  - تم فحص وتفكيك كافة الملفات البرمجية لتكون جميع الملفات الجديدة والمعدلة `<= 80 سطراً`.
  - اجتياز اختبارات المعمارية الصارمة (`architecture_test.dart`) بنسبة 100%.
  - تشغيل كامل حزمة الاختبارات (`flutter test --no-pub`) بنجاح تام: 200/200 اختبار نجح بنسبة 100%.
  - فحص الكود الساكن (`flutter analyze --no-pub`): `No issues found!`.

## 2026-10-30 — Master Execution Plan Completed (Tasks 1-7, Architectural Guardrails, & Release Build)

- **Owner request:**
  تنفيذ خطة المعمارية المتقنة والتطوير الشامل لتطبيق Radar Labour عبر 7 مهام تكاملية مع الالتزام الصارم بالضوابط المعمارية العليا (Micro-Modularization <= 80 lines، Dumb UI، Clean Architecture، عدم حذف أي ميزات، والفحص والاختبار الشامل 100%):

  1. **المهمة 1 (قاعدة الجمعة الاستثنائية وقفل الأيام السابقة للمشرفين):**
     - إضافة دالة الفحص النقية `isFridayBusinessDate` في `lib/core/time/business_date.dart`.
     - منع مشرف الكامبوس (`housingSupervisor`) من تسجيل الغياب نهائياً يوم الجمعة، مع إمكانية الدخول ومراجعة الأيام السابقة من السجل، وعرض تنبيه إرشادي بارز وتعطيل أزرار الحفظ وخانات الاختيار يوم الجمعة (`FridayAbsenceNotAllowed`).
     - احتساب عمل عمال الموقع يوم الجمعة كـ "إضافي الجمعة" (Friday Overtime)، واحتساب العمال غير المحددين في وضع راحة دون تسجيل أي غياب (`Absent = 0`).
     - تعديل `StatusEngine` و `DailyReportGenerator` و `DailyReportCompiler` و `SiteWhatsappFormatter` لدعم تقرير إضافي الجمعة.
     - قفل الأيام السابقة فور انتهاء اليوم على كافة المشرفين (`canEditPastDays: false` لمشرفي الموقع والكامبوس، وحصر التعديل وتبرير الغياب على الإدارة `projectManager` و `hr`).

  2. **المهمة 2 (حذف تبويب السكن من شريط التنقل وتوحيد مصطلح الكامبوس):**
     - إزالة تبويب `AppSection.housing` من شريط التنقل للإدارة في `role_capabilities.dart` و `home_scaffold.dart`.
     - توحيد مسمى الكامبوس (`Campus` / `الكامبوس`) في كافة نصوص التطبيق واستبدال مسميات "السكن" القديمة.

  3. **المهمة 3 (صفحة "حول التطبيق" بثلاث لغات تعمل محلياً 100% دون إنترنت):**
     - استبدال بطاقات الجهاز التقنية في شاشة الإعدادات ببطاقة تفاعلية تنقل إلى شاشة `AboutAppScreen`.
     - إتاحة مبدل لغوي فوري داخل الشاشة لـ 3 لغات: الإنجليزية (افتراضياً)، العربية (RTL)، والأردية (RTL) بالاعتماد الكامل على نصوص استاتيكية محلية.

  4. **المهمة 4 (حصر إدخال وعرض البيانات الداخلية باللغة الإنجليزية):**
     - توحيد حقول الإدخال في إضافة العمال والفرق والكامبوس إلى حقل اسم إنجليزي واحد، مع تخزينه في `fullNameAr` و `fullNameEn` لضمان توافق قاعدة البيانات.
     - فرض العرض الدائم باللغة الإنجليزية لأسماء العمال والفرق في كافة القوائم وعارض سجل العمليات بغض النظر عن لغة واجهة التطبيق.

  5. **المهمة 5 (تبسيط تجربة حفظ المشرف ودمج شاشات التأكيد في حوار واحد):**
     - استبدال حوارات التأكيد الأربعة المتتالية بحوار موحد ذكي `OperationConfirmSyncDialog` يعرض ملخص الحضور/الغياب، الفروقات (+A / -R)، وقائمة العمال، وشارة إضافي الجمعة عند الانطباق.
     - حفظ التغييرات فوراً في الخلفية مع نسخ نص الواتساب للحافظة وعرض إشعار SnackBar قابل للتراجع.

  6. **المهمة 6 (تبسيط بطاقات لوحة التحكم وشارات الحالات):**
     - تخصيص عرض لوحة التحكم يوم الجمعة ليعرض شريط إضافي الجمعة وبطاقتين فقط: إضافي الجمعة (أخضر) وراحة الجمعة (رمادي مزرق).
     - عرض 4 بطاقات واضحة في الأيام العادية: موجود بالموقع، غائب، مبرر / بعذر، ولم يُرصد بعد.
     - تحديث شارات `SupervisorTaskBanner` و `AttendanceDateBar`.

  7. **المهمة 7 (تسجيل عمليات الإضافة الإدارية في سجل المراجعة التدقيقي):**
     - ربط إنشاء العمال والفرق الجديدة في شاشات الإدارة بتسجيل تلقائي آمن داخل `AuditLogRepository.record`.

  8. **التحقق المعماري والاختبارات وبناء الإصدار:**
     - الالتزام بقاعدة الـ 80 سطراً: كل ملف جديد أو معدل في `lib/` لا يتجاوز 80 سطراً.
     - الفحص الساكن: `flutter analyze --no-pub` -> **No issues found!**
     - الاختبارات: `flutter test --no-pub` -> **All 189 tests passed! (100%)**.
     - بناء نسخة الإنتاج: `flutter build apk --target-platform android-arm64 --release --no-pub` وحفظها في `outputs/Radar Labour.apk` (الحجم: 24.9 MB، البصمة: `BC8001D8D83D3011E4C18010F039CDC14018FFCA8724FAF944312C8B043381EB`).


## 2026-10-30 — Global Multi-Language GitHub Documentation Overhaul Completed

- **Owner request:**
  إعادة بناء وتطوير توثيق المشروع ليواكب أعلى المعايير العالمية على GitHub كمهندس برمجيات وكاتب توثيق تقني أول:
  1. إنشاء وتحديث الملف الإنجليزي الرئيسي `README.md` بلغة تقنية احترافية متقدمة.
  2. إنشاء الملف العربي الموازي `README.ar.md` بلغة عربية فصحى رصينة ومصطلحات هندسية معتمدة.
  3. إضافة شريط التنقل اللغوي الفوري في السطر الأول تماماً لكلا الملفين: `🌐 [English](README.md) • 🇸🇦 [العربية](README.ar.md)`.
  4. استيفاء كافة الأقسام الإلزامية:
     - الترويسة والشارات الحية (Flutter, Dart, Clean Architecture, Target: Android arm64, Release Ready).
     - نبذة معمارية موسعة وشرح التحديات التشغيلية لإدارة العمالة وفلسفة Offline-First.
     - قسم أبرز التحديثات الأخيرة (مركز الإشعارات، تنبيهات الإقامات، محرك التصحيح التلقائي، البحث الفوري، التقرير اليومي، وأداة تصفير التجارب).
     - تصنيف الميزات الأساسية بأيقونات وشرح تفصيلي (العمالة، حضور الموقع، فحص السكن، سجل الأحداث، الصلاحيات، وقوالب الواتساب).
     - جدول التقنيات المستخدمة (Riverpod, Drift, Cryptography, Secure Storage, GoRouter, Supabase, Connectivity Plus).
     - رسم شجري معماري مفصل لمجلد `lib/` وفق نمط Clean Architecture.
     - توثيق نسخة الإنتاج الجاهزة `outputs/Radar Labour.apk` بالحجم الدقيق وبصمة SHA-256، مع دليل التشغيل المحلي للمطورين.

## 2026-10-30 — Final QA, Documentation Consolidation & Production Release Build Completed

- **Owner request:**
  تنفيذ الفحص الشامل وضمان الجودة (Code Review & QA)، تنظيف وتوحيد الوثائق، وتوليد وبناء نسخة الإنتاج الرسمية (Production Release Build):
  1. **مراجعة الكود وجودة المعالجة (Code Review & Strict Error Handling):**
     - تم فحص ومعالجة كافة كتل الاستثناءات غير المصنفة أو الصامتة (`catch (_) {}`) في كامل ملفات المشروع:
       - `lib/features/operations/presentation/widgets/operation_background_sync.dart`: تحويلها إلى `on Object catch (error)` وتسجيل الخطأ بأمان عبر `debugPrint`.
       - `lib/core/database/legacy_accounts_migration.dart`: استبدال التجاهل الصامت بـ `on Object catch (error)` وتسجيل تخطي الترحيل بأمان.
       - `lib/app/screens/preferences_dev_tool_card.dart`: تصنيف الخطأ وتسجيله عبر `debugPrint` وعرض إشعار الفشل للمستخدم.
       - `lib/app/auth_gate_controller.dart` و `lib/app/auth_sign_in_handler.dart`: استبدال `catch (_)` باعتراض صريح وتسجيل آمن مع عرض رسائل واضحة.
       - `lib/features/operations/presentation/site_attendance_screen.dart` و `housing_check_dialog_helper.dart`: استبدال كافة `catch (_)` باعتراض صريح مع إشعار للمستخدم و `debugPrint`.
       - `lib/app/local_accounts_screen.dart`: تصنيف وتسمية كتل الاستثناءات.
     - التأكد من عدم وجود أي كتل `catch` فارغة نهائياً في المشروع.
  2. **تنظيف وتوحيد ملفات التوثيق (Documentation Consolidation):**
     - **حذف ملف `CLAUDE.md` نهائياً** والتخلص من تشتت الملفات.
     - **تحديث وإعادة هيكلة ملف `AGENTS.md`** ليكون المرجع الشامل، الموحد، والموجز لأي نموذج ذكاء اصطناعي أو مطور مستقبلاً.
     - تضمين المبادئ الهندسية الأساسية في `AGENTS.md`:
       - **التقسيم المعماري (Micro-modularization):** ألا يتجاوز أي ملف 80 سطراً للحفاظ على الكود نظيفاً وسهل الصيانة (والحد الأقصى 300 سطر للقديم).
       - **واجهات نظيفة (Dumb UI):** عزل واجهات المستخدم تماماً عن استعلامات قواعد البيانات ومنطق الأعمال، والاعتماد الحصري على Riverpod.
       - **تحديث الوثائق:** التزام إجباري بتحديث وثائق المشروع وسجل العمل (`WORKLOG.md`) وسجل الأخطاء بعد أي تعديل.
       - **بناء الإصدار (Release Build):** بناء التطبيق دائماً للأجهزة الحديثة `android-arm64` بالأمر المخصص.
  3. **الفحص والتحقق الكامل:**
     - `flutter analyze --no-pub`: **No issues found!** (صفر أخطاء، صفر تحذيرات).
     - `flutter test --no-pub`: **All 185 tests passed!** (100% نجاح لكافة الاختبارات).
     - كافة الملفات المعدلة والجديدة تلتزم بصرامة بقاعدة الـ 80 سطراً.
  4. **بناء نسخة الإنتاج النهائية الرسمية:**
     - الأمر: `flutter build apk --target-platform android-arm64 --release --no-pub`.
     - وقت البناء: 240.2 ثانية.
     - ملف الـ APK النهائي: `outputs/Radar Labour.apk` (ونسخة البناء في `build/app/outputs/flutter-apk/app-release.apk`).
     - الحجم الدقيق: **24,948,248 بايت** (~23.79 MB).
     - بصمة التشفير SHA-256: `670C30206ADA9A4325D296998C00E371746C2E24D8B0598F6BB217F089E85DE1`.

## 2026-10-30 — Premium UX/UI Polish, Notification Center & Dev Tools Completed

- **Owner request:**
  تنفيذ حزمة التحسينات الختامية لواجهة المستخدم وتجربة الميدان وفق القواعد العليا الصارمة (قاعدة الـ 80 سطراً، Dumb UI، وهندلة الأخطاء الشاملة بـ AppSnackBar):
  1. **تحسين شاشة تسجيل الدخول ومحدد اللغة (Login UX & Language Switcher):**
     - إضافة زر تبديل اللغة (`AuthLanguageButton`) في شريط العنوان لشاشة الدخول للتبديل بين العربية والإنجليزية وتغيير اتجاه التطبيق فوراً قبل الدخول عبر `appLocaleProvider.notifier.setLocale()`.
     - منع تغطية الكيبورد نهائياً: تغليف بطاقة الدخول بـ `SingleChildScrollView` مع إزاحة ديناميكية `MediaQuery.viewInsetsOf(context).bottom` داخل `SafeArea`.
     - تحسين مظهر البطاقة: `elevation: 4`، حواف دائرية `BorderRadius.circular(16)`، وحشوة داخلية مريحة 24px في `LoginFormLayout`.
     - تمييز زر الدخول بلون الثيم الأساسي `Theme.of(context).colorScheme.primary` وخط عريض وحواف منحنية.
     - إعادة هيكلة وتجزئة `lib/app/auth_gate.dart` (الذي كان 237 سطراً) إلى ملفات أحادية المسؤولية $\le 80$ سطراً (`auth_gate.dart` 61 سطراً، `auth_gate_controller.dart` 65 سطراً، `auth_gate_service.dart` 44 سطراً، `auth_sign_in_handler.dart` 41 سطراً، `auth_login_scaffold.dart` 52 سطراً، و `auth_login_content.dart` 69 سطراً).
  2. **مركز الإشعارات وتفريغ لوحة التحكم (Notification Center & Decluttering):**
     - تفريغ لوحة التحكم (`DashboardScreen`): إزالة البطاقات الصفراء التحذيرية الخاصة بالنواقص (`_CoverageWarnings`) لتصبح اللوحة نظيفة وتركز على العدادات والتقارير والنزاعات.
     - استبدال أيقونة السحابة في `HomeScaffold` AppBar بأيقونة جرس إشعارات ذكية (`NotificationBadge`) مع نقطة حمراء `Badge` تظهر فقط عند وجود حركات معلقة في الـ Outbox أو فرق/سكنات لم تسجل اليوم.
     - عند النقر على الجرس تفتح نافذة سفلية أنيقة (`NotificationsSheet`):
       - قسم حالة المزامنة (`NotificationsSyncSection`): إيضاح الوضع المحلي أو وجود حركات معلقة أو اكتمال المزامنة.
       - قسم النواقص لليوم (`NotificationsCoverageSection` و `NotificationsCoverageTile`): قائمة الفرق والسكنات غير المرصودة مع أسماء المشرفين.
       - بطاقة تهنئة خضراء في حال اكتمال كافة التسجيلات لليوم.
  3. **أداة المطورين لمسح بيانات التجارب (`PreferencesDevToolCard`):**
     - إضافة كارد أحمر في قسم إدارة الإعدادات (`PreferencesAdminSection`): "مسح بيانات التجارب (أحداث اليوم)" مع حوار تأكيد تحذيري صارم.
     - عند التأكيد، تنفيذ `OperationsDevTools.clearTestData(database)` ومسح `events` و `worker_history` و `audit_log` ذرياً دون المساس بالعمال أو الفرق.
     - تصفير فوري وتلقائي لكافة عدادات لوحة التحكم، وإظهار إشعار عائم أخضر عبر `AppSnackBar`.
  4. **الفحص والتحقق الكامل وبناء نسخة الإصدار النهائية:**
     - `flutter analyze --no-pub`: **No issues found!** (صفر أخطاء، صفر تحذيرات).
     - `flutter test --no-pub`: **All 185 tests passed!** (100% نجاح لكافة الاختبارات).
     - اختبارات المعمارية: نجاح بنسبة 100%.
     - جميع الملفات المعدلة والجديدة $\le 80$ سطراً بنسبة 100%.
     - بناء نسخة Release APK: `outputs/Radar Labour.apk` بحجم **24,948,248 بايت** وبصمة SHA-256: `5BE92441D8AD1C25FAB1D8CE2043BFD12C072525C6DF09E89AFBEF00D4506D52`.

## 2026-10-30 — UX Simplification, Smart Background Sync & WhatsApp Template Revamp Completed

- **Owner request:**
  تنفيذ التعديلات الميدانية النهائية لتبسيط التجربة وقوالب الواتساب وفق القواعد الصارمة (قاعدة الـ 80 سطراً، Dumb UI، وهندلة الأخطاء الشاملة بـ AppSnackBar):
  1. **تبسيط حوار الحفظ والمزامنة (`OperationConfirmSyncDialog`):** إزالة خياري "حفظ ورفع" و"حفظ محلي"، واستبدالهما بزر واحد "تأكيد وحفظ" يرجع `true` وزر "مراجعة" يرجع `false`.
  2. **الرفع التلقائي الصامت في الخلفية (`triggerBackgroundSync`):** عند التأكيد، يتم الحفظ محلياً وإظهار إشعار النجاح عبر `AppSnackBar` يختفي تلقائياً، مع إطلاق المزامنة في الخلفية بنمط Fire-and-forget بدون تعطيل المستخدم وبدون إظهار رسائل خطأ مقلقة.
  3. **تحديث قوالب الواتساب وهيكلتها:**
     - تقسيم `whatsapp_template_engine.dart` إلى ملفات مستقلة `<= 80 سطراً` (`housing_whatsapp_formatter.dart` و `site_whatsapp_formatter.dart` و `whatsapp_worker_item.dart` و `attendance_worker_selector.dart` و `attendance_summary_creator.dart`).
     - حذف عبارة "تم الإنشاء بواسطة رادار ليبور" نهائياً.
     - قالب فحص السكن: تصنيف الغياب إلى "عمال الشركة" و"عمال الإيجار" مرقمين برقم الإقامة والاسم، أو "0" عند عدم وجود غياب.
     - قالب تسجيل الموقع: عرض التاريخ، اسم الفريق، اسم المشرف المستخرج من جلسة المستخدم، وقسم "العمال (Labor)"، وقسم "مشغلي المعدات (Operator)" الذي يظهر فقط عند وجود مشغلين.
  4. **هندلة الأخطاء الشاملة بالواجهات:** تغليف عمليات الحفظ في `site_attendance_screen.dart` و `housing_check_dialog_helper.dart` بكتل `try/catch` محكمة وحماية الفحص بـ `mounted` وعرض رسائل الفشل عبر `AppSnackBar.show()`.
- **نتائج الفحص والتحقق:**
  - `flutter analyze --no-pub`: **No issues found!** (صفر أخطاء، صفر تحذيرات).
  - `flutter test --no-pub`: **All 181 tests passed!** (100% نجاح لكافة الاختبارات بما فيها اختبارات قوالب الواتساب الجديدة).
  - بناء وتحديث نسخة الـ Release: `outputs/Radar Labour.apk` بحجم 24,947,736 بايت وبصمة SHA-256: `9DF9510A9115122CC133BC6401397091B49B7800E384E933118DB7536E86DDE6`.

## 2026-10-30 — Comprehensive QA, Full Test Suite (179/179) & Final Release APK Build

- **Owner request:**
  تنفيذ التدقيق الشامل للجودة (QA)، فحص التحليل الساكن، تشغيل حزمة الاختبارات بالكامل مع تغطية SnackBar dismissibility، وبناء واستخراج نسخة الإصدار الرسمية (Release APK).
- **الإجراءات والتحسينات المطبقة:**
  1. **حل مشكلة الإشعار الأسود وسرعة اختفائه (SnackBar Dismissibility & Floating):**
     - إنشاء المكون الموحد `lib/core/ui/app_snack_bar.dart` الذي يمسح أي إشعار سابق فوراً عبر `clearSnackBars()` ويطبق السلوك العائم `SnackBarBehavior.floating` ومدة ظهور محددة (3 ثوانٍ) مع إمكانية السحب الأفقي للإخفاء الفوري `DismissDirection.horizontal`.
     - ضبط `ThemeData.snackBarTheme` في `lib/app/radar_labor_app.dart` لتوحيد الثيم العائم في كافة أنحاء التطبيق.
     - تحديث `lib/features/operations/presentation/widgets/operation_sync_helper.dart` و `housing_check_dialog_helper.dart`.
     - إضافة وحدة اختبار الـ Widget المخصصة `test/core/ui/app_snack_bar_test.dart` للتحقق من عدم تعليق الإشعارات واختفائها الفوري عند السحب أو انتهاء المدة.
  2. **فحص التحليل الساكن والمعمارية:**
     - `flutter analyze --no-pub`: نتيجة الفحص **No issues found!** (صفر أخطاء، صفر تحذيرات).
     - اختبارات المعمارية في `test/architecture/architecture_test.dart`: اجتازت كافة الاختبارات الخمسة بنسبة 100%.
  3. **حزمة الاختبارات الشاملة (Full Test Suite):**
     - `flutter test --no-pub`: نجاح **179/179 اختباراً (100% نجاح)** شملت كافة الميزات الجديدة (فحص السكن، البحث بآخر 4 أرقام، التصحيح التلقائي المزدوج، ساعات القفل، الرفع التلقائي، والإشعارات).
  4. **بناء نسخة Release APK الرسمية:**
     - بناء نسخة arm64 الحديثة عبر: `flutter build apk --target-platform android-arm64 --release --no-pub`.
     - حفظ النسخة في: `outputs/Radar Labour.apk`.
     - الحجم الدقيق: **24,947,800 بايت** (~23.79 MB).
     - بصمة التشفير SHA-256: `3089D24B6CD2226BAD95FEB9B7DD3B824AB02021F526F87A0ED03DA393D0F39E`.

## 2026-10-30 — Radar Labour V2: Phase 2 (Core Logic) & Phase 3 (UI, Search, Lockout, Auto-Sync & Reports) Completed

- **Owner request:**
  تنفيذ المهام المتبقية من ترقية Radar Labour V2 وفق القواعد العليا الصارمة (Micro-modularization <= 80 سطراً لكل ملف Dart، حماية الـ Event Ledger Append-only، حماية الصلاحيات، وواجهات Dumb UI):
  1. **Phase 2 (Core Logic):**
     - الترقيم التلقائي (Auto-Serial): لا يتم تخزين S/O في قاعدة البيانات ويُحسب ديناميكياً للعرض فقط.
     - الاستيراد الصارم (Strict Import): فحص شامل لملف الاستيراد ورفضه بالكامل (Transaction Rollback) في حال وجود أي رقم إقامة مكرر أو لا يتكون من 10 أرقام. تحديث العمال المسجلين وتسجيل الحركة في `worker_history`.
     - التصحيح التلقائي المزدوج (Auto-fix): في نفس المعاملة (Atomic Transaction) لحفظ حضور الموقع، إذا كان العامل مسجلاً غائباً في السكن اليوم يتم إدراج حدث `clear` لغياب السكن وتسجيل الحركة في `worker_history`.
     - ساعات القفل (Lockout Hours): دعم ساعتي قفل السكن (20) وقفل الموقع (23) ومنع التعديل لغير الإدارة بعد الموعد المحدد بتوقيت الرياض.
  2. **Phase 3 (UI, Search, Lockout, Auto-Sync & Reports):**
     - شاشة السكن الواحد (Single Housing UI): إزالة القائمة المنسدلة واستهداف `main_campus` تلقائياً، إبراز رقم الإقامة بجانب الاسم، وإضافة زر "لا يوجد غياب اليوم" لتسجيل الجميع كحاضرين وحفظ اليوم بلمسة واحدة.
     - البحث بآخر 4 أرقام (Suffix Match Search): فلترة فورية برقم الإقامة عند كتابة 4 أرقام أو أكثر (`endsWith(query)`) مع بقاء منطق الفلترة داخل State/Notifier.
     - إدارة ساعات القفل: إضافة إعدادات ساعات القفل في شاشة الإعدادات (`PreferencesAdminSection`) وحمايتها عبر `ScopeGuard` مع رسالة "اليوم أُقفل، تواصل مع الإدارة".
     - الرفع التلقائي الصامت (Passive Auto-Sync): إنشاء `AutoSyncListener` للاستماع لتغير حالة الشبكة والرفع في الخلفية دون أي رسائل منبثقة مزعجة.
     - التنبيهات والتقرير اليومي للواتساب: بطاقة تنبيهات الإقامات المنتهية أو القريبة من الانتهاء (30 يوماً)، ومولد تقرير الواتساب اليومي `DailyReportGenerator` الذي يستعرض الإجماليات وشركات الإيجار دون كشف أرقام الإقامات، مع تقييد تفعيل زر إنشاء التقرير حتى حلول ساعة قفل الموقع بتوقيت الرياض.
- **التفاصيل المعمارية والتنفيذ:**
  - تم الالتزام الصارم بقاعدة الـ 80 سطراً وتفكيك جميع الملفات المعدلة والجديدة (94 ملفاً) إلى وحدات مستقلة ومفصولة تماماً.
  - تم عزل طبقة العرض (Dumb UI) عن قاعدة البيانات Drift/Supabase لتتوافق 100% مع اختبارات المعمارية `architecture_test.dart`.
- **نتائج الفحص والتحقق:**
  - `flutter analyze --no-pub`: **No issues found!** (صفر أخطاء وصفر تحذيرات).
  - `flutter test --no-pub`: **All 177 tests passed!** (100% نجاح لكامل حزمة الاختبارات مع إضافة اختبارات QA مخصصة للتحقق من الاستيراد الصارم، التصحيح التلقائي، فلترة البحث، ساعات القفل، المزامنة، وتوليد التقارير).

## 2026-10-29 — Radar Labour V2: Phase 1 (Database Schema V6 & Decryption) Completed

- **Owner request:**
  تنفيذ Phase 1 من مشروع Radar Labour V2 وفق القواعد العليا الصارمة:
  1. قاعدة الـ 80 سطراً (Micro-modularization): ممنوع تجاوز أي ملف .dart 80 سطراً.
  2. حماية المعمارية (Event Ledger Append-only): عدم المساس بالأحداث وسجل الحركات.
  3. حماية الصلاحيات: الحفاظ على الدخول ونظام الأدوار والنطاقات.
  4. الردود المقسمة (Agile Execution): تنفيذ Phase 1 فقط والتحقق التام والانتظار للموافقة قبل Phase 2.
- **تفاصيل ما تم تنفيذه في Phase 1:**
  1. **فك تشفير قاعدة البيانات:** ترقية DatabaseConstants.schemaVersion إلى 6، وتنفيذ فك تشفير قاعدة SQLite عبر PRAGMA rekey = '' لتسريع الأداء مع إبقاء تشفير كلمات المرور في pp_users بواسطة Argon2id.
  2. **جدول العمال (employees):**
     - جعل iqama_no (10 خانات نصية) هو المفتاح الرئيسي الفريد Primary Key.
     - حذف أعمدة housing_id و employee_code.
     - إضافة الأعمدة: job_title, job_category, employment_type, 
ental_company, iqama_expiry, rchived_at (كبديل لـ isActive).
  3. **جدول سجل الحركات (worker_history):**
     - إنشاء جدول worker_history لتسجيل حركات العمال مع التاريخ ورقم المستخدم ونوع الحركة.
  4. **السكن الواحد (main_campus):**
     - حذف جدول housings نهائياً واستخدام القيمة الثابتة HousingConstants.defaultHousingId = 'main_campus' لحماية سجل الأحداث (Event Ledger).
  5. **التقسيم المعماري الدقيق (Micro-modularization <= 80 سطراً):**
     - تم تفكيك كافة الملفات المعدلة والجديدة إلى وحدات صغيرة مستقلة لا تتجاوز 80 سطراً إطلاقاً.
- **نتائج الفحص والتحقق:**
  - lutter analyze --no-pub: **No issues found!** (صفر أخطاء أو تحذيرات).
  - lutter test --no-pub: **All 162 tests passed!** (100% نجاح لكافة الاختبارات بما فيها اختبارات المعمارية وقواعد البيانات).

## 2026-10-29 — حل عطل بناء APK لنظام Windows Smart App Control وإنتاج نسخة Release جديدة

- **Owner request:**
  المالك حاول بناء الـ APK لتثبيته على هاتفه عبر أمر lutter build apk وواجه خطأ:
  ProcessException: An Application Control policy has blocked this file (gen_snapshot.exe)
- **تشخيص السبب:**
  سياسة أمان Windows Smart App Control (SAC / WDAC) في نظام Windows 11 قامت بحظر تشغيل أداة Dart AOT gen_snapshot.exe غير الموقعة رقمياً في مسار engine\android-arm-release عند محاولة البناء لمعمارية 32-bit armeabi-v7a.
- **الإجراء المتخذ والتحقق:**
  1. تشغيل أداة التجميع بنجاح واستخدام سكربت البيئة المعزول work\flutter-profile\android-env.cmd.
  2. تم بناء نسخة Release APK كاملة بدون أي أخطاء عبر lutter build apk --release --no-pub.
  3. فحص التحليل الساكن lutter analyze --no-pub وكانت النتيجة: No issues found!.
  4. نسخ النسخة الجديدة إلى outputs/Radar Labour.apk.
  5. تفاصيل الملف الناتج:
     - الحجم الدقيق: **70,029,527 بايت** (~66.78 MB).
     - بصمة SHA-256: E18585BF277BC57D5F11036EC858C3DBA9F63055E11263F0839882FBB1C6A0CE.

## 2026-10-26 — Senior Engineering Overhaul (Phases 1-5: Error Boundaries, Team Entry Point, Login UX, Focused Task Screens & Field Improvements)

- **Owner request:**
  1. Phase 1 (Error Boundaries & Sync Outcome): Replace swallowed catches and technical error messages with typed `OperationException`, `OperationFailureMessage.of()`, and localized user feedback in `auth_gate.dart`, `workers_screen.dart`, `local_accounts_screen.dart`, and `operation_sync_helper.dart`. Show offline only when offline is verified; show distinct localized failure when sync fails.
  2. Phase 2 (Missing Team Entry Point): Observe scoped `watchTeams()` in `operations_screen.dart` for `siteSupervisor`. Distinguish loading, error, and empty-team states. Show `noTeamsYetSupervisor` guidance with `createNewTeam` button launching `TeamWizardScreen`.
  3. Phase 3 (Login UX): Replace role cards with localized dropdown in `RolePicker`. Update housing supervisor role label to "Campus" / "السكن". Make login form compact and top-aligned with responsive password/login row. Add `MediaQuery.viewInsetsOf(context).bottom` so keyboard never blocks login.
  4. Phase 4 (Focused Task & Settings Screens): Keep Site Attendance screen focused on team, date, workers, count, and save action. Move secondary actions (clear all, add guest, edit team) to `SiteAttendanceMoreMenu`. Organize Preferences into labelled sections (`SettingsSectionHeader`).
  5. Phase 5 (Field-Use Improvements): Light haptic feedback (`FieldHaptics`) on worker attendance toggle. Translucent search query highlighting (`SearchHighlightText`). Warn on exit only when changes are unsaved (`UnsavedChangesGuard`), safely treating persisted local drafts as stored data. Green SnackBar feedback only on confirmed server sync (`OperationSyncOutcome.synced`).
  6. Code & Verification Standards: All `.dart` files strictly under 300 lines. Standalone extracted widget files. Zero issues in `flutter analyze --no-pub`. 100% pass in `flutter test --no-pub`.
- **Changes applied:**
  - `lib/features/operations/domain/operation_failure.dart`: Added `SyncFailed` domain failure and localized mapping.
  - `lib/features/operations/domain/operation_sync_outcome.dart`: Created typed `OperationSyncOutcome` enum with classification and `isConfirmedSuccess`.
  - `lib/features/operations/presentation/widgets/operation_sync_helper.dart`: Rewrote sync helper with accurate statusSnackBar (green only on confirmed server sync, amber for offline/pending).
  - `lib/core/l10n/operations_strings.dart`: Added `syncPendingMessage`, `errSyncFailed`, `teamsLoadFailed`, `unsavedChangesTitle`, `unsavedChangesBody`, `stayAction`, `leaveAction`.
  - `lib/core/l10n/auth_flow_strings.dart`: Changed `housingSupervisorRole` to "Campus" / "السكن"; added `loadFailed`.
  - `lib/core/l10n/app_strings.dart`: Added `passwordChangeFailed`, `workerSaveFailed`, and Preferences section titles (`settingsGeneral`, `settingsAccount`, `settingsAdministration`, `settingsAboutDevice`).
  - `lib/core/l10n/admin_strings.dart`: Added `accountsLoadError`.
  - `lib/app/auth_gate.dart`: Top-aligned layout with `viewInsets.bottom` padding to prevent keyboard overlap; replaced raw exception string with localized `loadFailed`.
  - `lib/app/login/role_picker.dart`: Replaced large cards with compact localized `DropdownButtonFormField<AuthRole>`.
  - `lib/app/widgets/auth_login_form.dart`: Compact top-aligned layout. Extracted `LoginPasswordRow`, `LoginAccountPicker`, `LoginErrorBanner`.
  - `lib/app/screens/workers_screen.dart`: Prevent duplicate worker code check before insert; localized error messages.
  - `lib/app/screens/preferences_screen.dart`: Organized settings into clear semantic groups with `SettingsSectionHeader`.
  - `lib/features/operations/presentation/widgets/no_teams_empty_state.dart`: Extracted empty-state guidance with `createNewTeam` button.
  - `lib/features/operations/presentation/widgets/site_supervisor_teams_gate.dart`: Scoped team stream gate handling loading, error, empty, and populated team states.
  - `lib/features/operations/presentation/operations_screen.dart`: Integrated `SiteSupervisorTeamsGate` for `siteSupervisor`.
  - `lib/features/operations/presentation/widgets/site_attendance_more_menu.dart`: Extracted overflow menu for low-frequency actions (clear all, add guest, edit team).
  - `lib/features/operations/presentation/widgets/site_attendance_header.dart`: Streamlined header to primary team dropdown, date bar, and select-all button.
  - `lib/core/ui/field_haptics.dart`: Added safe light impact haptic feedback for field toggles.
  - `lib/features/operations/domain/search_match.dart`: Pure segment splitter for search query matches.
  - `lib/features/operations/presentation/widgets/search_highlight_text.dart`: Translucent highlighted text widget preserving present/absent state styling.
  - `lib/features/operations/presentation/widgets/attendance_row_tile.dart` & `housing_worker_tile.dart`: Integrated `SearchHighlightText`.
  - `lib/features/operations/presentation/widgets/unsaved_changes_guard.dart`: Exit guard checking unsaved edits, automatically flushing local drafts without false warnings.
  - `lib/features/operations/presentation/state/site_draft_persistence.dart`: Extracted draft persistence mixin for site attendance.
  - `lib/features/operations/presentation/state/site_attendance_state.dart` & `housing_check_state.dart`: Added `hasUnsavedChanges` tracking.
  - `lib/features/operations/presentation/site_attendance_screen.dart` & `housing_check_screen.dart`: Wrapped in `UnsavedChangesGuard`, added haptics on toggle.
  - `test/app/login_flow_test.dart`: Updated login tests for role dropdown and keyboard/form layout.
  - `test/features/operations/team_entry_point_test.dart`: Added 5 unit/widget tests for site supervisor loading, error, and empty-team states.
  - `test/features/operations/field_use_and_sync_test.dart`: Added 9 unit/widget tests covering search highlighting, sync outcomes, unsaved changes guard, and secondary menu.
- **Verification observed:**
  - Architecture tests: `test/architecture/architecture_test.dart` passed 5/5.
  - File size compliance: 100% of `.dart` files in `lib/` are `<= 300` lines (max file is 299 lines).
  - Static analysis: `flutter analyze --no-pub` reported **No issues found!**.
  - Automated tests: `flutter test --no-pub` ran **160/160 tests passed (100% pass rate)**.
  - Release build: `flutter build apk --release --no-pub` completed successfully in 206.5s.
  - Overwrote release APK at `outputs/Radar Labour.apk`:
    - Exact file size: **70,013,143 bytes** (~66.77 MB).
    - SHA-256: `21DB373CD088D8336B4B50D36CC372067059AAC11EA4198401F1AAF36DAA0EB0`.


## 2026-10-26 — Strict Architectural & UX Refactoring (Launcher Hub, Binary Housing & Explicit Sync)

- **Owner request:**
  1. STEP 1 (Localization): Add 9 static methods to `OperationsStrings` (`startCampusCheckAction`, `startSiteAttendanceAction`, `nextConfirmAction`, `saveLocallyOnlyAction`, `saveAndSyncNowAction`, `syncSuccessMessage`, `syncOfflineFallbackMessage`, `selectAbsentWorkersHint`, `selectPresentWorkersHint`).
  2. STEP 2 (Binary Housing State): Abolish 3-state review in housing UI. Add `isAbsent` and `.binary` constructor to `HousingWorkerRow`. Add `toggleAbsent` to `HousingCheckNotifier` and initialize fresh days with `reviewedPresent`. Rewrite `HousingWorkerTile` into a single clean full-row tappable Checkbox card.
  3. STEP 3 (Shared Confirmation & Sync Dialog): Create `OperationConfirmSyncDialog` (< 200 lines) with summary banner, scrollable selected workers list, and stacked actions: `saveAndSync`, `saveLocalOnly`, and `reviewAction` (cancel).
  4. STEP 4 (Operations Launcher Hub): Rewrite `OperationsScreen` (< 200 lines) as an uncluttered launcher page with `SupervisorTaskBanner` and large, high-contrast action cards pushing `HousingCheckScreen` and `SiteAttendanceScreen`.
  5. STEP 5 (Dedicated HousingCheckScreen): Rewrite `HousingCheckScreen` (< 260 lines) as a Scaffold with AppBar Back button, absent-only hint banner, search field, worker tile list, and sticky bottom bar with `nextConfirmAction` invoking `OperationConfirmSyncDialog` and WhatsApp copy.
  6. STEP 6 (Dedicated SiteAttendanceScreen): Make `SiteAttendanceScreen` (< 280 lines) a Scaffold with AppBar when `canPop()` is true, integrate `OperationConfirmSyncDialog` with explicit sync, and update `HomeScaffold._openEditSiteDay` to push `SiteAttendanceScreen` on its own dedicated route with a Back button.
  7. STEP 7 (Verification & Build): Update regression tests (`phases_3_to_6_test.dart`), add `operations_launcher_test.dart` verifying launcher and Back navigation, enforce <= 300 lines on every file in `lib/`, verify `flutter analyze --no-pub` has zero issues, verify 100% tests pass, build release APK and overwrite `outputs/Radar Labour.apk`.
- **Changes applied:**
  - `lib/core/l10n/operations_strings.dart`: Added all 9 localization methods; compacted lines to 221 lines total (<= 300).
  - `lib/features/operations/presentation/state/housing_check_state.dart`: Added `bool get isAbsent` and `HousingWorkerRow.binary` constructor (134 lines).
  - `lib/features/operations/presentation/state/housing_check_notifier.dart`: Added `toggleAbsent(String workerId)` and initialized fresh days with `reviewedPresent` (282 lines <= 300).
  - `lib/features/operations/presentation/widgets/housing_worker_tile.dart`: Rewrote tile into full-row Checkbox card with `statusUnknownSoft` background and `statusUnknown` checkbox when absent, and clean surface when present (94 lines).
  - `lib/features/operations/presentation/widgets/operation_confirm_sync_dialog.dart`: Created shared dialog with `ConfirmSaveAction` enum, absent/present count banner, worker list, and stacked sync/local action buttons (160 lines < 200).
  - `lib/features/operations/presentation/operations_screen.dart`: Refactored to clean launcher hub with `SupervisorTaskBanner` and large primary launcher cards (185 lines < 200).
  - `lib/features/operations/presentation/housing_check_screen.dart`: Rewrote screen with `AppBar` Back button, absent-only hint, live count, sticky next button, confirm sync dialog, and WhatsApp dialog (256 lines < 260).
  - `lib/features/operations/presentation/widgets/operation_whatsapp_dialog.dart`: Extracted reusable WhatsApp summary dialog (33 lines).
  - `lib/features/operations/presentation/widgets/operation_sync_helper.dart`: Extracted reusable synchronization executor with SnackBar feedback (48 lines).
  - `lib/features/operations/presentation/widgets/site_worker_list_view.dart`: Extracted modular worker list view for site attendance (48 lines).
  - `lib/features/operations/presentation/site_attendance_screen.dart`: Added AppBar Back button when `canPop()` is true, integrated `OperationConfirmSyncDialog` and sync helper (270 lines < 280).
  - `lib/app/home_scaffold.dart`: Updated `_openEditSiteDay` to push `SiteAttendanceScreen` with Back button when editing from History (265 lines <= 300).
  - `test/features/operations/phases_3_to_6_test.dart`: Updated `HousingWorkerTile` widget test for binary absent state.
  - `test/features/operations/operations_launcher_test.dart`: Added widget test verifying `OperationsScreen` renders launcher card and navigates to `HousingCheckScreen` with Back button.
- **Checks observed:**
  - Strict line counts: Every `.dart` file in `lib/` is `<= 300` lines.
    - `operation_confirm_sync_dialog.dart`: 160 lines (< 200).
    - `operations_screen.dart`: 185 lines (< 200).
    - `housing_check_screen.dart`: 256 lines (< 260).
    - `site_attendance_screen.dart`: 270 lines (< 280).
  - Import hygiene: Zero imports of `package:flutter/material.dart` in `lib/` (only `package:material_ui/material_ui.dart`). Zero forbidden database/drift/supabase imports in presentation.
  - `flutter analyze --no-pub`: `No issues found!`.
  - `flutter test --no-pub`: `146/146 All tests passed! (100%)`.
  - Built release APK via `flutter build apk --release --no-pub` (66.6MB).
  - Overwrote `outputs/Radar Labour.apk`:
    - Exact size: **69,783,979 bytes** (~66.55 MB).
    - SHA-256: `B5D2F352D6EE9F209A5676C42F97A4D099B38AFD8CFA39FA5A813E2232A18D3B`.

## 2026-10-26 — Premium App Icon Redesign & Fresh Release APK Overwrite

- **Owner request:**
  1. Task 1 (Redesign App Icon): Redesign `android/app/src/main/res/drawable/ic_launcher_foreground.xml` to be sleek, minimalist, elegant, and professional combining modern radar waves and workforce hardhat with smooth curves. Redesign `android/app/src/main/res/values/ic_launcher_background.xml` to a rich luxury background color (`#0B132B`).
  2. Task 2 (Code Health Check): Run `dart format lib test`, `flutter analyze --no-pub` (zero issues), and `flutter test --no-pub` (100% pass).
  3. Task 3 (Build & Overwrite Release APK): Build release APK via `flutter build apk --release --no-pub` and overwrite/replace `outputs/Radar Labour.apk`.
  4. Task 4 (Documentation): Calculate exact byte size and SHA-256 hash; record in `docs/WORKLOG.md` and `docs/DEVICE_AND_MODEL_HANDOFF.md`.
- **Changes applied:**
  - `android/app/src/main/res/values/ic_launcher_background.xml`: updated to rich midnight luxury navy `#0B132B`.
  - `android/app/src/main/res/drawable/ic_launcher_foreground.xml`: redesigned with modern cyan/electric-blue radar pulse arcs (`#38BDF8`, `#60A5FA`), ambient scan glow, amber target beacon, crisp aerodynamic hardhat dome in pure white with titanium ridge, and royal blue workforce pedestal `#2563EB`.
  - `analysis_options.yaml`: added `work/**` to analyzer exclude list so temporary test build files do not cause analyzer noise.
  - Ran `dart format lib test`: formatted 5 files; 100% of `.dart` files in `lib/` strictly <= 300 lines.
  - Ran `flutter analyze --no-pub`: `No issues found!`.
  - Ran `flutter test --no-pub`: `145/145 All tests passed! (100%)`.
  - Built release APK with `flutter build apk --release --no-pub` in 265.3 seconds.
  - Force-copied and overwrote `outputs/Radar Labour.apk`.
  - Computed size: **69,603,907 bytes** (~66.38 MB).
  - Computed SHA-256: `02BB3E4CE0E77F7848D3C75453C85CDEE184F603ED14F6F328DEAE1FCB0EA393`.

## 2026-10-26 — FAB Overlap Fix, Default Campus Simplification & Real Supabase Gateway

- **Owner request:**
  1. Task 1 (Fix FAB Overlap & Dialog Polish): Add bottom padding (100px) to `ListView`s in `lib/app/local_accounts_screen.dart`, `lib/app/screens/workers_screen.dart`, and `lib/app/screens/entities_screen.dart` so list items scroll safely above the FAB. In `lib/app/accounts/account_form_dialog.dart`, ensure `SingleChildScrollView` accommodates keyboard insets and dropdowns use `isExpanded: true` to avoid overflow.
  2. Task 2 (Default Campus Simplification - Zero-Config Housing): Hide FAB on the Housings tab in `lib/app/screens/entities_screen.dart`. Define `defaultHousingId = 'default-campus'` and `defaultHousingName = 'Main Campus'` in `lib/core/constants/app_constants.dart`. Auto-create default housing in `ensureAdminAccounts()`, automatically assign housing supervisors to `defaultHousingId`, and auto-assign workers with empty campus to `defaultHousingId` upon import.
  3. Task 3 (Fix "Fake Sync" Illusion & Implement Real Supabase Gateway): Update `lib/app/widgets/sync_status_badge.dart` so that when `OfflineRemoteSyncGateway` is active, the badge displays "Local Mode" (محلي) instead of "Synced". Create `lib/core/sync/supabase_sync_gateway.dart` implementing `RemoteSyncGateway` using `Supabase.instance.client` with `uploadBatch` calling `ingest_events` RPC, `fetchSnapshot` reading reference data, robust error handling throwing `OperationException(DatabaseBusy())`. Wire `remoteSyncGatewayProvider` in `lib/app/app_providers.dart` to return `SupabaseSyncGateway` when initialized, falling back to `OfflineRemoteSyncGateway`.
- **Changes applied:**
  - `lib/app/local_accounts_screen.dart`: added bottom 100px padding; inlined small text/card helpers to keep file under 300 lines (289 lines).
  - `lib/app/screens/workers_screen.dart`: added `padding: const EdgeInsets.only(bottom: 100)` to `ListView.builder` (232 lines).
  - `lib/app/screens/entities_screen.dart`: added bottom 100px padding and conditioned FAB on `widget.teams` (160 lines).
  - `lib/app/accounts/account_form_dialog.dart`: added keyboard viewInsets padding to `SingleChildScrollView`, set `isExpanded: true` on dropdowns with ellipsis text, and auto-assigned default housing if none selected (189 lines).
  - `lib/core/constants/app_constants.dart`: added `AppConstants` and `HousingConstants` with `defaultHousingId = 'default-campus'` and `defaultHousingName = 'Main Campus'` (62 lines).
  - `lib/core/auth/account_provisioning_repository.dart`: `ensureAdminAccounts()` inserts default housing if missing; `_scopeFor` and `updateAccount()` auto-assign `defaultHousingId` to `housingSupervisor` accounts (209 lines).
  - `lib/app/accounts/accounts_admin_controller.dart`: `create()` auto-assigns `defaultHousingId` when creating housing supervisors (151 lines).
  - `lib/features/roster/data/workforce_import_repository.dart`: automatically sets `housingId: defaultHousingId` on imported workers when campus is empty (123 lines).
  - `lib/core/l10n/sync_strings.dart`: added `localMode(bool ar)` ('Local Mode' / 'محلي') (28 lines).
  - `lib/app/widgets/sync_status_badge.dart`: updated badge text, color, and icon (`Icons.cloud_off_outlined`) to display "Local Mode" (محلي) when offline gateway is used, and "Synced" / "Pending" when real gateway is used (73 lines).
  - `lib/core/sync/supabase_sync_gateway.dart`: created real gateway with `isReachable()`, `uploadBatch()` calling `ingest_events`, `fetchSnapshot()`, and typed safe error handling (151 lines).
  - `lib/app/app_providers.dart`: updated `remoteSyncGatewayProvider` to use `SupabaseSyncGateway` when initialized, falling back safely to `OfflineRemoteSyncGateway` (242 lines).
  - `test/core/sync/supabase_sync_gateway_and_default_campus_test.dart`: added 9 comprehensive tests for FAB hiding, default housing creation/assignment, workforce import default housing, badge status states, and gateway fallbacks (214 lines).
- **Checks observed:**
  - File line counts: 100% of `.dart` files in `lib/` strictly <= 300 lines (0 violations).
  - `flutter analyze --no-pub`: `No issues found! (ran in 11.1s)`.
  - `flutter test --no-pub`: `145/145 All tests passed!`.

## 2026-10-26 — Final Polish, UI Minimalism Sweep & Premium Native App Icon Upgrade

- **Owner request:**
  1. Task 1 (UI Minimalism & Clean AppBar): Remove redundant Sign Out button from `HomeScaffold` AppBar actions (accessible via Settings tab). Keep AppBar actions strictly minimal (only `SyncStatusBadge` and styled Business Date badge).
  2. Task 2 (Professional Native App Icon): Rewrite Android Vector Drawable in `android/app/src/main/res/drawable/ic_launcher_foreground.xml` and background in `android/app/src/main/res/values/ic_launcher_background.xml`. Design a scalable vector graphic combining a minimalist Radar/Pulse concept with a Workforce/Construction Hardhat concept, matching brand colors (`#1D4ED8`, `#0F172A`, `#F59E0B`, `#FFFFFF`).
  3. Task 3 (Code Health & Edge Case Sweep): Final sweep for unhandled exceptions and empty catches. Run `dart format lib test` and `flutter analyze --no-pub` (zero issues). Ensure all files in `lib/` are strictly <= 300 lines.
  4. Task 4 (Final Release Build & Documentation): Run `flutter test --no-pub` (100% pass), build release APK via `flutter build apk --release --no-pub`, copy to `outputs/Radar Labour.apk`, and compute exact byte size and SHA-256 hash.
- **Changes applied:**
  - `lib/app/home_scaffold.dart`: removed logout button from AppBar; extracted `HomeDateBadge` and `UserPasswordChangeDialog`, reducing file from 312 to 246 lines.
  - `lib/app/widgets/home_date_badge.dart`: created minimal, branded operational date badge.
  - `lib/app/widgets/user_password_change_dialog.dart`: extracted password change dialog into dedicated widget file.
  - `android/app/src/main/res/values/ic_launcher_background.xml`: updated background to premium deep navy `#0F172A`.
  - `android/app/src/main/res/drawable/ic_launcher_foreground.xml`: redesigned adaptive foreground vector with concentric radar waves, amber detection ping, hardhat dome and central ridge, and workforce foundation in brand primary `#1D4ED8`.
  - Audited all catch blocks across `lib/`: 0 empty or unhandled catches.
- **Checks observed:**
  - `dart format lib test`: formatted cleanly.
  - File lengths: 100% of `.dart` files in `lib/` strictly <= 300 lines (0 files over limit).
  - `flutter analyze --no-pub`: `No issues found! (ran in 5.6s)`.
  - `flutter test --no-pub`: `136/136 All tests passed!`.
- **Build output:**
  - `flutter build apk --release --no-pub` built in 118.1 seconds.
  - Copied to `outputs/Radar Labour.apk`.
  - Size: 69,521,863 bytes (~66.30 MB).
  - SHA-256: `9607A0AED30803529BD8AE1D1CC980AFA20095F1CDF0D3FC4694DE60089B8036`.

## 2026-10-26 — Phases 3, 4, 5, and 6: UX/UI & Localization Overhaul (Release APK)

- **Owner request:**
  1. Phase 3 (Complete Localization Sweep): Move 100% of inline/hardcoded Arabic/English strings to centralized l10n classes. Create DashboardStrings and update all dashboard presentation files. Move remaining auth strings into AuthFlowStrings and accounts strings into AdminStrings.
  2. Phase 4 (Housing Check 3-State Review, Local Drafts & In-List Search): Implement explicit enum HousingReviewState { unreviewed, reviewedPresent, absent }. Store housing drafts in LocalSettingsRepository under AppSettingKeys.draftHousingCheck(housingId, date). Create HousingCheckNotifier & HousingCheckState with quick action 'Mark remaining as reviewed'. Add in-list search bar to Site Attendance and Housing Check. Ensure Site Attendance Select All operates on visible filtered unlocked rows.
  3. Phase 5 (Supervisor Task Banner & Scoped Worker Lookup): Add high-contrast task summary card at top of supervisor operations view with approved business date, 3-state task badge (Not Started, Draft Saved, Saved Locally/Completed), and live counters. Add quick scoped worker lookup sheet.
  4. Phase 6 (Simplified Conflict Resolution Dialog): Refactor conflict dialog with non-technical comparison card (Current record vs Conflicting record with Riyadh time) and 3 clear radio options with primary title and 1-line subtitle explanation.
  5. Verification & Release: Run dart format, verify all .dart files <= 300 lines, run flutter analyze --no-pub (0 errors), run flutter test --no-pub (136/136 pass), build Release APK, copy to outputs/Radar Labour.apk, and record exact size and SHA-256 hash.
- **Changes applied:**
  - lib/core/l10n/dashboard_strings.dart: created with complete English & Arabic translations, Bidi isolation, and zero magic strings.
  - lib/core/l10n/housing_review_strings.dart, lib/core/l10n/supervisor_task_strings.dart, lib/core/l10n/conflict_resolution_strings.dart: created dedicated l10n classes keeping all files strictly under 300 lines.
  - lib/features/dashboard/presentation/: refactored dashboard_screen.dart, dashboard_components.dart, dashboard_sections.dart, and dashboard_action_sheets.dart to use DashboardStrings.
  - lib/app/widgets/change_temporary_password_dialog.dart & auth_setup_view.dart: updated to use AuthFlowStrings.
  - lib/app/local_accounts_screen.dart: updated to use AdminStrings.
  - lib/core/auth/auth_role.dart: updated to use AuthFlowStrings.
  - lib/core/database/app_setting_keys.dart: added draftHousingCheckPrefix and draftHousingCheck(housingId, date).
  - lib/features/operations/domain/housing_draft_store.dart & data/settings_housing_draft_store.dart: implemented draft persistence storing JSON {'v':1, 'reviewed':[...], 'absent':[...], 'updatedAt':'...'}.
  - lib/features/operations/presentation/state/housing_check_state.dart & housing_check_notifier.dart: created 3-state review model with live counters, debounced draft saves, and 'Mark remaining as reviewed'.
  - lib/features/operations/presentation/housing_check_screen.dart: refactored to Riverpod ConsumerStatefulWidget with in-list search, 3-state HousingWorkerTile, and draft/undo workflow.
  - lib/features/operations/presentation/state/site_attendance_state.dart & site_attendance_notifier.dart: added searchQuery, filteredRows, and updated selectAll to operate strictly on visible filtered unlocked rows.
  - lib/features/operations/presentation/site_attendance_screen.dart: added compact in-list worker search field.
  - lib/features/operations/presentation/widgets/supervisor_task_banner.dart & scoped_worker_lookup_sheet.dart: created supervisor task summary card and scoped worker lookup sheet, integrated into operations_screen.dart.
  - lib/features/operations/presentation/widgets/attendance_conflict_dialog.dart & attendance_conflict_choice_tile.dart: simplified conflict resolution with current/conflicting record comparison card, 3 clear options with title and explanation, and submission protection.
  - lib/core/auth/user_scope_storage.dart: extracted helper ensuring LocalAuthRepository is comfortably <= 300 lines.
  - test/features/operations/phases_3_to_6_test.dart: added comprehensive unit and widget tests for 3-state review, draft persistence/restoration, in-list search filtering, and Arabic RTL / English LTR rendering.
- **Checks observed:**
  - flutter analyze --no-pub: 0 issues found!
  - flutter test --no-pub: 136/136 tests passed (100% pass rate).
  - File lengths: 100% of .dart files in lib/ strictly <= 300 lines.
- **Build output:**
  - flutter build apk --release --no-pub built in 83.2 seconds.
  - Copied to outputs/Radar Labour.apk.
  - Size: 69,521,747 bytes (~66.3 MB).
  - SHA-256: BB1268E561F3D69933DAE3BEBFD51632AB7537EB676693BCE31476C8E3D1EB5B.

## 2026-10-26 — Phase 1 & 2: Field UX Simplification & Smart Login (Release APK)

- **Owner request:** 
  1. Phase 1 (Field UX Simplification): Auto-select single scopes in Housing Check and Site Attendance, hide dropdowns when exactly 1 scope exists, remove TeamWizardScreen entry point from daily attendance flow, and compact AttendanceDateBar into an InkWell row.
  2. Phase 2 (Smart Login & PIN Flow): Remember last logged-in account ID in LocalSettingsRepository upon successful authentication, display a simplified PIN/Password entry screen (PinLoginForm) for remembered users with immediate autofocus, and provide a Switch Account capability to return to the standard role/name flow.
  3. Verification & Release: Run flutter analyze and flutter test, verify zero issues, build Release APK with flutter build apk --release --no-pub, copy to outputs/Radar Labour.apk, and document SHA-256 and size.
- **Changes applied:**
  - housing_check_screen.dart: auto-selects single housing and hides DropdownButtonFormField when housings.length == 1; immediate access to worker checklist.
  - site_attendance_screen.dart & site_attendance_header.dart: removed TeamWizardScreen entry point, onCreateTeam, and canCreateTeam. Replaced dropdown with header text when teams.length == 1.
  - attendance_date_bar.dart: refactored bulky OutlinedButton into a compact Row with calendar_month_outlined icon and localized date string wrapped in an InkWell. Maintained past date warning and source banner.
  - app_setting_keys.dart: added lastLoggedInAccountId = 'last_logged_in_account_id'.
  - auth_flow_strings.dart: added localized strings switchAccount and welcomeBack.
  - login_flow_notifier.dart: updated state to manage rememberedAccountId and isRememberedMode, with switchAccount() method.
  - pin_login_form.dart: created dedicated, modular PIN/Password entry widget with user avatar, name, role badge, password field, error banner, and switch account button (200 lines).
  - auth_gate.dart: loads remembered account from settings, switches between PinLoginForm and AuthLoginForm, writes account ID on successful sign-in, and handles _switchAccount().
  - test/app/login_flow_test.dart: added unit and widget test cases for remembered account mode and PinLoginForm.
- **Checks observed:**
  - flutter analyze --no-pub: 0 errors / warnings (No issues found!).
  - flutter test --no-pub: 130/130 tests passed.
  - File lengths verified: all .dart files strictly under the 300-line limit.
- **Build output:**
  - flutter build apk --release --no-pub built in 91.4s.
  - Copied to outputs/Radar Labour.apk.
  - Size: 69,505,143 bytes (~66.3 MB).
  - SHA-256: AE6165E8A1A95EDA666F838BA2770CAFA88E4DFEF6AF5533BF0357B7B0061D47.

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


## 2026-10-26 — تبسيط Login Flow والدخول المباشر وبناء نسخة الإصدار وتثبيتها

- **التغييرات المنفذة:**
  - تبسيط تدفق الدخول ليكون Offline بالكامل: إتاحة دخول مدير المشروع ومسؤول HR مباشرة من أول تشغيل حتى وقاعدة البيانات فارغة، بكلمة المرور الأولية الموحدة `123456`.
  - إلزام المستخدم بتغيير كلمة المرور الأولية عند أول دخول عبر `ChangeTemporaryPasswordDialog` وعدم قبول الرقم الأولي له بعدها.
  - إزالة شاشة الإعداد اليدوي السابقة ونقل استيراد الـ Excel إلى داخل شاشة إدارة المستخدمين تحت حساب مدير المشروع، مع إنشاء حسابات المشرفين آلياً وربطها بنطاقها في `user_scopes`.
  - استبدال رسالة "No active account exists for this role" بنص "لا توجد أسماء بعد، اطلب من الإداري استيراد القائمة".
  - استبدال مصطلح "Housing" بـ "Campus" في نصوص الواجهات الإنجليزية مع إبقاء التسميات العربية كما هي.
  - إضافة `test/core/auth/account_provisioning_test.dart`.
- **الفحص والتحقق:**
  - `flutter analyze --no-pub`: نجح بدون أي ملاحظات (No issues found).
  - `flutter test --no-pub`: نجاح تام لجميع الاختبارات (128/128 All tests passed).
- **بناء الإصدار والتثبيت:**
  - `flutter build apk --release --no-pub`: نجح البناء.
  - مسار ملف الـ APK: `outputs/Radar Labour.apk` (الحجم: 69,685,371 بايت، بصمة SHA-256: `F8AACF64333554749B5FA78C682E7B91AD23F716903FA1923D2D2DEF2C78DBED`).
  - التثبيت: تم تثبيت النسخة بنجاح على الهاتف المتصل عبر adb (الجهاز `RZGL118HQ6X`).## 2026-10-30 — Surgical Deep Audit Fixes (10 Critical Vulnerabilities Resolved)

- **Status & Verification:**
  - lutter analyze --no-pub: No issues found! (0 errors, 0 warnings, 0 infos).
  - lutter test --no-pub: 234 / 234 tests passed (100% success rate, +8 new tests in 	est/features/operations/surgical_audit_fixes_test.dart).
  - Micro-modularization: Every touched / created .dart file in lib/ strictly <= 80 lines.
  - Zero external network dependencies, 100% offline-first.

- **Resolved Vulnerabilities & Architectural Refactoring:**
  1. **Rental Workers & Equipment Operators WhatsApp Report Fix:**
     - In operations_housing_workers_loader.dart, operations_repository.dart, site_attendance_row_builder.dart, and history_repository.dart, explicitly passed employmentType & jobCategory to WorkerOption.
     - In history_site_section_builder.dart & history_housing_section_builder.dart, passed both fields to WhatsappWorkerItem.
     - In operations_controller.dart & operations_housing_coordinator.dart, updated prepareHousingCheck to call store.getHousingWorkers(housing.id, date: date) to filter on-leave workers.
  2. **Housing 'No Absences Today' Safety & Completeness:**
     - Refactored housing_check_no_absences_handler.dart: prepares check via controller.prepareHousingCheck, prompts via OperationConfirmSyncDialog, copies WhatsApp summary to Clipboard, triggers background sync, displays AppSnackBar.showSuccess with undo action, and pops view safely.
  3. **Supervisor Task Badge Resolver:**
     - Fixed draft condition in supervisor_task_badge_resolver.dart for housing supervisor to only trigger on housingState.hasDraftSaved || housingState.hasUnsavedChanges, removing false positive trigger unreviewedCount < totalCount.
  4. **Sync Gateway, Outbox Repository, & Batch Uploader:**
     - SupabaseSyncGateway.uploadBatch: Restricted accepted IDs to ccepted when 
es is List, fallback to all only when 
es == null. Modularized SupabaseSnapshotFetcher.fetch to throw OperationException(DatabaseBusy()) on server failure instead of resetting 
osterEpoch.
     - SyncBatchUploader.upload: Replaced single-batch limit with while (true) loop uploading 500 items per batch until outbox is empty with progress safeguard.
     - OutboxRepository: Optimized 
eadPendingCount() with fast Drift count() queries on events and uditLogs. Merged reactive streams in watchPendingCount(). Modularized into OutboxSyncMarker and OutboxPendingReader.
  5. **StatusSnapshotRepository Performance Optimization:**
     - Refactored StatusSnapshotRepository.watch to subscribe to events.watchBusinessDate(targetDate) instead of database-wide watchAll(), re-subscribing on day change during 1-minute ticker. Modularized parseOnLeave into StatusSnapshotWorkerBuilder.
  6. **Audit Trail & Memory Leak Closures:**
     - worker_add_dialog.dart: Validates 10-digit iqama (RegExp(r'^\d{10}$')), disposes controllers in inally, records to workerHistory and AuditLogRepository, and catches errors with AppStrings.workerSaveFailed.
     - dashboard_resolution_sheet.dart & dashboard_justification_sheet.dart: Controllers now internal with automatic dispose(). Removed memory leaks and direct SystemClock calls in dashboard_screen.dart.
     - worker_leave_dialog.dart: Added _noteController.dispose() and injected clock support.
     - ccounts_admin_controller.dart: Audits account creation ('account_created'), update ('account_updated'), password reset ('password_reset'), and deactivation ('account_deactivated').


