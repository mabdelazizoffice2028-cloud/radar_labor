import 'package:radar_labor/core/l10n/about_app_content_data.dart';

export 'package:radar_labor/core/l10n/about_app_content_data.dart';

final class AboutAppStrings {
  const AboutAppStrings._();

  static String title(String lang) => switch (lang) {
    'ar' => 'حول هذا التطبيق',
    'ur' => 'اس ایپ کے بارے میں',
    _ => 'About this app',
  };

  static String englishLabel = 'English';
  static String arabicLabel = 'العربية';
  static String urduLabel = 'اردو';

  static AboutAppContentData content(String lang) =>
      AboutAppContentData.forLanguage(lang);
}
