import 'package:radar_labor/core/l10n/operations_strings.dart';

/// Closed hierarchy of domain operation failures (PRD §13).
sealed class OperationFailure {
  const OperationFailure();
}

final class PermissionDenied extends OperationFailure {
  const PermissionDenied();
}

final class DateOutOfWindow extends OperationFailure {
  const DateOutOfWindow();
}

final class FutureDate extends OperationFailure {
  const FutureDate();
}

final class WorkersUnavailable extends OperationFailure {
  const WorkersUnavailable(this.workerIds);

  final Set<String> workerIds;
}

final class ScopeChanged extends OperationFailure {
  const ScopeChanged();
}

final class UnresolvedConflicts extends OperationFailure {
  const UnresolvedConflicts();
}

final class TeamNameInvalid extends OperationFailure {
  const TeamNameInvalid();
}

final class TeamNameExists extends OperationFailure {
  const TeamNameExists();
}

final class SaveFailed extends OperationFailure {
  const SaveFailed();
}

final class DatabaseBusy extends OperationFailure {
  const DatabaseBusy();
}

final class SessionRevoked extends OperationFailure {
  const SessionRevoked();
}

final class ActivationRequired extends OperationFailure {
  const ActivationRequired();
}

final class RosterWipeNotConfirmed extends OperationFailure {
  const RosterWipeNotConfirmed();
}

/// Typed exception wrapping an [OperationFailure] (replaces OperationPermissionException).
final class OperationException implements Exception {
  const OperationException(this.failure);

  final OperationFailure failure;

  @override
  String toString() => 'OperationException(${failure.runtimeType})';
}

/// Maps any [OperationFailure] to a localized, actionable message without sensitive data.
abstract final class OperationFailureMessage {
  static String of(OperationFailure failure, bool ar) => switch (failure) {
    PermissionDenied() => OperationsStrings.errPermissionDenied(ar),
    DateOutOfWindow() => OperationsStrings.errDateOutOfWindow(ar),
    FutureDate() => OperationsStrings.errFutureDate(ar),
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
  };
}
