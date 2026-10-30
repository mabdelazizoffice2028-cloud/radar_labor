final class AboutAppContentData {
  const AboutAppContentData({
    required this.overviewTitle,
    required this.overviewBody,
    required this.siteTitle,
    required this.siteBody,
    required this.campusTitle,
    required this.campusBody,
    required this.lockoutTitle,
    required this.lockoutBody,
  });

  final String overviewTitle;
  final String overviewBody;
  final String siteTitle;
  final String siteBody;
  final String campusTitle;
  final String campusBody;
  final String lockoutTitle;
  final String lockoutBody;

  factory AboutAppContentData.forLanguage(String lang) => switch (lang) {
    'ar' => const AboutAppContentData(
      overviewTitle: 'نظرة عامة',
      overviewBody:
          'رادار ليبور هو نظام ميداني سريع وبسيط لتتبع حضور العمال في مواقع المشاريع ورصد الغياب في الكامبوس محلياً ودون الحاجة لإنترنت.',
      siteTitle: 'مشرف الموقع (Site Supervisor)',
      siteBody:
          'يقوم بتحديد العمال الحاضرين في فريقه يومياً. في أيام الجمعة يسجل فقط العمال الحاضرين كعمل إضافي (ولا يُحتسب غياب للعمال غير المحددين).',
      campusTitle: 'الكامبوس (CAMPOS)',
      campusBody:
          'يسجل العمال الغائبين يومياً من السبت إلى الخميس. في أيام الجمعة يُغلق تسجيل الغياب تلقائياً.',
      lockoutTitle: 'الإقفال اليومي والمراجعة',
      lockoutBody:
          'يُقفل اليوم تلقائياً بنهايته ولا يمكن للمشرفين تعديل الأيام السابقة. يراجع مدير المشروع والإداري الملخص اليومي والتبريرات.',
    ),
    'ur' => const AboutAppContentData(
      overviewTitle: 'عمومی جائزہ',
      overviewBody:
          'ریڈار لیبر پروجیکٹ سائٹس پر ورکرز کی حاضری اور کیمپس میں غیر حاضری کو ٹریک کرنے کے لیے ایک تیز اور آسان لوکل سسٹم ہے۔',
      siteTitle: 'سائٹ سپروائزر',
      siteBody:
          'روزانہ اپنی ٹیم کے حاضر ورکرز کو منتخب کرتا ہے۔ جمعہ کے روز صرف جمعہ اوور ٹائم کے لیے حاضر ورکرز کا اندراج ہوتا ہے (غیر منتخب ورکرز کو غیر حاضر شمار نہیں کیا جاتا)۔',
      campusTitle: 'کیمپس',
      campusBody:
          'ہفتہ سے جمعرات تک روزانہ غیر حاضر ورکرز کا اندراج کرتا ہے۔ جمعہ کے روز غیر حاضری کا اندراج بند رہتا ہے۔',
      lockoutTitle: 'روزانہ لاک آؤٹ اور جائزہ',
      lockoutBody:
          'ہر دن کے اختتام پر دن لاک ہو جاتا ہے اور سپروائزرز پچھلے دنوں میں ترمیم نہیں کر سکتے۔ پروجیکٹ مینیجرز اور ایڈمن روزانہ خلاصے کا جائزہ لیتے ہیں۔',
    ),
    _ => const AboutAppContentData(
      overviewTitle: 'Overview',
      overviewBody:
          'Radar Labour is a simple, fast daily system to track worker presence across project sites and absences at the CAMPOS completely offline.',
      siteTitle: 'Site Supervisor',
      siteBody:
          'Selects the workers present in their team each day. On Fridays, selects only workers who attended for Friday Overtime (unselected workers are not counted as absent).',
      campusTitle: 'CAMPOS',
      campusBody:
          'Records daily absent workers from Saturday to Thursday. On Fridays, absence recording is closed.',
      lockoutTitle: 'Daily Lockout & Review',
      lockoutBody:
          'Each day closes at the end of the day; past days cannot be edited by supervisors. Project Managers and Admin review daily summaries and manage justifications.',
    ),
  };
}
