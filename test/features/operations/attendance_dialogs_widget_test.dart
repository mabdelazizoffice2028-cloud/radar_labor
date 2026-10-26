import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/conflict_resolution_strings.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_conflict_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_diff_dialog.dart';

void main() {
  const teamA = EntityOption(id: 'team-a', nameAr: 'فرقة أ', nameEn: 'Team A');
  const w1 = WorkerOption(
    id: 'w1',
    code: '101',
    nameAr: 'أحمد',
    nameEn: 'Ahmed',
  );
  const w2 = WorkerOption(
    id: 'w2',
    code: '102',
    nameAr: 'خالد',
    nameEn: 'Khaled',
  );

  testWidgets('AttendanceDiffDialog renders added and removed workers', (
    tester,
  ) async {
    final diff = AttendanceDiff.compute(
      baseline: const AttendanceBaseline(
        kind: BaselineKind.previousDay,
        date: '2026-04-19',
        workerIds: {'w1'},
      ),
      selectedIds: const {'w2'},
      workersById: const {'w1': w1, 'w2': w2},
      arabic: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttendanceDiffDialog(
            team: teamA,
            date: '2026-04-20',
            diff: diff,
            arabic: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('Compared with 2026-04-19'), findsOneWidget);
    expect(find.textContaining('Khaled (102)'), findsOneWidget);
    expect(find.textContaining('Ahmed (101)'), findsOneWidget);
  });

  testWidgets(
    'AttendanceConflictDialog disables confirm until all conflicts are resolved',
    (tester) async {
      final conflicts = [
        AttendanceConflict(
          worker: w1,
          otherTeamId: 'team-b',
          otherTeamNameAr: 'فرقة ب',
          otherTeamNameEn: 'Team B',
          recordedAtUtc: DateTime.utc(2026, 4, 20, 5, 30), // 08:30 Riyadh
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceConflictDialog(
              conflicts: conflicts,
              currentTeamName: 'Team A',
              arabic: false,
            ),
          ),
        ),
      );

      expect(find.textContaining('08:30'), findsOneWidget);

      final confirmFinder = find.widgetWithText(FilledButton, 'Confirm & Save');
      expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNull);

      await tester.tap(
        find.text(ConflictResolutionStrings.resolveAsTransferTitle(false)),
      );
      await tester.pump();

      expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNotNull);
    },
  );
}
