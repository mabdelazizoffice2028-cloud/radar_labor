import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/features/dashboard/data/iqama_expiry_repository.dart';

final class IqamaExpirySheet extends StatelessWidget {
  const IqamaExpirySheet({required this.workers, required this.arabic, super.key});
  final List<ExpiringWorker> workers;
  final bool arabic;

  static Future<void> show(BuildContext context, List<ExpiringWorker> workers, bool arabic) =>
      showModalBottomSheet<void>(
        context: context, isScrollControlled: true,
        builder: (_) => FractionallySizedBox(heightFactor: 0.7, child: IqamaExpirySheet(workers: workers, arabic: arabic)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(arabic ? 'تنبيهات الإقامات (${workers.length})' : 'Iqama Expiry Alerts (${workers.length})'),
      automaticallyImplyLeading: false,
      actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
    ),
    body: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: workers.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final w = workers[i];
        final isExpired = w.daysRemaining < 0;
        final color = isExpired ? Theme.of(context).colorScheme.error : Colors.amber.shade800;
        final sub = isExpired
            ? (arabic ? 'منتهية منذ ${-w.daysRemaining} يوم (${w.iqamaNo})' : 'Expired ${-w.daysRemaining} days ago (${w.iqamaNo})')
            : (arabic ? 'متبقي ${w.daysRemaining} يوم (${w.iqamaNo})' : '${w.daysRemaining} days remaining (${w.iqamaNo})');
        return ListTile(
          leading: Icon(isExpired ? Icons.error_outline : Icons.warning_amber_rounded, color: color),
          title: Text(arabic ? w.nameAr : (w.nameEn ?? w.nameAr), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(sub, style: TextStyle(color: color, fontSize: 13)),
        );
      },
    ),
  );
}
