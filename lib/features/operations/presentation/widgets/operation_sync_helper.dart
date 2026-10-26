import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';

/// Helper to execute synchronization to server with localized UI feedback.
Future<void> performOperationSync({
  required WidgetRef ref,
  required BuildContext context,
  required ActorContext? actor,
  required ScopeSnapshot? scope,
  required bool arabic,
}) async {
  var effActor = actor;
  var effScope = scope;
  if (effActor == null || effScope == null) {
    final s = ref.read(currentSessionProvider);
    if (s != null) {
      effActor ??= ActorContext(userId: s.id, role: s.role);
      effScope ??= ScopeSnapshot(
        teamIds: s.teamIds.toSet(),
        housingIds: s.housingIds.toSet(),
      );
    }
  }

  if (effActor == null || effScope == null) return;
  try {
    final res = await ref
        .read(syncEngineProvider)
        .synchronize(actor: effActor, scope: effScope);
    if (context.mounted) {
      final msg = !res.offline
          ? OperationsStrings.syncSuccessMessage(arabic)
          : OperationsStrings.syncOfflineFallbackMessage(arabic);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(OperationsStrings.syncOfflineFallbackMessage(arabic)),
        ),
      );
    }
  }
}
