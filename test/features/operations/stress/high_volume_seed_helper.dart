import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';

final class HighVolumeSeedHelper {
  static Future<void> seedLargeDataset(AppDatabase db) async {
    final teams = [
      for (var t = 0; t < 10; t++)
        TeamsCompanion.insert(
          teamId: 'team-$t', nameAr: 'فريق $t', nameEn: Value('Team $t'),
        ),
    ];

    final employees = [
      for (var i = 0; i < 1500; i++)
        EmployeesCompanion.insert(
          iqamaNo: '109870${i.toString().padLeft(4, '0')}',
          fullNameAr: 'عامل $i',
          fullNameEn: Value('Worker $i'),
          currentTeamId: Value('team-${i % 10}'),
          jobCategory: Value(i < 50 ? 'engineer' : 'direct_labor'),
        ),
    ];

    final events = <EventsCompanion>[];
    var seq = 1;
    final now = DateTime.utc(2026, 4, 1, 8);
    for (var day = 1; day <= 30; day++) {
      final date = '2026-04-${day.toString().padLeft(2, '0')}';
      for (var i = 0; i < 150; i++) {
        events.add(EventsCompanion.insert(
          eventId: 'evt-$day-$i', deviceId: 'dev-1', deviceSeq: seq++,
          type: 'sitePresent', action: 'set', businessDate: date,
          employeeUid: Value('109870${i.toString().padLeft(4, '0')}'),
          teamId: Value('team-${i % 10}'), deviceTime: now.add(Duration(days: day)),
        ));
      }
    }

    await db.batch((batch) {
      batch.insertAll(db.teams, teams);
      batch.insertAll(db.employees, employees);
      batch.insertAll(db.events, events);
    });
  }
}
