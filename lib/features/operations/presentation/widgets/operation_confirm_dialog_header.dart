import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class OperationConfirmDialogHeader extends StatelessWidget {
  const OperationConfirmDialogHeader({
    required this.title,
    required this.entityName,
    required this.date,
    required this.arabic,
    super.key,
  });

  final String title;
  final String entityName;
  final String date;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final isFriday = isFridayBusinessDate(date);
    final subStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: AppTokens.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
            if (isFriday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTokens.statusOnSiteSoft,
                  borderRadius: BorderRadius.circular(AppTokens.radius12),
                ),
                child: Text(
                  arabic ? 'إضافي الجمعة' : 'Friday Overtime',
                  style: const TextStyle(
                    color: AppTokens.statusOnSite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text('$entityName • $date', style: subStyle),
      ],
    );
  }
}
