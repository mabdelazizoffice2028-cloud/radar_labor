<div align="center">

# رادار ليبور · Radar Labour

**تطبيق ميداني عربي/إنجليزي لتسجيل حالة العمال اليومية. يعمل دون اتصال، ويخزن بياناته محليًا في قاعدة مشفّرة.**

![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Mode](https://img.shields.io/badge/Runtime-Local%20%26%20Offline-15803D)

[العربية](#العربية) · [English](#english) · [الوثائق](docs/README.md)

**الحالة:** V1 جاهز للتجربة على Android · **النسخة:** 1.0.0 · **البيانات:** محلية ومشفّرة

</div>

---

## العربية

### عن التطبيق

«رادار ليبور» أداة للمشرفين والإدارة لمتابعة حالة العمال اليومية من الهاتف. الواجهة الإنجليزية افتراضيًا مع خيار العربية وRTL. التطبيق لا يحتاج إلى الإنترنت أثناء التشغيل: قاعدة البيانات مشفّرة ومحلية، وخط Cairo وأيقونات Material مضمّنان مع التطبيق. لا توجد خدمة سحابية أو أصول تُحمّل عند التشغيل.

هذا النظام لتسجيل الحالة اليومية؛ ليس جهاز حضور وانصراف، ولا نظام رواتب، ولا أداة تتبّع GPS.

### ما يعمل حاليًا

- شاشة تشغيل واضحة بحالات التحميل والخطأ وإعادة المحاولة؛ لا يبدأ التطبيق بواجهة بيضاء صامتة.
- لوحة حالات تحسب العامل بالموقع، وفي السكن فقط، وغير المعلوم، والمبرر، وغير المسجل من سجل اليوم؛ وتعرض مجهولي الحالة وتجاوز SLA والتعارضات.
- اختيار يوم عمل لمراجعة اللوحة، وتنبيهات بالمساكن والفرق التي لم تسجل لذلك اليوم.
- تسوية تعارضات العامل بخيارات موثقة، وتسجيل تبرير محلي للحالة غير المعلومة.
- إنشاء الفرق ومساكن العمال بأسماء عربية وإنجليزية.
- تسجيل العامل برقم فريد واسمين عربي/إنجليزي وإسناده إلى فريق وسكن.
- فحص السكن: تحديد الغائبين أو تأكيد «لا يوجد غائبون»، مراجعة الأسماء، الحفظ المحلي، تراجع يسجل أحداثًا عكسية، وإنشاء ملخص واتساب قابل للنسخ.
- تسجيل الموقع حسب الفريق، تأكيد الحاضرين وإرسال سجل الفريق حتى عند صفر حضور؛ بعدها يظهر ملخص واتساب للحاضرين أو رسالة صفر حضور لنسخها. التصحيح والتراجع يحتفظان بسجل الأحداث.
- سجل أحداث محلي متزايد التسلسل والكتابة الجماعية الذرية، وتاريخ يوم العمل وفق توقيت الرياض والحد اليومي المحدد.
- حفظ اللغة والتفضيلات محليًا، وتخزين مفتاح التشفير في التخزين الآمن للنظام.
- تسجيل دخول محلي إلزامي حسب الدور: مدير المشروع وHR ومشرف السكن ومشرف الموقع ومشاهد فقط. كلمة البداية 123456 مؤقتة ويجب تغييرها عند أول دخول؛ كلمات المرور محفوظة كهاش Argon2id داخل قاعدة البيانات المشفرة.
- إعداد أول تشغيل باستيراد XLSX/CSV محليًا مع تجاهل رقم الهوية، كشف الأكواد المكررة قبل الحفظ، وحفظ الاسم/الكود/المسمى/المورد. يختار المالك اسمي مدير المشروع وHR من السجل المستورد.
- إدارة الحسابات من الإعدادات وإسناد مشرفي السكن والموقع إلى نطاقاتهم؛ المشرف لا يرى إلا المساكن أو الفرق المسندة إليه، والمشاهد لا يستطيع الحفظ.
- اسم حزمة Android الظاهر: **Radar Labour**. ملفات الاختبار والبناء مخصصة للتثبيت التجريبي وليست موقعة لمتجر Google Play.

### قيود النسخة الحالية

هذه نسخة V1 محلية للتجربة. بيانات الموظفين والمستخدمين لا تغادر الجهاز. استيراد الملف يتجاهل رقم الهوية تمامًا؛ أسماء القوى تبقى داخل قاعدة SQLite المشفّرة. ملف القوى لا يحتوي تعيين الفريق/السكن، لذلك يجب على مدير المشروع إسناد كل مشرف يدويًا من شاشة إدارة المستخدمين. لا يتصل التطبيق بخدمة سحابية. إدارة فترات التوظيف المتقدمة، تصدير التقارير، والنسخ الاحتياطي/الاسترجاع خارج نطاق التسليم الحالي. راجع [خارطة الطريق](docs/ROADMAP.md) و[سجل العيوب](docs/BUGS.md) قبل التوسعة.

### الاستيراد الأولي

يدعم التطبيق ملفات `.xlsx` و`.csv` بحد أقصى 25 MB. يحتاج الاستيراد `S/O` و`Name`، ويقرأ اختياريًا `Designation` و`Supplier`، ويتجاهل `ID No.`. عند استخدام CSV من LibreOffice اختر `Unicode (UTF-8)`، وفاصل الحقول comma `,`، ومحدد النص double quote `"`. يصدر CSV الورقة النشطة فقط؛ اختر ورقة القوى الكاملة قبل الحفظ. التفاصيل في [دليل التسليم](docs/DEVICE_AND_MODEL_HANDOFF.md).

### البناء والتشغيل

المتطلبات: Flutter 3.47.x، Dart 3.13.x، Android SDK وJDK 17.

```powershell
flutter pub get --offline
flutter analyze
flutter test
flutter build apk --release
```

يُنشأ ملف البناء في `build/app/outputs/flutter-apk/app-release.apk` ثم ينسخ باسم `outputs/Radar Labour.apk` لتسهيل نقله للهاتف. APK التجربة الحالي في `outputs/Radar Labour.apk`، وموقع بمفتاح debug؛ لا تنشره على المتجر قبل إعداد معرّف تطبيق نهائي ومفتاح توقيع إنتاجي. على جهاز المالك، شغّل أولًا `work/flutter-profile/android-env.cmd` في PowerShell ثم استخدم أوامر Flutter مع `--no-pub` للاستفادة من الإعداد والكاش المحليين. في أي جهاز تطوير غير متصل، يجب أن تكون الحزم وأدوات Android المطلوبة موجودة مسبقًا في الكاش. لا تحذف `.dart_tool` أو كاش Flutter/Pub/Gradle ولا تشغّل `flutter clean` في بيئة المالك دون حاجة مثبتة.

### المستودع والوثائق

- [تعليمات النماذج والمساهمين](AGENTS.md): ملف التعليمات العام الذي يبدأ منه كل موديل.
- [مركز الوثائق](docs/README.md): فهرس الحالة والتسليم والسجلات.
- [تقرير البيئة والتسليم](docs/DEVICE_AND_MODEL_HANDOFF.md): ما تم، وأخطاء الجهاز، والتحقق، وما يجب أن يكمله الموديل التالي.
- [متطلبات المنتج](docs/PRD.md) · [التصميم](docs/DESIGN.md) · [القرارات](docs/DECISIONS.md)
- [خارطة الطريق](docs/ROADMAP.md) · [سجل العمل وتسليم النماذج](docs/WORKLOG.md) · [سجل الأخطاء](docs/BUGS.md)
- [تقرير التنفيذ](docs/PROJECT_REPORT.md) · [تعليمات Claude الإضافية](CLAUDE.md)

### الخصوصية والترخيص

قاعدة البيانات المحلية مشفرة بمفتاح عشوائي محفوظ في التخزين الآمن. النسخ الاحتياطي لتطبيق Android معطّل. لا تضف مفاتيح أو بيانات حقيقية أو أسرار توقيع للمستودع. الخط Cairo مرخّص بـ SIL Open Font License؛ نص الترخيص والإسناد موجودان بجانب ملف الخط في `assets/fonts/`.

---

## English

### About

Radar Labour is an Arabic/English field app for recording workers' daily status. English is the default; Arabic is selectable with RTL. Runtime operation is local and offline: records live in an encrypted on-device database, while the Cairo font and Material icons ship with the app. No cloud service or remote asset is loaded at runtime.

This is a daily status tool, not a time clock, payroll system, or GPS tracker.

### Available now

- Visible loading, startup failure, and retry states instead of an empty white screen.
- A live status dashboard that evaluates on-site, housing-only, unknown, justified, and unrecorded workers, and highlights unknown workers, SLA breaches, and conflicts.
- Select a business date, and see which housing locations or teams have not submitted for that date.
- Resolve worker conflicts using a typed reason and record local justifications for unknown status.
- Create teams and housing locations with Arabic and English names.
- Add workers with a unique code, bilingual names, team, and housing assignment.
- Run housing checks, confirm no-absence days, review names, save locally, undo through inverse events, and copy a local WhatsApp summary.
- Record a team's site attendance, confirm selected workers, submit even when zero workers are present, and copy a WhatsApp summary of the present roster (or the zero-present message). Corrections use the append-only event ledger.
- Atomically append ordered event batches and calculate the Riyadh business date.
- Persisted language preference and a database key stored with the platform secure storage.
- Required local sign-in for project manager, HR, housing supervisor, site supervisor, and read-only viewer. The initial `123456` password is temporary and must be changed on first sign-in; passwords are Argon2id hashes in the encrypted database.
- First-run XLSX/CSV roster import with a preview, duplicate-code rejection, and no ID-number persistence. Imported name, code, designation, and supplier are stored locally; the manager and HR accounts are selected from the imported roster.
- In-app account management and supervisor scope assignment. Supervisors are limited to assigned housing/teams; viewer actions are read-only.
- Android launcher label: **Radar Labour**. This sideload build is for testing and is not Play Store signed.

### Current scope

This is the local V1 test build. Worker and account records remain on-device. The import flow discards identity numbers; roster names stay in the encrypted SQLite database. The provided roster does not assign supervisors to teams or housing, so a project manager must assign each scope from account settings. The app does not contact a cloud service. Advanced employment-period management, report export, and backup/restore remain outside this delivery. See the [roadmap](docs/ROADMAP.md) and [defect register](docs/BUGS.md).

### First roster import

The app accepts `.xlsx` and `.csv` files up to 25 MB. `S/O` and `Name` are required; `Designation` and `Supplier` are optional; `ID No.` is ignored. For LibreOffice CSV export, choose `Unicode (UTF-8)`, comma `,` as the field delimiter, and double quote `"` as the string delimiter. CSV exports only the active sheet, so select the complete workforce sheet first. See the [device and model handoff](docs/DEVICE_AND_MODEL_HANDOFF.md) for details.

### Build

Requirements: Flutter 3.47.x, Dart 3.13.x, Android SDK, and JDK 17.

```powershell
flutter pub get --offline
flutter analyze
flutter test
flutter build apk --release
```

The build output is `build/app/outputs/flutter-apk/app-release.apk`; the handoff copy is `outputs/Radar Labour.apk`. The current test APK is in `outputs/Radar Labour.apk` and uses a debug key. Configure a final application ID and production signing key before store distribution. On the owner's workstation, run `work/flutter-profile/android-env.cmd` first and use Flutter commands with `--no-pub` to use its local setup and caches. Offline work requires dependencies and Android tools to be cached in advance. Preserve `.dart_tool` and Flutter/Pub/Gradle caches; do not run `flutter clean` without a demonstrated need.

### Project documents

For coding agents, start with [`AGENTS.md`](AGENTS.md), then the [documentation index](docs/README.md) and [detailed device/model handoff](docs/DEVICE_AND_MODEL_HANDOFF.md). Consult the [PRD](docs/PRD.md), [design specification](docs/DESIGN.md), [decision log](docs/DECISIONS.md), [roadmap](docs/ROADMAP.md), [work log](docs/WORKLOG.md), [defect register](docs/BUGS.md), and [implementation report](docs/PROJECT_REPORT.md) as relevant.

### Privacy and font license

The local database is encrypted with a random key held in platform secure storage. Android backup is disabled. Never commit real worker records, credentials, or signing secrets. Cairo is distributed under the SIL Open Font License; the full license and attribution are in `assets/fonts/`.

---

## Repository metadata

- Suggested description: **Radar Labour — Arabic/English offline Flutter app for daily worker status with encrypted local storage.**
- Suggested topics: `flutter`, `dart`, `android`, `offline-first`, `sqlite`, `drift`, `arabic`, `rtl`.
- No project license has been selected. All rights remain with the project owner unless a license is added.
