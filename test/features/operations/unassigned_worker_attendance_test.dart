import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/data/site_attendance_row_builder.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_state.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_worker_tile.dart';
import 'package:radar_labor/features/operations/presentation/widgets/no_teams_empty_state.dart';

void main() {
  group('Phase 3: Unassigned worker attendance & UI ergonomics', () {
    test('ScopeSnapshot allows no_team for direct attendance', () {
      const scope = ScopeSnapshot(teamIds: {'team-1'}, housingIds: {'h-1'});
      expect(scope.allowsTeam('team-1'), isTrue);
      expect(scope.allowsTeam(OperationsConstants.noTeamId), isTrue);
      expect(scope.allowsTeam('other-team'), isFalse);
    });

    test('SiteAttendanceRowBuilder loads unassigned workers when teamId is no_team', () {
      const emp1 = Employee(
        iqamaNo: '2001', fullNameAr: 'عامل أول',
        employmentType: 'company', jobCategory: 'direct_labor',
        currentTeamId: null, rowVersion: 1,
      );
      const emp2 = Employee(
        iqamaNo: '2002', fullNameAr: 'عامل ثان',
        employmentType: 'rental', jobCategory: 'direct_labor',
        currentTeamId: 'team-1', rowVersion: 1,
      );

      final rows = SiteAttendanceRowBuilder.buildRows(
        teamId: OperationsConstants.noTeamId,
        activeById: {'2001': emp1, '2002': emp2},
        employeesById: {'2001': emp1, '2002': emp2},
        teamsById: {},
        selectedIds: {},
        lockedIds: {},
        arabic: true,
      );

      expect(rows.length, 1);
      expect(rows.first.worker.id, '2001');
      expect(rows.first.origin, WorkerRowOrigin.member);
    });

    testWidgets('NoTeamsEmptyState renders direct attendance button', (tester) async {
      var directTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoTeamsEmptyState(
              arabic: true,
              onCreateTeam: () {},
              onDirectAttendance: () => directTapped = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('create_first_team_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('record_without_team_button')), findsOneWidget);
      expect(find.text(OperationsStrings.directAttendance(true)), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('record_without_team_button')));
      expect(directTapped, isTrue);
    });

    testWidgets('HousingWorkerTile distinguishes unreviewed and absent visually', (tester) async {
      const w = WorkerOption(id: 'w1', code: '101', nameAr: 'محمد');
      const unreviewedRow = HousingWorkerRow(worker: w, reviewState: HousingReviewState.unreviewed);
      const absentRow = HousingWorkerRow(worker: w, reviewState: HousingReviewState.absent);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HousingWorkerTile(row: unreviewedRow, arabic: true, onStateChanged: (_) {}),
                HousingWorkerTile(row: absentRow, arabic: true, onStateChanged: (_) {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text(HousingReviewStrings.reviewStateUnreviewed(true)), findsOneWidget);
      expect(find.text(HousingReviewStrings.reviewStateAbsent(true)), findsOneWidget);
    });
  });
}
