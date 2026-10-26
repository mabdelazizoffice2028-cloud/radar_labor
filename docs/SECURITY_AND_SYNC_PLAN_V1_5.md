# الخطة الأمنية ومعمارية المزامنة — رادار ليبور V1.5 (الجلسة 8)

> **الحالة:** موثقة ومعدة وفق متطلبات القسم 18 (الجلسة 8) والقسم 23 من `Radar_Labour_PRD_V1_5_Full.md` وبالاستناد إلى `docs/SUPABASE_HANDOFF_FOR_GEMINI.md`.
> **القاعدة الحاكمة:** التطبيق محلي وأوفلاين أولًا (Offline-First). لا يُضمَّن أي مفتاح سري (`service_role` أو `secret`) داخل تطبيق Flutter، ولا يُرفع أي رقم هوية أو كلمة مرور خام أو مجزأة محليًا إلى السحابة.

---

## 1. ربط الهوية المحلية (`app_users`) بهوية Supabase Auth (`auth.users`)

1. **فصل مصادقة الجهاز عن مصادقة السحابة:**
   - محليًا، تُخزَّن حسابات `app_users` داخل قاعدة بيانات SQLite المشفرة (SQLCipher / `sqlite3mc`) مع تجزئة Argon2id ورقم البداية المؤقت (`123456`) الذي يُلزم المستخدم بتغييره فور أول دخول (BC-5).
   - لا تُرفع حقول `pw_hash` أو `pw_salt` أو `kdf_params` إلى السحابة في أي جدول.
2. **جدول `public.profiles` في الخادم:**
   - يرتبط كل حساب سحابي بـ `auth.users(id)` عبر المفتاح الأساسي `user_id uuid primary key references auth.users(id) on delete cascade`.
   - يحمل الحقول:
     - `local_account_id text unique not null` (مطابق لـ `app_users.id`).
     - `employee_uid text null references public.employees(employee_uid)` (اختياري لدور `viewer` وفق BC-7).
     - `display_name text not null`.
     - `role text not null check (role in ('projectManager','hr','housingSupervisor','siteSupervisor','viewer'))`.
     - `is_active boolean not null default true`.
     - `row_version integer not null default 1`.
3. **إصدار الهوية والتفعيل:**
   - ينشئ الإداري الحسابات محليًا، وعند المزامنة مع الخادم تُنشأ سجلات `profiles` ونطاقاتها (`profile_teams`, `profile_housings`) عبر وظيفة إدارية موثوقة (Edge Function / Admin RPC) تتحقق من أن المستدعي يحمل دور `projectManager` أو `hr`.
   - يحصل جهاز المشرف عند التفعيل الأول على رمز جلسة (`JWT`) محدود النطاق مرتبط بـ `auth.uid()`.

---

## 2. سياسات أمان مستوى الصف (Row-Level Security — RLS)

تُفعَّل `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` على كافة الجداول دون استثناء:

| الجدول | القراءة (`SELECT`) | الكتابة المباشرة (`INSERT` / `UPDATE` / `DELETE`) |
| :--- | :--- | :--- |
| `app_meta` (`roster_epoch`) | جميع المستخدمين النشطين (`is_active = true`) | عبر دالة `wipe_roster_atomic` للإدارة فقط (`projectManager`, `hr`) |
| `employees`, `teams`, `housings`, `employment_periods` | جميع المستخدمين النشطين (`is_active = true`) لتحديث الدليل المحلي | الإدارة فقط (`projectManager`, `hr`) مع رفع `row_version` وتسجيل `audit_log` |
| `profiles`, `profile_teams`, `profile_housings` | الإدارة تقرأ الكل؛ المشرف/المشاهد يقرأ صفه ونطاقاته فقط (`user_id = auth.uid()`) | الإدارة فقط (`projectManager`, `hr`) |
| `events` | الإدارة والمشاهد يقرأون الكل؛ مشرف الموقع يقرأ أحداث فرقه في `profile_teams`؛ مشرف السكن يقرأ أحداث مساكنه في `profile_housings` | **ممنوعة مباشرةً**؛ تتم حصرًا عبر الدالة الموثوقة `ingest_event_batch` |
| `audit_log` | الإدارة فقط (`projectManager`, `hr`) (Q-5) | **ممنوعة مباشرةً**؛ تتم عبر الدوال الموثوقة في المعاملة نفسها |

---

## 3. الدالة الموثوقة لإدخال الأحداث (`ingest_event_batch`)

لمنع التلاعب بـ `user_id` أو الكتابة خارج النطاق أو تكرار الأحداث عند انقطاع الاتصال، تُنفَّذ جميع عمليات رفع الحضور عبر دالة Postgres `SECURITY DEFINER` مقيدة:

1. **التحقق من الحساب والجلسة:**
   - تتحقق الدالة من أن `auth.uid()` يقابل حسابًا في `profiles` وأن `is_active = true`.
   - تتحقق من `roster_epoch` المرسل مع الدفعة؛ ومع ذلك، وفق القرار **D-25**، تقبل الدالة رفع الأحداث المسجلة أوفلاين قبل مسح القوى أو تعطيل الحساب (مع وسمها بحقبة التسجيل)، ثم تعيد في استجابتها راية `session_revoked = true` و`current_roster_epoch` لينهي العميل الجلسة بأمان بعد ضمان عدم ضياع أي حدث.
2. **منع التكرار (Idempotency):**
   - قيد فريد مزدوج على `event_id` وعلى `(device_id, device_seq)` مع `ON CONFLICT DO NOTHING`. إعادة إرسال الدفعة نفسها بسبب انقطاع الشبكة آمنة تمامًا ولا تكرر أي صف.
3. **فرض النطاق (`ScopeGuard`) على الخادم:**
   - تفرض الدالة `user_id = auth.uid()` بغض النظر عما يرسله العميل.
   - لمشرف الموقع: يجب أن ينتمي `team_id` إلى `profile_teams` الخاصة به، أو يكون الحدث من نوع `site_present` مع `action = 'clear'` و`payload->>'reason' = 'cross_team_correction'` (استثناء D-15 المقيّد والمُدقَّق).
   - لمشرف السكن: يجب أن ينتمي `housing_id` إلى `profile_housings` الخاصة به.
   - لدور `viewer`: يُرفض أي حدث فورًا (`PermissionDenied`).

---

## 4. التفعيل لأول مرة (`ActivationRequired`)

- جهاز الإدارة (`projectManager` / `hr`) هو نقطة البداية: يستورد ملف القوى محليًا (مع تجاهل أرقام الهويات بالكامل وفق D-28) وينشئ حسابات المشرفين والمراقبين.
- أي جهاز جديد لمشرف أو مشاهد لم يتلقَّ بيانات القوى والحسابات بعد يعرض حالة `ActivationRequired` عند محاولة العمل قبل أول مزامنة ناجحة.
- بمجرد إتمام أول اتصال وتنزيل القوى والحسابات والنطاقات، يعمل الجهاز أوفلاين بالكامل.

---

## 5. إنهاء الجلسات ومسح القوى (`SessionRevoked` & `roster_epoch`)

- عند قيام الإدارة بـ **مسح القوى** (`wipeRoster`) أو **تعطيل حساب مشرف** (`deactivateAccount`):
  1. محليًا وعلى الخادم، يرتفع عداد `roster_epoch` بمقدار `+1` (أو تصبح راية `active = false` للحساب).
  2. عند أول مزامنة لجهاز المشرف بعد هذا القرار، يقوم محرك المزامنة (`SyncEngine`) **أولًا** برفع كافة الأحداث المعلقة في صندوق الصادر (`OutboxRepository`) حتى تصبح القراءة المحلية `pendingCount == 0` (D-25).
  3. **ثانيًا**، يحدّث الجهاز نسخته المحلية من `roster_epoch` والقوى والحسابات، ويُنهي جلسة المشرف الحالية برسالة `SessionRevoked` («أنهت الإدارة جلستك»).

---

## 6. النسخ الاحتياطي الإلزامي قبل مسح القوى (`RosterWipeNotConfirmed`)

- لا يُسمح بتنفيذ مسح القوى (`wipeRoster`) إلا بعد تحقق شرطين برمجيًا في `RosterAdminRepository`:
  1. تصدير نسخة احتياطية محلية صالحة (`backupExported == true`) تحتوي على سجل العمال الحالي والفرق والمساكن (دون أي أرقام هوية أو كلمات مرور).
  2. إدخال نص التأكيد المزدوج المطابق (`WIPE` أو `مسح`).
- عند الإخلال بأي من الشرطين، يرمي المستودع `OperationException(RosterWipeNotConfirmed())` ولا يجري أي تعديل على قاعدة البيانات.

---

## 7. قرارات المخطط والحزم للجلسات 9 و10

- **ترقية المخطط المحلي إلى `schemaVersion = 5`:**
  - إضافة جدول `audit_log` للإلحاق فقط (`audit_id`, `user_id`, `action`, `entity_type`, `entity_id`, `device_id`, `device_time`, `received_at`, `sync_status`).
  - جعل العمود `app_users.employee_uid` قابلًا للقيم الفارغة (`nullable`) لدعم إنشاء حساب `viewer` دون ربطه بسجل عامل (BC-7).
  - حفظ `roster_epoch` في جدول `settings` بمفتاح `AppSettingKeys.rosterEpoch` (القيمة الابتدائية `'1'`).
- **حزم الاتصال والسحابة:**
  - التزامًا بقواعد المستودع (`AGENTS.md` — عدم إضافة تبعيات خارجية تكسر البناء المحلي الأوفلاين على محطة عمل Windows)، يُبنى محرك المزامنة (`SyncEngine` + `OutboxRepository`) عبر واجهة مجردة نقية `RemoteSyncGateway` مع تنفيذ محلي أوفلاين (`OfflineRemoteSyncGateway` / `InMemoryRemoteSyncGateway`) يضمن عمل جميع مسارات الرفع والتنزيل والتفعيل وإنهاء الجلسات واختباراتها محليًا بنسبة 100% دون الاعتماد على حزم شبكة خارجية غير مخزنة في الكاش المحلي.
