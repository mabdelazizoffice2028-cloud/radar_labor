import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/operation_sync_outcome.dart';

String operationSyncMessage(OperationSyncOutcome outcome, bool arabic) =>
    switch (outcome) {
      OperationSyncOutcome.synced =>
        OperationsStrings.syncSuccessMessage(arabic),
      OperationSyncOutcome.pending =>
        OperationsStrings.syncPendingMessage(arabic),
      OperationSyncOutcome.offline =>
        OperationsStrings.syncOfflineFallbackMessage(arabic),
      OperationSyncOutcome.failed =>
        OperationFailureMessage.of(const SyncFailed(), arabic),
      OperationSyncOutcome.sessionRevoked =>
        OperationFailureMessage.of(const SessionRevoked(), arabic),
    };
