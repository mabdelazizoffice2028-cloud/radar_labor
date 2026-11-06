/// Domain result model for the test data wipe operation.
final class TestDataWipeResult {
  const TestDataWipeResult({
    required this.wipedEventsCount,
    required this.wipedDraftsCount,
    required this.backupFilePath,
    required this.wipedAt,
  });

  final int wipedEventsCount;
  final int wipedDraftsCount;
  final String backupFilePath;
  final DateTime wipedAt;
}
