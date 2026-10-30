import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/l10n/notifications_strings.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class NotificationsSyncSection extends ConsumerWidget {
  const NotificationsSyncSection({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(remoteSyncGatewayProvider);
    final isOffline = gateway is OfflineRemoteSyncGateway;
    final pendingCount =
        ref.watch(pendingOutboxCountProvider).asData?.value ?? 0;

    final IconData icon;
    final Color color;
    final String title;
    final String subtitle;

    if (isOffline) {
      icon = Icons.cloud_off_outlined;
      color = AppTokens.textSecondary;
      title = NotificationsStrings.localModeTitle(arabic);
      subtitle = NotificationsStrings.localModeSub(arabic);
    } else if (pendingCount > 0) {
      icon = Icons.cloud_upload_outlined;
      color = AppTokens.statusHousingOnly;
      title = NotificationsStrings.pendingUploadsTitle(arabic);
      subtitle = NotificationsStrings.pendingUploadsSub(arabic, pendingCount);
    } else {
      icon = Icons.cloud_done_outlined;
      color = AppTokens.statusOnSite;
      title = NotificationsStrings.fullySyncedTitle(arabic);
      subtitle = NotificationsStrings.fullySyncedSub(arabic);
    }

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: AppTokens.space12),
        ),
      ),
    );
  }
}
