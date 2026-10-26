import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/audit/audit_entry.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/admin_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Admin-only read-only view of the append-only Audit Log (PRD §23.5, D-26).
final class AuditLogTabView extends ConsumerWidget {
  const AuditLogTabView({required this.arabic, this.actorOverride, super.key});

  final bool arabic;
  final ActorContext? actorOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final actor =
        actorOverride ??
        ActorContext(
          userId: session?.id ?? 'admin',
          role: session?.role ?? AuthRole.projectManager,
        );
    final repo = ref.watch(auditLogRepositoryProvider);

    return FutureBuilder<List<ResolvedAuditEntry>>(
      future: repo.readForAdmin(actor: actor, arabic: arabic),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data ?? const <ResolvedAuditEntry>[];
        if (entries.isEmpty) {
          return Center(child: Text(AdminStrings.auditLogEmpty(arabic)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTokens.space16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final item = entries[index];
            final actionLabel = AdminStrings.auditActionLabel(
              arabic,
              item.entry.action,
            );
            final entityLabel = item.entityDisplayName ?? item.entry.entityId;
            final dateStr = businessDateFor(item.entry.deviceTime);
            final timeStr = RiyadhTimeFormat.hhMm(item.entry.deviceTime);

            return Card(
              margin: const EdgeInsets.only(bottom: AppTokens.space8),
              child: ListTile(
                leading: const Icon(
                  Icons.history_edu_outlined,
                  color: AppTokens.primary,
                ),
                title: Text('$actionLabel — $entityLabel'),
                subtitle: Text('${item.actorDisplayName} • $dateStr $timeStr'),
              ),
            );
          },
        );
      },
    );
  }
}
