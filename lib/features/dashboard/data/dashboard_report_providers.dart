import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/lockout_settings_extension.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/dashboard/data/daily_report_compiler.dart';
import 'package:radar_labor/features/dashboard/data/iqama_expiry_repository.dart';

final siteLockoutHourProvider = FutureProvider<int>((ref) => ref.watch(settingsRepositoryProvider).readSiteLockoutHour());

final expiringWorkersProvider = FutureProvider<List<ExpiringWorker>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final now = ref.watch(clockProvider).nowUtc();
  return IqamaExpiryRepository.getExpiringWorkers(database: db, nowUtc: now);
});

final dailyReportCompilerProvider = Provider<DailyReportCompilerService>((ref) => DailyReportCompilerService(ref.watch(appDatabaseProvider)));

final class DailyReportCompilerService {
  const DailyReportCompilerService(this._db);
  final AppDatabase _db;

  Future<String> compile({
    required StatusSnapshot snapshot, required String date, required bool arabic,
  }) => DailyReportCompiler.compile(database: _db, snapshot: snapshot, date: date, arabic: arabic);
}
