# ملف تسليم إلى Gemini — تجهيز Supabase لمشروع رادار ليبور

> انسخ هذا الملف إلى Gemini. المطلوب منه إرشاد المالك خطوة بخطوة داخل لوحة
> Supabase؛ المالك نفسه سينشئ الحساب والمشروع. لا تطلب منه كلمات مرور أو مفاتيح.

## نص المهمة إلى Gemini

أنت مساعد إعداد قاعدة بيانات Supabase لمشروع Flutter اسمه Radar Labor. اشرح
للمالك خطوة واحدة في كل مرة، وانتظر منه أن يقول «تم» أو يرسل لقطة الشاشة قبل
الانتقال للخطوة التالية. لا تفترض خبرته بـ Supabase. لا تطلب منه لصق كلمة مرور
قاعدة البيانات أو API secret أو ملف عمال حقيقي. إذا طلبت اختبارًا، استخدم بيانات
وهمية فقط.

ساعده على إنشاء مشروع تطوير Supabase باسمه، ثم اشرح له أين يجد SQL Editor وكيف
يحفظ migrations، ثم راجع إعدادات الجداول وRLS. لا تطلب منه وضع أي مفتاح في
Flutter حاليًا ولا تربط المشروع بالتطبيق الآن. إصدار V1 الذي يعمل عليه المطور
محلي وأوفلاين، وقاعدة البيانات الحالية SQLite مشفرة داخل الجهاز. Supabase
تحضير موازٍ للمزامنة المستقبلية فقط، وربط التطبيق لا يبدأ إلا بطلب مستقل بعد
اتفاق صريح على مزامنة البيانات وسياسة التخزين والنسخ الاحتياطي.

عند كل خطوة اشرح: ما الذي سيفعله، أين يضغط، كيف يعرف أنها نجحت، وما الذي لا
ينبغي نسخه أو مشاركته. إذا واجه اختلافًا في واجهة Supabase الحالية، اعتمد
التوثيق الرسمي الحالي ولا تخمّن أسماء الأزرار. لا تشغّل SQL قبل أن تعرضه عليه
وتشرح أثره، ولا تحذف أو تعِد إنشاء مشروع موجود.

## ملخص المنتج

- الاسم: Radar Labor / رادار ليبور، تطبيق Flutter لإدارة معرفة موقع العمال في
  يوم العمل؛ ليس نظام رواتب أو انصراف أو GPS.
- المنصة الحالية: Android، Flutter 3.47.7 / Dart 3.13.5.
- V1 الحالي: تخزين محلي SQLite مشفر، إنجليزي افتراضيًا مع عربي وRTL، يعمل دون
  اتصال. الأصول والخط Cairo مضمنة.
- الوظائف: القوى العاملة، الفرق، المساكن، تسجيل فحص السكن والغياب، تسجيل حضور
  الموقع، لوحة حالة العمال والتعارضات والتبريرات، رسائل WhatsApp محلية قابلة
  للنسخ. لا إرسال تلقائي.
- الأدوار: مدير المشروع، HR، مشرف السكن، مشرف الموقع، مشاهد فقط. للحسابات
  المحلية كلمة بدء مؤقتة 123456 يغيّرها المستخدم عند أول دخول. لا تنقل هذه
  السياسة تلقائيًا إلى Supabase؛ حسابات النسخة السحابية ينبغي أن تستخدم Supabase
  Auth وكلمات مرور منفصلة/دعوات آمنة.
- بيانات العمل حساسة. لا تخزن رقم الهوية/الإقامة، ولا تنسخ ملف Excel الحقيقي
  إلى المحادثة أو Git. ملف القوى يحوي S/O وID No. وName وDesignation وSupplier؛
  الاستيراد المحلي يتجاهل ID No. وS/O رمز عمل أولي. الملف لا يحدد الفريق أو
  السكن؛ يجب تعيين المشرفين ونطاقهم صراحة.

## النموذج الحالي محليًا (SQLite/Drift)

| الجدول | المفتاح / الحقول الأساسية | الغرض |
| --- | --- | --- |
| employees | `employeeUid` PK، `employeeCode` unique، `fullNameAr`، `fullNameEn`، `category`، `supplier`، `currentTeamId`، `housingId`، `isActive`، `rowVersion` | سجل العامل دون رقم الهوية |
| teams | `teamId` PK، `nameAr`، `nameEn`، `supervisorUserId`، `isActive` | فرق الموقع |
| housings | `housingId` PK، `nameAr`، `nameEn`، `isActive` | المساكن |
| employment_periods | `periodId` PK، `employeeUid`، `startDate`، `endDate`، `reason` | فترات توظيف العامل |
| events | `eventId` PK، `deviceId`، `deviceSeq`، `type`، `action`، `businessDate`، `employeeUid`، `teamId`، `housingId`، `userId`، `payload`، `deviceTime`، `receivedAt`، `serverSeq`، `late`، `eventSchemaVersion`، `syncStatus`، `rejectReason` | سجل تغييرات append-only؛ التصحيح حدث جديد `clear` ولا يحذف الحدث السابق |
| settings | `key` PK، `value` | إعدادات الجهاز والتطبيق؛ بيانات الحسابات المحلية في قاعدة الجهاز المشفرة |

أنواع الأحداث الحالية: `housing_check`, `housing_absent`, `site_present`,
`site_submitted`, `justification`, `resolution`. الفعل: `set` أو `clear`.
تسلسل الجهاز فريد لكل جهاز؛ الحدث متكرر الإرسال يجب أن يكون idempotent.

## مخطط سحابي مقترح للمراجعة، وليس تعليمات للربط الحالي

أنشئ مخططًا versioned مثل `public` أو `attendance` بعد مراجعة Gemini؛ لا تضع
كلمات مرور المستخدمين في الجداول. استخدم `auth.users` لهوية المصادقة.

1. `profiles`
   - `user_id uuid primary key references auth.users(id) on delete cascade`
   - `display_name text not null`, `role text not null`, `is_active boolean`
   - role check: `project_manager`, `hr`, `housing_supervisor`,
     `site_supervisor`, `viewer`.
2. `teams`
   - `team_id uuid primary key`, `name_ar`, `name_en`, `is_active`,
     `row_version`, `updated_at`.
3. `housings`
   - `housing_id uuid primary key`, `name_ar`, `name_en`, `is_active`,
     `row_version`, `updated_at`.
4. `employees`
   - `employee_uid uuid primary key`, `employee_code text unique not null`,
     `full_name_ar`, `full_name_en`, `category`, `supplier`,
     `current_team_id references teams`, `housing_id references housings`,
     `is_active`, `row_version`, `updated_at`.
   - **ممنوع إضافة ID No./iqama أو بيانات هوية شخصية.**
5. `employment_periods`
   - `period_id uuid primary key`, `employee_uid references employees`,
     `start_date date`, `end_date date null`, `reason text`.
   - قيد `end_date is null or end_date >= start_date`.
6. `profile_teams(user_id references profiles, team_id references teams)`،
   composite PK `(user_id, team_id)` لتحديد نطاق مشرف الموقع.
7. `profile_housings(user_id references profiles, housing_id references
   housings)`، composite PK `(user_id, housing_id)` لنطاق مشرف السكن.
8. `events`
   - `event_id uuid primary key`, `device_id uuid`, `device_seq bigint`,
     `type text`, `action text`, `business_date date`,
     nullable `employee_uid/team_id/housing_id` FKs, `user_id uuid references
     profiles`, `payload jsonb`, `device_time timestamptz`,
     `received_at timestamptz default now()`, `server_seq bigint generated
     ... as identity`, `late boolean`, `event_schema_version integer`.
   - unique `(device_id, device_seq)` مع idempotency على `event_id`.
   - `sync_status` و`reject_reason` محليان؛ لا تنسخهما إلى cloud events إلا
     بوجود سبب موثق، واستخدم جدول delivery منفصل إن احتجت حالة نقل سحابية.

## مبدأ الصلاحيات قبل أي بيانات حقيقية

- فعّل RLS على كل جدول مكشوف عبر Data API، وامنح أقل الصلاحيات اللازمة.
- HR ومدير المشروع يديران بيانات الدليل والأحداث حسب متطلبات العمل.
- مشرف الموقع يقرأ/يكتب أحداث الفرق المرتبطة به في `profile_teams` فقط.
- مشرف السكن يقرأ/يكتب أحداث المساكن المرتبطة به في `profile_housings` فقط.
- المشاهد SELECT فقط؛ لا يسمح له بأي كتابة.
- الأحداث append-only. الإدخال والتصحيح عبر RPC موثوقة واحدة مثل
  `ingest_events` تتحقق من `auth.uid()`, الدور، النطاق، `event_id` وتسلسل
  الجهاز؛ امنع UPDATE/DELETE المباشر.
- اختبر السياسات بحسابات وهمية للأدوار الخمسة قبل أي roster حقيقي.
- في التطبيق المنشور يستخدم العميل publishable key فقط مع Auth وRLS. مفتاح
  secret/service-role يتجاوز RLS ويظل على خادم موثوق ولا يوضع في تطبيق Flutter،
  ولا ترسله إلى Gemini أو ChatGPT.

## خطة عمل Gemini مع المالك

1. إرشاد المالك لإنشاء حساب Supabase والتحقق من بريده بنفسه؛ لا تطلب بيانات
   الدخول.
2. إنشاء organization/project تطوير فقط، اختيار region مناسب دون بيانات عمال،
   وتخزين كلمة مرور قاعدة البيانات عند المالك. لا يرسلها في المحادثة.
3. توضيح لوحة المشروع وSQL Editor ومكان migrations، دون تشغيل DDL بعد.
4. مراجعة قائمة الجداول والمفاتيح والعلاقات أعلاه مع المالك، ثم إعداد migration
   أولى بعد عرضه وشرحه. لا تضف سياسات تسمح للعامة بقراءة البيانات.
5. إنشاء حسابات اختبار وبيانات وهمية، ثم فحص RLS لكل دور. لا تستورد ملف العمال.
6. توقف عند مشروع تطوير آمن ومخطط معتمد. لا تربطه بتطبيق V1 المحلي حتى يطلب
   المالك تنفيذ مزامنة مستقلة ويوافق على مخاطر الإنترنت وتدفق البيانات.

## المراجع الرسمية

- [نظرة عامة على قاعدة Supabase](https://supabase.com/docs/guides/database/overview)
- [مفاتيح API واختيار publishable/secret](https://supabase.com/docs/guides/getting-started/api-keys)
