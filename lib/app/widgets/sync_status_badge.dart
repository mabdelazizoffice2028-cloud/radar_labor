import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/l10n/sync_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Quiet non-intrusive sync status indicator showing "Synced" or "Pending upload (n)" (PRD §23.6).
final class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({required this.arabic, super.key});

  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingOutboxCountProvider);
    final count = pendingAsync.asData?.value ?? 0;
    final hasPending = count > 0;
    final label = hasPending
        ? SyncStrings.pendingUploadStatus(arabic, count)
        : SyncStrings.syncedStatus(arabic);

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space8,
          vertical: AppTokens.space4,
        ),
        decoration: BoxDecoration(
          color: hasPending
              ? AppTokens.statusHousingOnlySoft
              : AppTokens.statusOnSiteSoft,
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasPending
                  ? Icons.cloud_upload_outlined
                  : Icons.cloud_done_outlined,
              size: 16,
              color: hasPending
                  ? AppTokens.statusHousingOnly
                  : AppTokens.statusOnSite,
            ),
            const SizedBox(width: AppTokens.space4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasPending
                    ? AppTokens.statusHousingOnly
                    : AppTokens.statusOnSite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
