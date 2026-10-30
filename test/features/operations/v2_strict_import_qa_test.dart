import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/roster/data/workforce_import_repository.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

final class _C implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 4, 19, 10, 0);
}

void main() {
  late AppDatabase db;
  late WorkforceImportRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = WorkforceImportRepository(db, clock: _C());
    await db.into(db.employees).insert(
      EmployeesCompanion.insert(
        iqamaNo: '1000000001', fullNameAr: 'عامل تجربة',
        jobTitle: const Value('Direct'), jobCategory: const Value('direct_labor'),
        employmentType: const Value('company'), currentTeamId: const Value('team-1'),
      ),
    );
  });

  tearDown(() => db.close());

  group('Strict Import QA', () {
    test('rejects file when iqama is not 10 digits and rolls back transaction', () async {
      await expectLater(
        repo.commit([const WorkforceRow(code: '12345', name: 'خطأ', designation: 'D', supplier: '')]),
        throwsA(isA<FormatException>()),
      );
      final count = (await (db.select(db.employees)..where((e) => e.iqamaNo.equals('12345'))).get()).length;
      expect(count, 0);
    });

    test('rejects file when duplicate iqama exists inside file and rolls back', () async {
      await expectLater(
        repo.commit([
          const WorkforceRow(code: '1000000002', name: 'عامل 2', designation: 'D', supplier: ''),
          const WorkforceRow(code: '1000000002', name: 'عامل 2 مكرر', designation: 'D', supplier: ''),
        ]),
        throwsA(isA<FormatException>()),
      );
      final count = (await (db.select(db.employees)..where((e) => e.iqamaNo.equals('1000000002'))).get()).length;
      expect(count, 0);
    });

    test('records worker_history on successful import insert and update', () async {
      final res = await repo.commit([
        const WorkforceRow(code: '1000000001', name: 'عامل تجربة محدث', designation: 'D', supplier: ''),
        const WorkforceRow(code: '1000000003', name: 'عامل جديد', designation: 'D', supplier: ''),
      ]);
      expect(res.added, 1);
      expect(res.updated, 1);
      final history = await db.select(db.workerHistory).get();
      expect(history.length, 2);
      expect(history.any((h) => h.iqamaNo == '1000000001' && h.action == 'imported_update'), isTrue);
      expect(history.any((h) => h.iqamaNo == '1000000003' && h.action == 'imported_create'), isTrue);
    });
  });
}
