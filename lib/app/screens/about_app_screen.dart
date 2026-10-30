import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/about_app_content_card.dart';
import 'package:radar_labor/core/l10n/about_app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

final class _AboutAppScreenState extends State<AboutAppScreen> {
  String _selectedLang = 'en';

  @override
  Widget build(BuildContext context) {
    final isRtl = _selectedLang == 'ar' || _selectedLang == 'ur';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AboutAppStrings.title(_selectedLang)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppTokens.space16),
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(AboutAppStrings.englishLabel)),
                ButtonSegment(value: 'ar', label: Text(AboutAppStrings.arabicLabel)),
                ButtonSegment(value: 'ur', label: Text(AboutAppStrings.urduLabel)),
              ],
              selected: {_selectedLang},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) setState(() => _selectedLang = set.first);
              },
            ),
            const SizedBox(height: AppTokens.space16),
            AboutAppContentCard(lang: _selectedLang),
          ],
        ),
      ),
    );
  }
}
