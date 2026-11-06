import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/constants/employment_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/attendance_breakdown_calculator.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_housing_operations.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/housing_whatsapp_formatter.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

void main() {
  test('AttendanceBreakdownCalculator: company vs rental matches total and items', () {
    const items = [
      AttendanceBreakdownItem(id: '1', code: '101', name: 'Ali', employmentType: EmploymentConstants.company),
      AttendanceBreakdownItem(id: '2', code: '102', name: 'Omar', employmentType: EmploymentConstants.rental, supplier: 'Supplier A'),
      AttendanceBreakdownItem(id: '3', code: '103', name: 'Zaid', employmentType: 'unknown_type'),
      AttendanceBreakdownItem(id: '4', code: '104', name: 'Hassan', employmentType: 'إيجار', supplier: 'Supplier B'),
    ];

    final breakdown = AttendanceBreakdownCalculator.calculate(items);
    expect(breakdown.totalCount, 4);
    expect(breakdown.companyCount, 2);
    expect(breakdown.rentalCount, 2);
    expect(breakdown.companyWorkers.map((w) => w.code).toList(), ['101', '103']);
    expect(breakdown.rentalWorkers.map((w) => w.code).toList(), ['102', '104']);
    expect(breakdown.rentalBySupplier['Supplier A']?.first.name, 'Omar');
    expect(breakdown.rentalBySupplier['Supplier B']?.first.name, 'Hassan');
  });

  test('Historical snapshot: event payload preserves classification after worker update', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final events = EventRepository(database: db, deviceId: 'test_dev', clock: const SystemClock());
    final housingOps = OperationsHousingOperations(events);

    await db.into(db.employees).insert(db.employees.actualCompanion(
      iqamaNo: '1111111111', fullNameAr: 'خالد', employmentType: drift.Value(EmploymentConstants.company),
    ));

    await housingOps.save(
      date: '2026-11-06',
      housing: const EntityOption(id: HousingConstants.defaultHousingId, nameAr: 'السكن', nameEn: 'Campus'),
      absentIds: {'1111111111'},
      actorUserId: 'user_1',
      workerEmploymentTypes: {'1111111111': EmploymentConstants.company},
    );

    await (db.update(db.employees)..where((e) => e.iqamaNo.equals('1111111111'))).write(
      db.employees.actualCompanion(iqamaNo: '1111111111', employmentType: drift.Value(EmploymentConstants.rental), fullNameAr: 'خالد معدل'),
    );

    final dayEvents = await events.readBusinessDate('2026-11-06');
    final ledger = AttendanceLedger(dayEvents);
    final absentEvent = ledger.activeEventFor(
      const LedgerKey(type: EventType.housingAbsent, housingId: HousingConstants.defaultHousingId, employeeUid: '1111111111'),
    );

    expect(absentEvent?.employmentType, EmploymentConstants.company);
    await db.close();
  });

  test('Housing WhatsApp Formatter: counts and worker names strictly match', () {
    const workers = [
      WhatsappWorkerItem(code: 'C1', name: 'Company Worker 1', employmentType: 'company'),
      WhatsappWorkerItem(code: 'R1', name: 'Rental Worker 1', employmentType: 'rental'),
    ];

    final arMsg = HousingWhatsappFormatter.format(date: '2026-11-06', workers: workers, arabic: true);
    expect(arMsg.contains('C1'), isTrue);
    expect(arMsg.contains('R1'), isTrue);
    expect(arMsg.contains('عمال الشركة:'), isTrue);
    expect(arMsg.contains('عمال الإيجار:'), isTrue);
  });
}

extension on $EmployeesTable {
  EmployeesCompanion actualCompanion({required String iqamaNo, required String fullNameAr, drift.Value<String>? employmentType}) =>
      EmployeesCompanion(iqamaNo: drift.Value(iqamaNo), fullNameAr: drift.Value(fullNameAr), employmentType: employmentType ?? const drift.Value('company'));
}
