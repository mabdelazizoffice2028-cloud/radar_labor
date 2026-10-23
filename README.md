<div align="center">

# رادار ليبور · Radar Labor

**أساس تطبيق أندرويد عربي لمتابعة حالة العمال اليومية، يعمل دون اتصال أولًا ويحفظ بياناته محليًا بتشفير.**

[العربية](#العربية) · [English](#english) · [متطلبات المشروع](docs/PRD.md) · [التصميم](docs/DESIGN.md) · [سجل القرارات](docs/DECISIONS.md) · [تعليمات التطوير](CLAUDE.md) · [تقرير التنفيذ](docs/PROJECT_REPORT.md)

![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)
![Stage](https://img.shields.io/badge/stage-S0%20Foundation-1D4ED8)

</div>

---

## العربية

### ما هو المشروع؟

«رادار ليبور» تطبيق أندرويد موجّه للإدارة والمشرفين لتوضيح حالة العامل خلال يوم العمل: في الموقع، في السكن فقط، غائب يحتاج إلى متابعة، لديه تبرير، أو لم تُسجّل حالته بعد. صُمّم للاستخدام الميداني بالعربية، مع مزامنة تتحمل انقطاع الإنترنت.

**هذا المستودع في مرحلة الأساس التقني S0.** يحتوي على تهيئة Flutter وقاعدة بيانات محلية مشفّرة واختباراتها. شاشات العمل والعمال والمزامنة ولوحة الإدارة لم تُنفّذ بعد؛ لذلك لا يمثّل التطبيق الحالي إصدارًا تشغيليًا.

> هذا النظام لتسجيل الحالة اليومية، وليس جهاز حضور وانصراف أو نظام رواتب أو تتبّع GPS.

### حالة التنفيذ

| الجزء | الحالة | التفاصيل |
| --- | --- | --- |
| S0 — الأساس | مكتمل | بنية Flutter، Drift وSQLite المشفّرة، تفعيل cipher، مخطط قاعدة الإصدار 1، واختبارات فتح القاعدة والترحيل |
| S1 — الأحداث ومحرك الحالة | لم يبدأ | مستودع الأحداث، تاريخ العمل بتوقيت الرياض، ومحرك الحالات واختباراته |
| S2 — المزامنة | لم يبدأ | طابور الإرسال، التعامل مع التكرار والرفض والانقطاع، وSupabase |
| S3–S7 — التطبيق والتجربة | لم تبدأ | الدخول والبيانات المرجعية والشاشات والإدارة والتجربة الميدانية |

### التقنية

- Flutter وDart مع دعم RTL وواجهات عربية.
- Drift فوق SQLite3MultipleCiphers كقاعدة محلية مشفّرة.
- Riverpod لإدارة الحالة، مع فصل طبقات العرض والمنطق والبيانات.
- Supabase للمزامنة المستقبلية؛ غير موصول في مرحلة S0.
- تخزين آمن للمفتاح والمصادقة الحيوية ضمن نطاق الخطة؛ لم يُربط تدفق الدخول بعد.

### بدء العمل

يتطلب المشروع Flutter 3.47.x وDart 3.13.x وAndroid SDK وJDK 17. في بيئة التطوير المتصلة، احصل على الحزم أولًا، ثم شغّل فحوصات التنسيق والتحليل والاختبارات قبل بناء Android.

في بيئة صاحب المشروع المعزولة عن الإنترنت، تعتمد SQLite الأصلية على ملفات موجودة في كاش Pub وملفات المشروع المولّدة. لا تحذف كاشات البيئة ولا مجلد `.dart_tool` عند العمل دون اتصال؛ راجع [تقرير التنفيذ](docs/PROJECT_REPORT.md) وملف قرارات المشروع قبل تعديل إعداداتها.

### التحقق من الأساس

تم التحقق محليًا في بيئة المشروع من التنسيق، والتحليل الثابت، والاختبارات، وبناء APK للتطوير والإصدار. اجتازت الاختبارات الخمسة عشر في مرحلة S0. بناء الإصدار المحلي موقّع بمفتاح تصحيح لأغراض التحقق، **ولا يصلح للنشر في المتجر**.

تشمل اختبارات قاعدة البيانات تفعيل cipher، ومخطط الإصدار 1، وإنشاء جدول الإعدادات، ورفض المفتاح غير الصحيح، وحفظ قاعدة مشفّرة وإعادة فتحها.

### بنية المستودع

```text
lib/
  app/                    تهيئة التطبيق
  core/
    constants/            ثوابت المشروع
    database/             Drift، التشفير، الفتح والترحيلات
    errors/               أنواع الإخفاقات
    time/                 ساعة قابلة للحقن
docs/
  PRD.md                  متطلبات المنتج ومعايير القبول
  DESIGN.md               مواصفات التصميم والواجهة
  DECISIONS.md            القرارات المقفلة وقرارات التنفيذ
  PROJECT_REPORT.md       تقرير الإنجاز والأخطاء والحلول
test/                     اختبارات معمارية وقاعدة البيانات والوقت
```

### الأمان والبيانات

- قاعدة البيانات المحلية مشفّرة، ويُرفض فتحها إن لم تتوفر واجهة cipher أو كان المفتاح خاطئًا.
- تعطيل النسخ الاحتياطي لتطبيق Android.
- لا تضع مفاتيح Supabase أو كلمات مرور أو مفاتيح توقيع في المستودع. إعدادات الاتصال المستقبلية تُمرّر وقت البناء؛ مفتاح `service_role` لا يدخل التطبيق مطلقًا.
- لا تُخزّن أرقام هوية أو إقامة العامل على أجهزة المشرفين وفق متطلبات المنتج.
- لم يُحسم بعد معرّف التطبيق النهائي أو إعداد التوقيع الإنتاجي.

### وثائق المشروع

- [وثيقة متطلبات المنتج](docs/PRD.md)
- [مواصفات التصميم](docs/DESIGN.md)
- [قرارات المشروع](docs/DECISIONS.md)
- [تعليمات التطوير](CLAUDE.md)
- [تقرير التنفيذ والمشكلات](docs/PROJECT_REPORT.md)

---

## English

### Overview

Radar Labor is an Arabic-first, offline-first Android app planned to help supervisors and management record each worker's daily status: on site, at housing only, unknown, justified, or not recorded. It is a daily status tool, not a time clock, payroll system, or GPS tracker.

**The repository currently contains S0, the engineering foundation only.** It includes the Flutter setup, encrypted local database, schema version 1, and foundation tests. Worker workflows, screens, sync, and the management dashboard have not been implemented. This is not an operational release.

### Project status

| Milestone | Status | Scope |
| --- | --- | --- |
| S0 — Foundation | Complete | Flutter base, Drift with encrypted SQLite, cipher verification, schema v1 and tests |
| S1 — Events and status engine | Not started | Event repository, Riyadh business date and pure status engine |
| S2 — Synchronization | Not started | Outbox, retry and conflict handling, Supabase integration |
| S3–S7 — Product workflows | Not started | Sign-in, reference data, field screens, dashboard and pilot |

### Technology

- Flutter 3.47.x and Dart 3.13.x.
- Drift with SQLite3MultipleCiphers for encrypted local storage.
- Riverpod for state management and a layered architecture.
- Supabase is planned for synchronization; it is not connected in S0.

### Development

Use Flutter 3.47.x, Dart 3.13.x, Android SDK and JDK 17. Resolve dependencies in a connected environment, then run formatting, static analysis and tests before building Android.

The owner's offline workstation relies on cached Pub packages and generated SQLite native assets. Avoid deleting those caches or `.dart_tool` when working offline. See [the implementation report](docs/PROJECT_REPORT.md) and [decision log](docs/DECISIONS.md) before changing the setup.

### Verification and release status

Formatting, static analysis, all 15 foundation tests, and debug and release APK builds passed locally. The release build uses a debug signing key for verification and is **not suitable for store distribution**. The final Android application ID and production signing configuration remain undecided.

### Security notes

- Database startup fails closed if encryption is unavailable or the key is rejected.
- Android backup is disabled.
- Never commit Supabase credentials, passwords, or signing keys. The Supabase `service_role` key must never be shipped in the app.
- Worker identity numbers are excluded from supervisor devices by the product requirements.

### Project documents

- [Product requirements](docs/PRD.md)
- [Design specification](docs/DESIGN.md)
- [Decision log](docs/DECISIONS.md)
- [Development instructions](CLAUDE.md)
- [Implementation report](docs/PROJECT_REPORT.md)

---

## Repository information

- **Suggested description:** Arabic-first, offline-first Flutter Android app for recording daily worker status, backed by encrypted local storage.
- **Suggested topics:** `flutter`, `dart`, `android`, `offline-first`, `sqlite`, `drift`, `supabase`, `arabic`, `rtl`.
- **Visibility recommendation:** private until the owner confirms that product requirements and operational details may be public.
- No license has been selected; all rights remain with the project owner unless a license is added.
