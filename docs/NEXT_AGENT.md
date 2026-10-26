# تسليم العمل للموديل التالي

**آخر تحديث:** 26 أكتوبر 2026. ابدأ من `AGENTS.md` في جذر المشروع، ثم اقرأ
`README.md` و`docs/README.md` و`DEVICE_AND_MODEL_HANDOFF.md` و`DECISIONS.md` وهذا
الملف. بعد ذلك راجع `WORKLOG.md` و`BUGS.md` و`ROADMAP.md` و`SECURITY_AND_SYNC_PLAN_V1_5.md`.

## الحالة الحالية (بعد إكمال V1.5 بالكامل)

- اكتملت جميع جلسات `Radar_Labour_PRD_V1_5_Full.md` (الجلسات 0 إلى 11 — المرحلة أ والمرحلة ب).
- قاعدة البيانات المحليّة المشفرة وصلت إلى `schemaVersion=5` (إضافة جدول `audit_log`، وجعل `app_users.employee_uid` اختياريًا لدعم حسابات `viewer`، ومفتاح `roster_epoch`).
- جميع ملفات `.dart` في `lib/` (باستثناء الملفات المولدة `*.g.dart`) تلتزم بالحد الصارم **<= 300 سطر** بعد تشغيل `dart format`.
- الفحص الساكن: `flutter analyze --no-pub` نجح بدون أي تحذير أو خطأ (**No issues found!**).
- الاختبارات الآلية: `flutter test --no-pub` نجح بالكامل (**130/130 All tests passed!**).
- نسخة الإطلاق النهائية مبنية ومنسوخة في `outputs/Radar Labour.apk`:
  - الحجم: **69,505,143 بايت**
  - بصمة SHA-256: `AE6165E8A1A95EDA666F838BA2770CAFA88E4DFEF6AF5533BF0357B7B0061D47`


## تحديث 26 أكتوبر 2026 (Phase 1 & Phase 2 — UX Simplification & Smart Login)

1. **المرحلة 1 (تبسيط واجهات العمليات):**
   - اختيار النطاق الفردي تلقائياً وإخفاء القائمة المنسدلة في فحص السكن (HousingCheckScreen) وحضور الموقع (SiteAttendanceScreen).
   - إزالة مسار إنشاء الفرق (TeamWizardScreen) من تدفق الحضور اليومي، وحصر إعداد الفرق في المسار الإداري.
   - اختزال AttendanceDateBar إلى صف تفاعلي مضغوط (InkWell).
2. **المرحلة 2 (الدخول الذكي دون اتصال):**
   - حفظ الحساب المسجل بنجاح في LocalSettingsRepository عبر AppSettingKeys.lastLoggedInAccountId.
   - شاشة مبسطة مباشرة لإدخال الرمز السري (PinLoginForm) تعرض اسم المستخدم ودوره مع تركيز فوري على حقل الرمز.
   - زر «تبديل الحساب» للعودة إلى شاشة اختيار الدور والاسم عند الحاجة.

## ما أُنجز في V1.5

1. **المرحلة أ (العمليات الميدانية والسجل التاريخي):**
   - فصل تبويب «التسجيل اليومي» عن الإدارة (`HomeScaffold` — BC-1) وحذف قائمة التسجيل من شاشة العمال (`WorkersScreen` — BC-2).
   - بث النطاقات الحي (`LocalAuthRepository.watchScopes`) ومعالج إعداد الفريق من 3 خطوات (`TeamWizardScreen`) وشاشة تعديل أعضاء الفريق (`TeamEditScreen`).
   - التسجيل اليومي الذكي (`SiteAttendanceRepository`, `SiteAttendanceNotifier`, `SiteAttendanceScreen`) بأولويات التحميل الأربع، والمسودة التلقائية، وإضافة العامل الضيف ليوم واحد، وحوار معاينة الفروقات (`AttendanceDiffDialog`)، وحوار حل التعارض المحلي (`AttendanceConflictDialog` مع استثناء D-15)، والتراجع الذري الشامل (`LedgerUndoPlan`)، ومحرك قوالب واتساب (`WhatsAppTemplateEngine`).
   - السجل التاريخي (`HistoryScreen`, `HistoryDayDetailSheet`) للمشرف والإدارة مع نافذة التعديل خلال 7 أيام، وإظهار أسماء المشرفين المسؤولين في بطاقات «لم يسجَّل بعد» (`DashboardCoverageRepository`).
2. **المرحلة ب (الدخول الموجه بالدور، سجل التدقيق، مسح القوى، والمزامنة التلقائية):**
   - تدفق الدخول الموجه بالدور (`RolePicker`, `LoginFlowNotifier`, `AuthLoginForm`, `AuthGate` — BC-5) مع التحقق الصارم من الدور في `signIn` وإعادة تعيين كلمة المرور وتعطيل الحساب في `LocalAccountsScreen` (BC-6).
   - الخطة الأمنية والمعمارية الكاملة في `docs/SECURITY_AND_SYNC_PLAN_V1_5.md`.
   - `AuditLogRepository` و `RosterAdminRepository` و `RosterWipePlan` وتبويب «سجل التغييرات» (`AuditLogTabView`).
   - محرك المزامنة التلقائية (`OutboxRepository`, `RemoteSyncGateway`, `SyncEngine`) ومؤشر المزامنة الهادئ (`SyncStatusBadge`).

## الخطوة التالية المحدودة

1. تثبيت `outputs/Radar Labour.apk` على هاتف المالك وتجربة:
   - الدخول الموجه بالدور (مدير مشروع / HR / مشرف موقع / مشرف سكن / مشاهد).
   - إنشاء فريق من معالج مشرف الموقع وتجربة التسجيل اليومي الذكي والفروقات وحل التعارض والملخص القابل للنسخ.
   - مراجعة السجل التاريخي وتبويب «سجل التغييرات» الإداري.
2. عند رغبة المالك في تفعيل المزامنة السحابية الحية على مشروع Supabase المستضاف، يُطبَّق مخطط SQL/RPC الموثق في `docs/SECURITY_AND_SYNC_PLAN_V1_5.md` ويُربط تنفيذ `SupabaseRemoteSyncGateway` بواجهة `RemoteSyncGateway`.

## البيئة

- لا تشغل `flutter clean` ولا تحذف `.dart_tool` أو كاش Flutter/Pub/Gradle.
- استخدم `work/flutter-profile/android-env.cmd` ثم أوامر Flutter مع `--no-pub`.
