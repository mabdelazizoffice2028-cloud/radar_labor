# تسليم العمل للموديل التالي (Radar Labour Deep Audit & Surgical Fixes)

**آخر تحديث:** 30 أكتوبر 2026 (إصلاح الثغرات الـ 10 الحرجة الناتجة عن الفحص المعمق Deep Audit). المرجع الأساسي والشامل للمشروع هو `AGENTS.md` في جذر المشروع، ثم `docs/README.md` و `DEVICE_AND_MODEL_HANDOFF.md` و `DECISIONS.md`.

## الحالة الحالية (بعد إنجاز الإصلاحات الجراحية الـ 10)

- **المرجع الموحد للمشروع:** الالتزام الصارم بـ `AGENTS.md` وكافة الضوابط المعمارية (Micro-modularization <= 80 سطراً، Dumb UI، Pure Dart، وفصل الطبقات).
- **إصلاحات التقارير والبيانات (Phase 1):**
  - تمرير `employmentType` و `jobCategory` إلى `WorkerOption` و `WhatsappWorkerItem` في كافة محولات العمليات والسجل التاريخي.
  - إيقاف تصفير عمال الإيجار ومشغلي المعدات في تقارير الواتساب.
  - استبعاد العمال المجازين (On Leave) عند تحضير ملخص فحص السكن.
- **إصلاح مسار "لا يوجد غياب اليوم" في السكن (Phase 2):**
  - اعتماد حوار تأكيد، نسخ ملخص الواتساب للحافظة، إطلاق المزامنة الخلفية، إظهار زر التراجع (Undo)، وإغلاق الشاشة بأمان.
- **إصلاح شارة مهام المشرف (Phase 3):**
  - تصحيح شرط مسودة السكن في `SupervisorTaskBadgeResolver` ليعتمد حصراً على `hasDraftSaved || hasUnsavedChanges` وإلغاء الشرط الخاطئ.
- **إصلاحات المزامنة وصندوق الصادر (Phase 4):**
  - `SupabaseSyncGateway.uploadBatch`: اعتماد المعرفات المقبولة فعلياً في `accepted` فقط وعدم ضياع الأحداث المرفوضة بصمت.
  - `SupabaseSyncGateway.fetchSnapshot`: رمي `OperationException(DatabaseBusy())` عند فشل الشبكة لمنع تصفير العداد محلياً.
  - `SyncBatchUploader`: رفع كافة الدفعات حتى تفريغ صندوق الصادر بالكامل عبر حلقة `while (true)` دون التوقف عند دفعة 500 الأولى.
  - `OutboxRepository`: تحويل قراءة العداد المعلق إلى استعلامات `COUNT` سريعة ومراقبة تدفقي الأحداث وسجلات التدقيق معاً.
- **تحسين أداء لوحة التحكم (Phase 5):**
  - `StatusSnapshotRepository.watch`: الاشتراك في أحداث يوم العمل المعروض فقط `watchBusinessDate(targetDate)` بدلاً من `watchAll()` لكامل تاريخ المشروع.
- **إغلاق تسريب الذاكرة والتدقيق الإداري (Phase 6):**
  - `worker_add_dialog.dart`: التحقق من أن رقم الإقامة 10 أرقام (`RegExp(r'^\d{10}$')`)، عمل `dispose()` للـ Controllers، وتسجيل الحركة في `workerHistory` و `audit_log`.
  - التخلص التلقائي من `TextEditingController` في نوافذ الحل والتبرير وشاشة الإجازات.
  - تسجيل كافة العمليات الإدارية للحسابات واستيراد القوى في `audit_log`.
- **الفحص الساكن للكود:** `flutter analyze --no-pub` -> **No issues found!** (صفر أخطاء وصفر تحذيرات).
- **حزمة الاختبارات الشاملة:** `flutter test --no-pub` -> **All 234 tests passed!** (بنسبة نجاح 100%).

## إرشادات البيئة الصارمة للوكيل القادم

1. لا تقم بتشغيل `flutter clean` أو حذف مجلد `.dart_tool` أو مسح كاش Gradle/Pub.
2. شغّل دائماً كافة الأوامر مع خيار `--no-pub`.
3. المعيار المفضل هو حوالي 80 سطراً لكل ملف `.dart` في `lib/`، والحد الأقصى المطلق هو 100 سطر دون تجاوز تحت أي ظرف.
4. استخدم حصرياً `import 'package:material_ui/material_ui.dart';`.
