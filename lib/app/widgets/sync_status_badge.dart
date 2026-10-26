import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/l10n/sync_strings.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Quiet non-intrusive sync status indicator showing "Local Mode", "Synced", or "Pending upload (n)" (PRD §23.6).
final class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({required this.arabic, super.key});

  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(remoteSyncGatewayProvider);
    final isOffline = gateway is OfflineRemoteSyncGateway;
    final pendingAsync = ref.watch(pendingOutboxCountProvider);
    final count = pendingAsync.asData?.value ?? 0;
    final hasPending = count > 0;

    final String label;
    final Color bgColor;
    final Color fgColor;
    final IconData icon;

    if (isOffline) {
      label = SyncStrings.localMode(arabic);
      bgColor = AppTokens.statusNotRecordedSoft;
      fgColor = AppTokens.statusNotRecorded;
      icon = Icons.cloud_off_outlined;
    } else if (hasPending) {
      label = SyncStrings.pendingUploadStatus(arabic, count);
      bgColor = AppTokens.statusHousingOnlySoft;
      fgColor = AppTokens.statusHousingOnly;
      icon = Icons.cloud_upload_outlined;
    } else {
      label = SyncStrings.syncedStatus(arabic);
      bgColor = AppTokens.statusOnSiteSoft;
      fgColor = AppTokens.statusOnSite;
      icon = Icons.cloud_done_outlined;
    }

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space8,
          vertical: AppTokens.space4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: AppTokens.space4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
