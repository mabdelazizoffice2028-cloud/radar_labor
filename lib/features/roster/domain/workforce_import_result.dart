/// Outcome of workforce file import committing workers and supervisor accounts.
final class WorkforceImportResult {
  const WorkforceImportResult({
    required this.added,
    required this.updated,
    this.accountsCreated = 0,
  });

  final int added;
  final int updated;
  final int accountsCreated;
}
