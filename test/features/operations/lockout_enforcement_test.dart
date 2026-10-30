import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';

void main() {
  group('Lockout Enforcement (Phase 3)', () {
    const scope = ScopeSnapshot(teamIds: {'t1'}, housingIds: {'main_campus'});
    final siteSup = ActorContext(userId: 'sup-1', role: AuthRole.siteSupervisor);
    final housingSup = ActorContext(userId: 'hsup-1', role: AuthRole.housingSupervisor);

    final at21Riyadh = DateTime.utc(2026, 10, 26, 18, 0); // 21:00 in Riyadh
    final at23Riyadh = DateTime.utc(2026, 10, 26, 20, 1); // 23:01 in Riyadh
    final at14Riyadh = DateTime.utc(2026, 10, 26, 11, 0); // 14:00 in Riyadh

    test('Housing supervisor is locked out when Riyadh time >= housing lockout hour', () {
      expect(
        () => ScopeGuard.guardHousingRecord(
          actor: housingSup, scope: scope, housingId: 'main_campus',
          date: '2026-10-26', todayBusinessDate: '2026-10-26', nowUtc: at21Riyadh, lockoutHour: 20,
        ),
        throwsA(isA<OperationException>().having((e) => e.failure, 'failure', isA<DayLockedOut>())),
      );
    });

    test('Site supervisor is locked out when Riyadh time >= site lockout hour', () {
      expect(
        () => ScopeGuard.guardSiteRecord(
          actor: siteSup, scope: scope, teamId: 't1',
          date: '2026-10-26', todayBusinessDate: '2026-10-26', nowUtc: at23Riyadh, lockoutHour: 23,
        ),
        throwsA(isA<OperationException>().having((e) => e.failure, 'failure', isA<DayLockedOut>())),
      );
    });

    test('Site supervisor before lockout hour succeeds', () {
      expect(
        () => ScopeGuard.guardSiteRecord(
          actor: siteSup, scope: scope, teamId: 't1',
          date: '2026-10-26', todayBusinessDate: '2026-10-26', nowUtc: at14Riyadh, lockoutHour: 23,
        ),
        returnsNormally,
      );
    });

    test('Admin roles (PM & HR) are exempted from lockout in ScopeDateGuard', () {
      expect(
        () => ScopeDateGuard.guardLockout(
          role: AuthRole.projectManager, date: '2026-10-26', todayBusinessDate: '2026-10-26',
          nowUtc: at23Riyadh, lockoutHour: 23,
        ),
        returnsNormally,
      );
      expect(
        () => ScopeDateGuard.guardLockout(
          role: AuthRole.hr, date: '2026-10-26', todayBusinessDate: '2026-10-26',
          nowUtc: at23Riyadh, lockoutHour: 23,
        ),
        returnsNormally,
      );
    });

    test('DayLockedOut failure maps to localized actionable message', () {
      final arMsg = OperationFailureMessage.of(const DayLockedOut(), true);
      final enMsg = OperationFailureMessage.of(const DayLockedOut(), false);
      expect(arMsg, contains(OperationsStrings.dayLockedOut(true)));
      expect(enMsg, contains(OperationsStrings.dayLockedOut(false)));
    });
  });
}
