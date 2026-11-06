import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/events/event_domain_mapper.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';

void main() {
  group('Senior Review Surgical Fixes', () {
    test('EventDomainMapper maps synced and acked to EventDelivery.acked', () {
      expect(EventDomainMapper.parseDelivery('synced'), EventDelivery.acked);
      expect(EventDomainMapper.parseDelivery('acked'), EventDelivery.acked);
      expect(EventDomainMapper.parseDelivery('rejected'), EventDelivery.rejected);
      expect(EventDomainMapper.parseDelivery('pending'), EventDelivery.pending);
    });

    test('isPastLockoutHour treats 00:00-02:59 Riyadh time as post-midnight of current business day', () {
      // 20:59 Riyadh (17:59 UTC) -> not locked out for 21:00 lockout
      expect(isPastLockoutHour(DateTime.utc(2026, 5, 10, 17, 59), 21), isFalse);
      // 21:00 Riyadh (18:00 UTC) -> locked out
      expect(isPastLockoutHour(DateTime.utc(2026, 5, 10, 18), 21), isTrue);
      // 01:00 Riyadh next calendar day (22:00 UTC) -> still same business day (effective hour 25 >= 21) -> locked out!
      expect(isPastLockoutHour(DateTime.utc(2026, 5, 10, 22), 21), isTrue);
    });

    test('ScopeGuard allows PM and HR to edit past days while blocking today', () {
      const pmActor = ActorContext(
        userId: 'pm-1',
        role: AuthRole.projectManager,
      );
      const scope = ScopeSnapshot(teamIds: {'team-1'}, housingIds: {'housing-1'});
      expect(
        () => ScopeGuard.guardSiteRecord(
          actor: pmActor,
          scope: scope,
          teamId: 'team-1',
          date: '2026-05-10',
          todayBusinessDate: '2026-05-10',
          nowUtc: DateTime.utc(2026, 5, 10, 8),
        ),
        throwsA(isA<OperationException>()),
      );
      expect(
        () => ScopeGuard.guardSiteRecord(
          actor: pmActor,
          scope: scope,
          teamId: 'team-1',
          date: '2026-05-09',
          todayBusinessDate: '2026-05-10',
          nowUtc: DateTime.utc(2026, 5, 10, 8),
        ),
        returnsNormally,
      );
    });

    test('SiteAttendanceState tracks hasLoadedDay to prevent empty-team infinite reload loop', () {
      const initial = SiteAttendanceState(
        selectedDate: '2026-05-10',
        todayDate: '2026-05-10',
      );
      expect(initial.hasLoadedDay, isFalse);
      final loadedEmpty = initial.copyWith(hasLoadedDay: true, isLoading: false);
      expect(loadedEmpty.hasLoadedDay, isTrue);
      expect(loadedEmpty.rows, isEmpty);
    });
  });
}
