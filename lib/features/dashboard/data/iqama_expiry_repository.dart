import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';

final class ExpiringWorker {
  const ExpiringWorker({
    required this.iqamaNo, required this.nameAr, this.nameEn,
    required this.expiryDate, required this.daysRemaining,
  });
  final String iqamaNo;
  final String nameAr;
  final String? nameEn;
  final DateTime expiryDate;
  final int daysRemaining;
}

final class IqamaExpiryRepository {
  static Future<List<ExpiringWorker>> getExpiringWorkers({
    required AppDatabase database, required DateTime nowUtc, int thresholdDays = 30,
  }) async {
    final rows = await (database.select(database.employees)..where((r) => r.archivedAt.isNull() & r.iqamaExpiry.isNotNull())).get();
    final result = <ExpiringWorker>[];
    for (final r in rows) {
      final diff = r.iqamaExpiry!.difference(nowUtc).inDays;
      if (diff <= thresholdDays) {
        result.add(ExpiringWorker(
          iqamaNo: r.iqamaNo, nameAr: r.fullNameAr, nameEn: r.fullNameEn,
          expiryDate: r.iqamaExpiry!, daysRemaining: diff,
        ));
      }
    }
    result.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return List.unmodifiable(result);
  }
}
