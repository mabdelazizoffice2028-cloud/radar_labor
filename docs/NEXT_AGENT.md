# تسليم العمل للموديل التالي

**آخر تحديث:** 23 أكتوبر 2026. ابدأ من `AGENTS.md` في جذر المشروع، ثم اقرأ
`README.md` و`docs/README.md` و`DEVICE_AND_MODEL_HANDOFF.md` و`DECISIONS.md` وهذا
الملف. بعد ذلك راجع `WORKLOG.md` و`BUGS.md` و`ROADMAP.md` وأقسام PRD/DESIGN ذات الصلة.

## توجيه المالك

- التوجيه الأحدث يطلب إكمال كل نطاق V1 الآن، ويلغي شرط التوقف بعد S6 وانتظار
  تجربة الهاتف.
- التطبيق محلي دون إنترنت وقت التشغيل، بقاعدة مشفرة وأصول وخطوط محلية. لا تهيئ
  Supabase ولا تنفذ مزامنة.
- الإنجليزية افتراضية، والعربية اختيارية مع RTL. اجعل الواجهات بسيطة.
- ملخصات WhatsApp محلية قابلة للنسخ فقط؛ لا ترسل تلقائيًا.
- كلمة المرور الابتدائية 123456 مؤقتة ويجب تغييرها في أول دخول؛ تبقى إمكانية
  تغييرها من الإعدادات. الأدوار: مدير المشروع، HR، مشرف سكن، مشرف موقع، ومشاهد.
- حدّث docs مع كل مرحلة وأخطاء، ولا تضع أسماء أو أرقام هوية في Git أو السجلات.

## الحالة الحالية

- GitHub remote مربوط بـ `https://github.com/mabdelazizoffice2028-cloud/radar_labor.git`.
  الفرع `origin/slice/s6-dashboard-resolution` يشير إلى commit `35389a246247516cd51bedbe1b76d078a825b071`.
- المستودع `C:\\my_apps\\radar_labor`، الفرع `slice/s6-dashboard-resolution`.
  لا تستخدم force push أو تغييرات خصوصية GitHub. قارن remote قبل أي نشر.
- Flutter 3.47.7 / Dart 3.13.5، Android SDK `C:\\Android\\Sdk`، JDK 17، Pub
  cache `C:\\devcache\\pub` وGradle cache `C:\\devcache\\gradle`.
- APK Release مبني بعد إنجاز المراحل 1+2+3، موجود في `outputs/Radar Labour.apk`، SHA-256
  `7D1870F86E1FD0BE6FFB1944B2D64C37E78BE6F4AFD3A38607CD165F0C2FDEE6`؛
  حجمه 65,224,742 بايت. إنه للتجربة وغير موقع لمتجر Play.
- التحقق الأحدث: `flutter analyze --no-pub` **نظيف تماماً (0 issues)**، و`flutter test --no-pub` اجتاز **94/94** بنجاح تام.
- **المراحل 1+2+3 مكتملة:**
  - توحيد `MaterialApp`، تفكيك `radar_labor_app.dart` إلى ملفات أصغر.
  - واجهة تسجيل الدخول بدون اختيار دور يدوي، شاشة الإعداد الأولي.
  - جداول `AppUsers` و`UserScopes`، `schemaVersion=4`، قفل تدريجي مخزن في DB.
- S6 يتضمن لوحة الحالات وعمليات السكن/الموقع والملخصات؛ راجع WORKLOG وBUGS.
- أضيفت حزمة `excel` محليًا؛ المستورد يستخدم Android Storage Access Framework
  عبر MethodChannel بلا إذن ملفات شامل ولا اتصال.
- ملف المصدر `All Labour Active` يحوي S/O وID No. وName وDesignation وSupplier.
  يمنع تخزين رقم الهوية، ويستخدم S/O ككود مبدئي بعد فحص التكرار. لا يتضمن
  الملف ربط الفريق والسكن؛ على المدير إسناد ذلك محليًا.
- نُقلت نسخة roster شخصية من docs وحذفت (B-007). لا تسترجعها ولا تنشرها.

## العمل المتبقي

ملفات تتجاوز 300 سطر (ما زالت تحتاج تقسيم):
- `lib/features/dashboard/presentation/dashboard_components.dart` — 329 سطراً (يستخدم `part of` — اقرأ `dashboard_screen.dart` أولاً قبل التعديل).

ميزات مطلوبة في drafts لم تُبنَ بعد:
- شاشة إدارة الحسابات (تعطيل / إعادة تعيين كلمة المرور / تحديث النطاق).
- شاشة تعيين العامل لفريق وسكن — ثغرة وظيفية رئيسية (شاشات الحضور فارغة بدونها).

المالك يراجع تحديثات التوثيق الحالية ويعمل لها commit ويرفعها بنفسه؛
لا تدفعها نيابة عنه. بعد ذلك يثبت APK على الهاتف ويجرب الأدوار والاستيراد.

التحقق من الهاتف/ADB غير مثبت. لا تدّع وضع الطيران أو التثبيت الناجح بلا دليل.
لا ترفع APK أو roster أو أسرار. إذا تعذر Flutter بسبب startup lock سجّل ذلك
وواصل ما يمكن التحقق منه بـ Dart، مع إبقاء سبب العائق مفتوحًا في `BUGS.md`.

## البيئة

- لا تشغل `flutter clean` ولا تحذف `.dart_tool` أو كاش Flutter/Pub/Gradle.
- استخدم `work/flutter-profile/android-env.cmd` ثم أوامر Flutter مع `--no-pub`؛
  فهو يضبط Android/JDK/Pub/Gradle وTEMP/TMP المحليين.
- B-003 يوثق حل عوائق Gradle السابقة، وB-005 يوثق قفل Flutter إن عاد.
