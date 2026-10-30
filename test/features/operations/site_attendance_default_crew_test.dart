import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_notifier.dart';

final class _FakeSiteStore implements SiteAttendanceStore {
  @override
  String currentBusinessDate() => '2026-10-26';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeDraftStore implements AttendanceDraftStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('selectDefaultCrew selects only unlocked member rows', () {
    final container = ProviderContainer(overrides: [
      siteAttendanceStoreProvider.overrideWithValue(_FakeSiteStore()),
      attendanceDraftStoreProvider.overrideWithValue(_FakeDraftStore()),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(siteAttendanceNotifierProvider.notifier);
    const worker1 = WorkerOption(id: 'w1', code: 'C1', nameAr: 'عامل 1');
    const worker2 = WorkerOption(id: 'w2', code: 'C2', nameAr: 'ضيف 2');
    const worker3 = WorkerOption(id: 'w3', code: 'C3', nameAr: 'مقفل 3');

    final rows = [
      const AttendanceRow(worker: worker1, isPresent: false, origin: WorkerRowOrigin.member),
      const AttendanceRow(worker: worker2, isPresent: false, origin: WorkerRowOrigin.guest),
      const AttendanceRow(worker: worker3, isPresent: false, origin: WorkerRowOrigin.locked),
    ];

    notifier.state = notifier.state.copyWith(rows: rows);
    notifier.selectDefaultCrew();

    final result = container.read(siteAttendanceNotifierProvider).rows;
    expect(result[0].isPresent, isTrue); // member row selected
    expect(result[1].isPresent, isFalse); // guest left unchanged
    expect(result[2].isPresent, isFalse); // locked row ignored
  });
}
