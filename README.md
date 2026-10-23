<div align="center">

# رادار ليبور · Radar Labor

**تطبيق ميداني عربي/إنجليزي لتسجيل حالة العمال اليومية. يعمل دون اتصال، ويخزن بياناته محليًا في قاعدة مشفّرة.**

![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Mode](https://img.shields.io/badge/Runtime-Local%20%26%20Offline-15803D)

[العربية](#العربية) · [English](#english) · [الوثائق](docs/README.md)

</div>

---

## العربية

### عن التطبيق

«رادار ليبور» أداة للمشرفين والإدارة لمتابعة حالة العمال اليومية من الهاتف. الواجهة عربية افتراضيًا مع خيار الإنجليزية، وتدعم RTL. التطبيق لا يحتاج إلى الإنترنت أثناء التشغيل: قاعدة البيانات مشفّرة ومحلية، وخط Cairo وأيقونات Material مضمّنان مع التطبيق. لا توجد خدمة سحابية أو تحميل أصول عند التشغيل.

هذا النظام لتسجيل الحالة اليومية؛ ليس جهاز حضور وانصراف، ولا نظام رواتب، ولا أداة تتبّع GPS.

### ما يعمل حاليًا

- شاشة تشغيل واضحة بحالات التحميل والخطأ وإعادة المحاولة؛ لا يبدأ التطبيق بواجهة بيضاء صامتة.
- لوحة حالات تحسب العامل بالموقع، وفي السكن فقط، وغير المعلوم، والمبرر، وغير المسجل من سجل اليوم؛ وتعرض مجهولي الحالة وتجاوز SLA والتعارضات.
- إنشاء الفرق ومساكن العمال بأسماء عربية وإنجليزية.
- تسجيل العامل برقم فريد واسمين عربي/إنجليزي وإسناده إلى فريق وسكن.
- فحص السكن: تحديد الغائبين أو تأكيد «لا يوجد غائبون»، مراجعة الأسماء، الحفظ المحلي، تراجع يسجل أحداثًا عكسية، وإنشاء ملخص واتساب قابل للنسخ.
- تسجيل الموقع حسب الفريق، تأكيد الحاضرين وإرسال سجل الفريق حتى عند صفر حضور؛ التصحيح والتراجع يحتفظان بسجل الأحداث.
- سجل أحداث محلي متزايد التسلسل والكتابة الجماعية الذرية، وتاريخ يوم العمل وفق توقيت الرياض والحد اليومي المحدد.
- حفظ اللغة والتفضيلات محليًا، وتخزين مفتاح التشفير في التخزين الآمن للنظام.

### قيود النسخة الحالية

هذه نسخة تطبيق محلي قيد الإكمال وليست إصدارًا نهائيًا لكل النطاق التشغيلي في PRD. استيراد ملفات Excel/CSV غير متاح حاليًا؛ إضافة العمال يدوية. لا تشمل بعد شاشة تسجيل الدخول، تعديل السجلات المرجعية، إدارة فترات العمل، التبريرات والحسم، اختيار تاريخ لوحة الحالات، عروض كل شرائط التنبيه، أو تصدير التقارير. المزامنة السحابية مؤجلة بقرار المالك. راجع [خارطة الطريق](docs/ROADMAP.md) و[سجل العيوب](docs/BUGS.md) للحالة الدقيقة.

### البناء والتشغيل

المتطلبات: Flutter 3.47.x، Dart 3.13.x، Android SDK وJDK 17.

```powershell
flutter pub get --offline
flutter analyze
flutter test
flutter build apk --release
```

ينتج APK الإصدار في `build/app/outputs/flutter-apk/app-release.apk`. يوقّع قالب Flutter المحلي نسخة التحقق بمفتاح debug؛ لا تنشرها على المتجر قبل إعداد معرّف تطبيق نهائي ومفتاح توقيع إنتاجي. في جهاز التطوير غير المتصل، يجب أن تكون الحزم وأدوات Android المطلوبة موجودة مسبقًا في الكاش. لا تحذف `.dart_tool` أو كاش Flutter/Pub/Gradle ولا تشغّل `flutter clean` في بيئة المالك دون حاجة مثبتة.

### المستودع والوثائق

- [مركز الوثائق](docs/README.md): نقطة البدء لكل موديل أو مساهم.
- [متطلبات المنتج](docs/PRD.md) · [التصميم](docs/DESIGN.md) · [القرارات](docs/DECISIONS.md)
- [خارطة الطريق](docs/ROADMAP.md) · [سجل العمل وتسليم النماذج](docs/WORKLOG.md) · [سجل الأخطاء](docs/BUGS.md)
- [تقرير التنفيذ](docs/PROJECT_REPORT.md) · [تعليمات المساهمة للموديلات](CLAUDE.md)

### الخصوصية والترخيص

قاعدة البيانات المحلية مشفرة بمفتاح عشوائي محفوظ في التخزين الآمن. النسخ الاحتياطي لتطبيق Android معطّل. لا تضف مفاتيح أو بيانات حقيقية أو أسرار توقيع للمستودع. الخط Cairo مرخّص بـ SIL Open Font License؛ نص الترخيص والإسناد موجودان بجانب ملف الخط في `assets/fonts/`.

---

## English

### About

Radar Labor is an Arabic/English field app for recording workers' daily status. Arabic is the default and the layout supports RTL. Runtime operation is local and offline: records live in an encrypted on-device database, while the Cairo font and Material icons ship with the app. No cloud service or remote asset is loaded at runtime.

This is a daily status tool, not a time clock, payroll system, or GPS tracker.

### Available now

- Visible loading, startup failure, and retry states instead of an empty white screen.
- A live status dashboard that evaluates on-site, housing-only, unknown, justified, and unrecorded workers, and highlights unknown workers, SLA breaches, and conflicts.
- Create teams and housing locations with Arabic and English names.
- Add workers with a unique code, bilingual names, team, and housing assignment.
- Run housing checks, confirm no-absence days, review names, save locally, undo through inverse events, and copy a local WhatsApp summary.
- Record a team's site attendance, confirm selected workers, submit even when zero workers are present, and correct through the append-only event ledger.
- Atomically append ordered event batches and calculate the Riyadh business date.
- Persisted language preference and a database key stored with the platform secure storage.

### Current scope

This is a local app under active completion, not a final release for the entire PRD. Excel/CSV import is not currently available; workers are entered manually. Sign-in, editing reference data, employment-period management, justifications/resolutions, date selection, all warning banners, and report export remain outstanding. Cloud synchronization is deferred by the owner. See the [roadmap](docs/ROADMAP.md) and [defect register](docs/BUGS.md).

### Build

Requirements: Flutter 3.47.x, Dart 3.13.x, Android SDK, and JDK 17.

```powershell
flutter pub get --offline
flutter analyze
flutter test
flutter build apk --release
```

The release APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The local Flutter template signs verification builds with its debug key; configure a final application ID and production signing key before store distribution. Offline work requires dependencies and Android tools to be cached in advance. Preserve `.dart_tool` and Flutter/Pub/Gradle caches; do not run `flutter clean` without a demonstrated need.

### Project documents

Start with the [documentation index](docs/README.md), then consult the [PRD](docs/PRD.md), [design specification](docs/DESIGN.md), [decision log](docs/DECISIONS.md), [roadmap](docs/ROADMAP.md), [model handoff log](docs/WORKLOG.md), [defect register](docs/BUGS.md), and [implementation report](docs/PROJECT_REPORT.md).

### Privacy and font license

The local database is encrypted with a random key held in platform secure storage. Android backup is disabled. Never commit real worker records, credentials, or signing secrets. Cairo is distributed under the SIL Open Font License; the full license and attribution are in `assets/fonts/`.

---

## Repository metadata

- Suggested description: **Arabic/English offline Flutter app for daily worker status, with encrypted local storage.**
- Suggested topics: `flutter`, `dart`, `android`, `offline-first`, `sqlite`, `drift`, `arabic`, `rtl`.
- No project license has been selected. All rights remain with the project owner unless a license is added.
