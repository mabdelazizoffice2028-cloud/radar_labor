import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/database/app_database.dart' hide EmploymentPeriod;
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_engine.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/settings_attendance_draft_store.dart';
import 'package:radar_labor/features/operations/data/site_attendance_loader.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';
import 'high_volume_seed_helper.dart';

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 4, 30, 12);
}

void main() {
  late AppDatabase db;
  late EventRepository events;
  late SiteAttendanceLoader loader;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await HighVolumeSeedHelper.seedLargeDataset(db);
    events = EventRepository(database: db, deviceId: 'dev-1', clock: _Clock());
    loader = SiteAttendanceLoader(database: db, events: events, draftStore: SettingsAttendanceDraftStore(settings: LocalSettingsRepository(db), clock: _Clock()));
  });

  tearDownAll(() => db.close());

  test('Benchmark: StatusEngine.evaluate over 1,500 profiles with 4,500+ events', () async {
    const engine = StatusEngine();
    final allEvents = await events.readBusinessDate('2026-04-30');
    final profiles = [
      for (var i = 0; i < 1500; i++)
        WorkerProfile(
          employeeUid: '109870${i.toString().padLeft(4, '0')}', code: '109870${i.toString().padLeft(4, '0')}',
          fullName: 'Worker $i', jobCategory: i < 50 ? 'engineer' : 'direct_labor',
          employmentPeriods: const [EmploymentPeriod('2026-01-01')],
        ),
    ];

    final sw = Stopwatch()..start();
    final snapshot = engine.evaluate(
      workers: profiles, events: allEvents, businessDate: '2026-04-30',
      nowUtc: DateTime.utc(2026, 4, 30, 15), slaMinutes: 60,
    );
    sw.stop();
    expect(snapshot.workers.length, 1500);
    expect(sw.elapsedMilliseconds, lessThan(800));
  });

  test('Benchmark: WorkerSearchFilter across 1,500 workers', () {
    final sw = Stopwatch()..start();
    var matches = 0;
    for (var i = 0; i < 1500; i++) {
      if (WorkerSearchFilter.matches(query: '0054', code: '109870${i.toString().padLeft(4, '0')}', nameAr: 'عامل $i')) matches++;
    }
    sw.stop();
    expect(matches, 1);
    expect(sw.elapsedMilliseconds, lessThan(100));
  });

  test('Benchmark: SiteAttendanceLoader loads team attendance day in high-volume DB', () async {
    final sw = Stopwatch()..start();
    final day = await loader.load(
      team: const EntityOption(id: 'team-0', nameAr: 'فريق 0', nameEn: 'Team 0'),
      date: '2026-04-30', today: '2026-04-30', arabic: true,
    );
    sw.stop();
    expect(day.rows.length, 150);
    expect(sw.elapsedMilliseconds, lessThan(1000));
  });
}
