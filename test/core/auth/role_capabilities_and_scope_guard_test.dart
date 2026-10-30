import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';

void main() {
  group('RoleCapabilities (§5.1 & §5.2)', () {
    test('matrix_matchesPrdSpecificationForAllFiveRoles', () {
      for (final role in [AuthRole.projectManager, AuthRole.hr]) {
        final cap = role.capabilities;
        expect(cap.canViewDashboard, isTrue);
        expect(cap.canViewAllHistory, isTrue);
        expect(cap.canViewOwnHistory, isFalse);
        expect(cap.canManageReferenceData, isTrue);
        expect(cap.canManageAccounts, isTrue);
        expect(cap.canResolveConflicts, isTrue);
        expect(cap.canJustifyAbsence, isTrue);
        expect(cap.canRecordHousing, isFalse);
        expect(cap.canRecordSite, isFalse);
        expect(cap.canSetupTeam, isFalse);
        expect(cap.canEditOwnTeamMembers, isFalse);
        expect(cap.canAddCrossTeamWorker, isFalse);
        expect(cap.canResolveOwnSaveConflicts, isFalse);
        expect(cap.canEditPastDays, isTrue);
        expect(cap.canWipeRoster, isTrue);
        expect(cap.canViewAuditLog, isTrue);
        expect(cap.sections, const [
          AppSection.dashboard,
          AppSection.workers,
          AppSection.teams,
          AppSection.history,
          AppSection.settings,
        ]);
      }

      final housing = AuthRole.housingSupervisor.capabilities;
      expect(housing.canViewDashboard, isFalse);
      expect(housing.canViewAllHistory, isFalse);
      expect(housing.canViewOwnHistory, isTrue);
      expect(housing.canManageReferenceData, isFalse);
      expect(housing.canManageAccounts, isFalse);
      expect(housing.canResolveConflicts, isFalse);
      expect(housing.canJustifyAbsence, isFalse);
      expect(housing.canRecordHousing, isTrue);
      expect(housing.canRecordSite, isFalse);
      expect(housing.canSetupTeam, isFalse);
      expect(housing.canEditOwnTeamMembers, isFalse);
      expect(housing.canAddCrossTeamWorker, isFalse);
      expect(housing.canResolveOwnSaveConflicts, isFalse);
      expect(housing.canEditPastDays, isFalse);
      expect(housing.canWipeRoster, isFalse);
      expect(housing.canViewAuditLog, isFalse);
      expect(housing.sections, const [
        AppSection.checkIn,
        AppSection.history,
        AppSection.settings,
      ]);

      final site = AuthRole.siteSupervisor.capabilities;
      expect(site.canViewDashboard, isFalse);
      expect(site.canViewAllHistory, isFalse);
      expect(site.canViewOwnHistory, isTrue);
      expect(site.canManageReferenceData, isFalse);
      expect(site.canManageAccounts, isFalse);
      expect(site.canResolveConflicts, isFalse);
      expect(site.canJustifyAbsence, isFalse);
      expect(site.canRecordHousing, isFalse);
      expect(site.canRecordSite, isTrue);
      expect(site.canSetupTeam, isTrue);
      expect(site.canEditOwnTeamMembers, isTrue);
      expect(site.canAddCrossTeamWorker, isTrue);
      expect(site.canResolveOwnSaveConflicts, isTrue);
      expect(site.canEditPastDays, isFalse);
      expect(site.canWipeRoster, isFalse);
      expect(site.canViewAuditLog, isFalse);
      expect(site.sections, const [
        AppSection.checkIn,
        AppSection.history,
        AppSection.settings,
      ]);

      final viewer = AuthRole.viewer.capabilities;
      expect(viewer.canViewDashboard, isTrue);
      expect(viewer.canViewAllHistory, isFalse);
      expect(viewer.canViewOwnHistory, isFalse);
      expect(viewer.canManageReferenceData, isFalse);
      expect(viewer.canManageAccounts, isFalse);
      expect(viewer.canResolveConflicts, isFalse);
      expect(viewer.canJustifyAbsence, isFalse);
      expect(viewer.canRecordHousing, isFalse);
      expect(viewer.canRecordSite, isFalse);
      expect(viewer.canSetupTeam, isFalse);
      expect(viewer.canEditOwnTeamMembers, isFalse);
      expect(viewer.canAddCrossTeamWorker, isFalse);
      expect(viewer.canResolveOwnSaveConflicts, isFalse);
      expect(viewer.canEditPastDays, isFalse);
      expect(viewer.canWipeRoster, isFalse);
      expect(viewer.canViewAuditLog, isFalse);
      expect(viewer.sections, const [
        AppSection.dashboard,
        AppSection.settings,
      ]);
    });
  });

  group('ScopeGuard (§5.5 & §8.4)', () {
    const scope = ScopeSnapshot(teamIds: {'team-1'}, housingIds: {'housing-1'});
    const today = '2026-10-23';

    test('siteSupervisor_allowedForAssignedTeamAndWindow', () {
      const actor = ActorContext(
        userId: 'sup-1',
        role: AuthRole.siteSupervisor,
      );
      expect(
        () => ScopeGuard.guardSiteRecord(
          actor: actor,
          scope: scope,
          teamId: 'team-1',
          date: '2026-10-23',
          todayBusinessDate: today,
        ),
        returnsNormally,
      );
      // Supervisor cannot edit past days
      expect(
        () => ScopeGuard.guardSiteRecord(
          actor: actor,
          scope: scope,
          teamId: 'team-1',
          date: '2026-10-16',
          todayBusinessDate: today,
        ),
        throwsA(
          isA<OperationException>().having(
            (e) => e.failure,
            'failure',
            isA<PermissionDenied>(),
          ),
        ),
      );
    });

    test('housingSupervisor_rejectsFridayRecord', () {
      const actor = ActorContext(
        userId: 'house-1',
        role: AuthRole.housingSupervisor,
      );
      // '2026-10-23' is Friday
      expect(
        () => ScopeGuard.guardHousingRecord(
          actor: actor,
          scope: scope,
          housingId: 'housing-1',
          date: '2026-10-23',
          todayBusinessDate: today,
        ),
        throwsA(
          isA<OperationException>().having(
            (e) => e.failure,
            'failure',
            isA<FridayAbsenceNotAllowed>(),
          ),
        ),
      );
    });

    test(
      'siteGuard_rejectsUnassignedTeamAndNonSiteRolesAndOutOfWindowDates',
      () {
        const siteActor = ActorContext(
          userId: 'sup-1',
          role: AuthRole.siteSupervisor,
        );
        expect(
          () => ScopeGuard.guardSiteRecord(
            actor: siteActor,
            scope: scope,
            teamId: 'team-other',
            date: today,
            todayBusinessDate: today,
          ),
          throwsA(
            isA<OperationException>().having(
              (e) => e.failure,
              'failure',
              isA<PermissionDenied>(),
            ),
          ),
        );

        for (final forbiddenRole in [
          AuthRole.projectManager,
          AuthRole.hr,
          AuthRole.housingSupervisor,
          AuthRole.viewer,
        ]) {
          expect(
            () => ScopeGuard.guardSiteRecord(
              actor: ActorContext(userId: 'u-1', role: forbiddenRole),
              scope: scope,
              teamId: 'team-1',
              date: today,
              todayBusinessDate: today,
            ),
            throwsA(
              isA<OperationException>().having(
                (e) => e.failure,
                'failure',
                isA<PermissionDenied>(),
              ),
            ),
          );
        }

        expect(
          () => ScopeGuard.guardSiteRecord(
            actor: siteActor,
            scope: scope,
            teamId: 'team-1',
            date: '2026-10-24',
            todayBusinessDate: today,
          ),
          throwsA(
            isA<OperationException>().having(
              (e) => e.failure,
              'failure',
              isA<FutureDate>(),
            ),
          ),
        );

        expect(
          () => ScopeGuard.guardSiteRecord(
            actor: siteActor,
            scope: scope,
            teamId: 'team-1',
            date: '2026-10-15',
            todayBusinessDate: today,
          ),
          throwsA(
            isA<OperationException>().having(
              (e) => e.failure,
              'failure',
              isA<DateOutOfWindow>(),
            ),
          ),
        );
      },
    );
  });
}
