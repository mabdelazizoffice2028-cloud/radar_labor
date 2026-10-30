import 'package:radar_labor/core/database/app_database.dart';

final class OperationsDevTools {
  const OperationsDevTools._();

  static Future<void> clearTestData(AppDatabase database) async {
    await database.transaction(() async {
      await database.customStatement('DELETE FROM events');
      await database.customStatement('DELETE FROM worker_history');
      await database.customStatement('DELETE FROM audit_log');
    });
  }
}
