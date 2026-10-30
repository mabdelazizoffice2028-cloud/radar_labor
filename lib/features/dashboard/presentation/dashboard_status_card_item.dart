import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class DashboardStatusCardItem extends StatelessWidget {
  const DashboardStatusCardItem({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    super.key,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, color: color, size: AppTokens.space24),
            ],
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
