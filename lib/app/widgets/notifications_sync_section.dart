import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';

final class NotificationsSyncSection extends ConsumerWidget {
  const NotificationsSyncSection({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(remoteSyncGatewayProvider);
    final isOffline = gateway is OfflineRemoteSyncGateway;
    final pendingCount = ref.watch(pendingOutboxCountProvider).asData?.value ?? 0;

    final IconData icon;
    final Color color;
    final String title;
    final String subtitle;

    if (isOffline) {
      icon = Icons.cloud_off_outlined;
      color = Colors.grey.shade700;
      title = arabic ? 'الوضع المحلي' : 'Local Mode';
      subtitle = arabic ? 'التطبيق يعمل دون اتصال بالسيرفر' : 'Working offline without server';
    } else if (pendingCount > 0) {
      icon = Icons.cloud_upload_outlined;
      color = Colors.orange.shade800;
      title = arabic ? 'حركات بانتظار الرفع' : 'Pending Uploads';
      subtitle = arabic
          ? 'يوجد $pendingCount حركات مسجلة بانتظار المزامنة'
          : '$pendingCount pending updates waiting to sync';
    } else {
      icon = Icons.cloud_done_outlined;
      color = Colors.green.shade700;
      title = arabic ? 'تمت المزامنة' : 'Fully Synced';
      subtitle = arabic ? 'جميع البيانات مرفوعة ومطابقة للسيرفر' : 'All data synced with server';
    }

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
