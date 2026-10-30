import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operation_sync_outcome.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_sync_message.dart';

export 'package:radar_labor/features/operations/presentation/widgets/operation_sync_message.dart';

Future<OperationSyncOutcome?> performOperationSync({
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

  if (effActor == null || effScope == null) return null;
  final engine = ref.read(syncEngineProvider);
  OperationSyncOutcome outcome;
  String? typedMessage;
  try {
    final res = await engine.synchronize(actor: effActor, scope: effScope);
    outcome = OperationSyncOutcome.classify(
      offline: res.offline,
      sessionRevoked: res.sessionRevoked,
      pendingRemaining: res.pendingRemaining,
    );
  } on OperationException catch (error) {
    outcome = OperationSyncOutcome.failed;
    typedMessage = OperationFailureMessage.of(error.failure, arabic);
  } on Exception {
    outcome = OperationSyncOutcome.failed;
  }
  if (context.mounted) {
    showOperationSyncSnackBar(
      context,
      outcome,
      arabic: arabic,
      messageOverride: typedMessage,
    );
  }
  return outcome;
}

void showOperationSyncSnackBar(
  BuildContext context,
  OperationSyncOutcome outcome, {
  required bool arabic,
  String? messageOverride,
}) {
  final confirmed = outcome.isConfirmedSuccess;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      backgroundColor:
          confirmed ? AppTokens.statusOnSite : AppTokens.statusHousingOnly,
      content: Text(messageOverride ?? operationSyncMessage(outcome, arabic)),
    ),
  );
}
