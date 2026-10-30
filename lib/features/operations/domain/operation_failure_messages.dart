import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

abstract final class OperationFailureMessage {
  static String of(OperationFailure failure, bool ar) => switch (failure) {
    PermissionDenied() => OperationsStrings.errPermissionDenied(ar),
    DateOutOfWindow() => OperationsStrings.errDateOutOfWindow(ar),
    FutureDate() => OperationsStrings.errFutureDate(ar),
    DayLockedOut() => OperationsStrings.dayLockedOut(ar),
    WorkersUnavailable() => OperationsStrings.errWorkersUnavailable(ar),
    ScopeChanged() => OperationsStrings.errScopeChanged(ar),
    UnresolvedConflicts() => OperationsStrings.errUnresolvedConflicts(ar),
    TeamNameInvalid() => OperationsStrings.errTeamNameInvalid(ar),
    TeamNameExists() => OperationsStrings.errTeamNameExists(ar),
    SaveFailed() => OperationsStrings.errSaveFailed(ar),
    DatabaseBusy() => OperationsStrings.errDatabaseBusy(ar),
    SessionRevoked() => OperationsStrings.errSessionRevoked(ar),
    ActivationRequired() => OperationsStrings.errActivationRequired(ar),
    RosterWipeNotConfirmed() => OperationsStrings.errRosterWipeNotConfirmed(ar),
    SyncFailed() => OperationsStrings.errSyncFailed(ar),
    FridayAbsenceNotAllowed() => OperationsStrings.errFridayAbsenceNotAllowed(ar),
  };
}
