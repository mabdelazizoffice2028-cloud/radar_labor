import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/notification_providers.dart';
import 'package:radar_labor/app/widgets/notifications_coverage_section.dart';
import 'package:radar_labor/app/widgets/notifications_sync_section.dart';

final class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({required this.arabic, super.key});
  final bool arabic;

  static Future<void> show(BuildContext context, {required bool arabic}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => NotificationsSheet(arabic: arabic),
      );

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(arabic ? 'مركز التنبيهات' : 'Notification Center', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
    ],
  );

  Widget _allGoodCard() => Card(
    color: Colors.green.shade50,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              arabic ? 'جميع سجلات الحضور والسكن مكتملة لليوم!' : 'All attendance and housing records complete today!',
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverage = ref.watch(todayCoverageProvider).asData?.value;
    final allRecorded = coverage != null && coverage.missingTeams.isEmpty && coverage.missingHousings.isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: 8),
              NotificationsSyncSection(arabic: arabic),
              const SizedBox(height: 8),
              if (coverage != null) NotificationsCoverageSection(coverage: coverage, arabic: arabic),
              if (allRecorded) _allGoodCard(),
            ],
          ),
        ),
      ),
    );
  }
}
