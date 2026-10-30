import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_report_providers.dart';
import 'package:radar_labor/features/dashboard/presentation/iqama_expiry_sheet.dart';

final class IqamaExpiryAlertCard extends ConsumerWidget {
  const IqamaExpiryAlertCard({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(expiringWorkersProvider).value ?? const [];
    if (workers.isEmpty) return const SizedBox.shrink();

    final expiredCount = workers.where((w) => w.daysRemaining < 0).length;
    final title = arabic ? 'تنبيه إقامات العمال' : 'Workforce Iqama Alert';
    final sub = arabic
        ? 'يوجد ${workers.length} عامل إقامتهم منتهية أو قاربت على الانتهاء ($expiredCount منتهية)'
        : '${workers.length} workers with expired or near-expiry Iqamas ($expiredCount expired)';

    return Card(
      color: Colors.amber.shade50,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 32),
        title: Text(title, style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: TextStyle(color: Colors.amber.shade900, fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber.shade900),
        onTap: () => IqamaExpirySheet.show(context, workers, arabic),
      ),
    );
  }
}
