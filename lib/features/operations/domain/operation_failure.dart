export 'package:radar_labor/features/operations/domain/operation_failure_messages.dart';

sealed class OperationFailure {
  const OperationFailure();
}

final class PermissionDenied extends OperationFailure { const PermissionDenied(); }
final class DateOutOfWindow extends OperationFailure { const DateOutOfWindow(); }
final class FutureDate extends OperationFailure { const FutureDate(); }
final class DayLockedOut extends OperationFailure { const DayLockedOut(); }
final class ScopeChanged extends OperationFailure { const ScopeChanged(); }
final class UnresolvedConflicts extends OperationFailure { const UnresolvedConflicts(); }
final class TeamNameInvalid extends OperationFailure { const TeamNameInvalid(); }
final class TeamNameExists extends OperationFailure { const TeamNameExists(); }
final class SaveFailed extends OperationFailure { const SaveFailed(); }
final class DatabaseBusy extends OperationFailure { const DatabaseBusy(); }
final class SessionRevoked extends OperationFailure { const SessionRevoked(); }
final class ActivationRequired extends OperationFailure { const ActivationRequired(); }
final class RosterWipeNotConfirmed extends OperationFailure { const RosterWipeNotConfirmed(); }
final class SyncFailed extends OperationFailure { const SyncFailed(); }

final class WorkersUnavailable extends OperationFailure {
  const WorkersUnavailable(this.workerIds);
  final Set<String> workerIds;
}

final class OperationException implements Exception {
  const OperationException(this.failure);
  final OperationFailure failure;

  @override
  String toString() => 'OperationException(${failure.runtimeType})';
}
