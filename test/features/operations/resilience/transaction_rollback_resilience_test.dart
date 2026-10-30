import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 4, 20, 8);
}

void main() {
  test('Transaction rollback resilience: mid-transaction failure leaves zero orphaned events', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final clock = _Clock();
    final events = EventRepository(database: db, deviceId: 'dev-1', clock: clock);

    // Initial event count is zero
    final initialEvents = await events.readBusinessDate('2026-04-20');
    expect(initialEvents, isEmpty);

    // Simulate an atomic transaction where a failure occurs mid-stream
    expect(
      () => db.transaction(() async {
        await events.append(EventDraft(
          type: EventType.sitePresent, action: EventAction.set,
          businessDate: '2026-04-20', employeeUid: 'w1', teamId: 'team-a',
        ));

        // Simulated crash/unhandled exception mid-transaction:
        throw StateError('Simulated unexpected power-off / network crash');
      }),
      throwsA(isA<StateError>()),
    );

    // Verify atomic rollback: zero partial records or orphaned events remain!
    final afterFailureEvents = await events.readBusinessDate('2026-04-20');
    expect(afterFailureEvents, isEmpty);

    // Subsequent valid transaction succeeds cleanly without corruption
    await events.append(const EventDraft(
      type: EventType.sitePresent, action: EventAction.set,
      businessDate: '2026-04-20', employeeUid: 'w2', teamId: 'team-a',
    ));

    final finalEvents = await events.readBusinessDate('2026-04-20');
    expect(finalEvents.length, 1);
    expect(finalEvents.single.employeeUid, 'w2');

    await db.close();
  });
}
