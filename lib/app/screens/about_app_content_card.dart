import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/about_app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AboutAppContentCard extends StatelessWidget {
  const AboutAppContentCard({required this.lang, super.key});
  final String lang;

  @override
  Widget build(BuildContext context) {
    final data = AboutAppStrings.content(lang);
    return Column(
      children: [
        _buildItem(context, data.overviewTitle, data.overviewBody, Icons.info_outline),
        _buildItem(context, data.siteTitle, data.siteBody, Icons.engineering_outlined),
        _buildItem(context, data.campusTitle, data.campusBody, Icons.home_work_outlined),
        _buildItem(context, data.lockoutTitle, data.lockoutBody, Icons.lock_clock_outlined),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, String body, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTokens.primary),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
