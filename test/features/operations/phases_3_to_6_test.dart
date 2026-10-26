import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/l10n/conflict_resolution_strings.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/settings_housing_draft_store.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_worker_tile.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime nowUtc() => _now;
}

void main() {
  const w1 = WorkerOption(
    id: 'w1',
    code: '101',
    nameAr: 'أحمد علي',
    nameEn: 'Ahmed Ali',
  );
  const w2 = WorkerOption(
    id: 'w2',
    code: '102',
    nameAr: 'خالد عمر',
    nameEn: 'Khaled Omar',
  );
  const w3 = WorkerOption(
    id: 'w3',
    code: '103',
    nameAr: 'محمد حسن',
    nameEn: 'Mohamed Hassan',
  );

  group('Phase 4: HousingDraftStore persistence and restoration', () {
    test('writes and reads draft JSON correctly', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final settings = LocalSettingsRepository(db);
      final clock = _FixedClock(DateTime.utc(2026, 10, 26, 10, 0));
      final store = SettingsHousingDraftStore(settings: settings, clock: clock);

      await store.writeDraft(
        housingId: 'h-1',
        date: '2026-10-26',
        reviewedWorkerIds: ['w1', 'w3'],
        absentWorkerIds: ['w2'],
      );

      final restored = await store.readDraft(
        housingId: 'h-1',
        date: '2026-10-26',
      );

      expect(restored, isNotNull);
      expect(restored!.reviewedWorkerIds, equals(['w1', 'w3']));
      expect(restored.absentWorkerIds, equals(['w2']));
      expect(restored.updatedAtUtc, equals(DateTime.utc(2026, 10, 26, 10, 0)));

      await store.deleteDraft(housingId: 'h-1', date: '2026-10-26');
      final afterDelete = await store.readDraft(
        housingId: 'h-1',
        date: '2026-10-26',
      );
      expect(afterDelete, isNull);
      await db.close();
    });
  });

  group('Phase 4: HousingCheckState 3-State review and in-list search', () {
    test('3-state review counters compute correctly', () {
      final rows = [
        const HousingWorkerRow(
          worker: w1,
          reviewState: HousingReviewState.reviewedPresent,
        ),
        const HousingWorkerRow(
          worker: w2,
          reviewState: HousingReviewState.absent,
        ),
        const HousingWorkerRow(
          worker: w3,
          reviewState: HousingReviewState.unreviewed,
        ),
      ];
      final state = HousingCheckState(
        selectedDate: '2026-10-26',
        todayDate: '2026-10-26',
        rows: rows,
      );

      expect(state.totalCount, equals(3));
      expect(state.reviewedCount, equals(1));
      expect(state.absentCount, equals(1));
      expect(state.unreviewedCount, equals(1));
      expect(state.reviewedWorkerIds, equals({'w1'}));
      expect(state.absentWorkerIds, equals({'w2'}));
    });

    test('HousingCheckState filters workers by code and names', () {
      final rows = [
        const HousingWorkerRow(worker: w1),
        const HousingWorkerRow(worker: w2),
        const HousingWorkerRow(worker: w3),
      ];

      var state = HousingCheckState(
        selectedDate: '2026-10-26',
        todayDate: '2026-10-26',
        rows: rows,
        searchQuery: '102',
      );
      expect(state.filteredRows.length, equals(1));
      expect(state.filteredRows.first.worker.code, equals('102'));

      state = state.copyWith(searchQuery: 'Khaled');
      expect(state.filteredRows.length, equals(1));
      expect(state.filteredRows.first.worker.id, equals('w2'));

      state = state.copyWith(searchQuery: 'محمد');
      expect(state.filteredRows.length, equals(1));
      expect(state.filteredRows.first.worker.id, equals('w3'));
    });
  });

  group(
    'Phase 4: SiteAttendanceState in-list search and filtered select all',
    () {
      test('SiteAttendanceState filters workers and computes filteredRows', () {
        final rows = [
          const AttendanceRow(
            worker: w1,
            isPresent: true,
            origin: WorkerRowOrigin.member,
          ),
          const AttendanceRow(
            worker: w2,
            isPresent: false,
            origin: WorkerRowOrigin.member,
          ),
          const AttendanceRow(
            worker: w3,
            isPresent: true,
            origin: WorkerRowOrigin.member,
          ),
        ];
        final state = SiteAttendanceState(
          selectedDate: '2026-10-26',
          todayDate: '2026-10-26',
          rows: rows,
          searchQuery: '101',
        );

        expect(state.filteredRows.length, equals(1));
        expect(state.filteredRows.first.worker.id, equals('w1'));
      });
    },
  );

  group('Phase 3 & Phase 6: Localization and RTL/LTR Widget tests', () {
    test(
      'DashboardStrings and ConflictResolutionStrings translations exist',
      () {
        expect(DashboardStrings.resolve(true), equals('تسوية'));
        expect(DashboardStrings.resolve(false), equals('Resolve'));
        expect(DashboardStrings.onSiteStatus(true), equals('في الموقع'));
        expect(DashboardStrings.onSiteStatus(false), equals('On site'));
        expect(
          ConflictResolutionStrings.resolveAsCorrectionTitle(true),
          equals('نعم، صحّح السجل السابق'),
        );
        expect(
          ConflictResolutionStrings.resolveAsCorrectionTitle(false),
          equals('Yes, correct previous record'),
        );
        expect(
          SupervisorTaskStrings.taskStatusSavedCompleted(true),
          equals('تم الحفظ محلياً — مكتمل'),
        );
        expect(
          SupervisorTaskStrings.taskStatusSavedCompleted(false),
          equals('Saved Locally / Completed'),
        );
      },
    );

    testWidgets(
      'HousingWorkerTile renders in Arabic RTL and English LTR without overflow',
      (tester) async {
        const row = HousingWorkerRow(
          worker: w1,
          reviewState: HousingReviewState.absent,
        );

        // Test RTL Arabic
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: HousingWorkerTile(
                  row: row,
                  arabic: true,
                  onStateChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        expect(find.textContaining('أحمد علي'), findsOneWidget);
        expect(
          find.textContaining(HousingReviewStrings.reviewStateAbsent(true)),
          findsOneWidget,
        );

        // Test LTR English
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: Scaffold(
                body: HousingWorkerTile(
                  row: row,
                  arabic: false,
                  onStateChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        expect(find.textContaining('Ahmed Ali'), findsOneWidget);
        expect(
          find.textContaining(HousingReviewStrings.reviewStateAbsent(false)),
          findsOneWidget,
        );
      },
    );
  });
}
