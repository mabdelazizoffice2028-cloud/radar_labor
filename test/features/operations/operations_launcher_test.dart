import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/presentation/housing_check_screen.dart';
import 'package:radar_labor/features/operations/presentation/operations_screen.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 26, 10, 0);
}

void main() {
  testWidgets(
    'OperationsScreen renders launcher card and navigates to HousingCheckScreen with Back button',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final clock = _FixedClock();
      final events = EventRepository(
        database: db,
        deviceId: 'dev-1',
        clock: clock,
      );
      final repo = OperationsRepository(database: db, events: events);

      final controller = OperationsController(
        store: repo,
        clock: clock,
        actorUserId: 'user-1',
        capabilities: AuthRole.housingSupervisor.capabilities,
        allowedHousingIds: const ['h-1'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            eventRepositoryProvider.overrideWithValue(events),
            operationsRepositoryProvider.overrideWithValue(repo),
            clockProvider.overrideWithValue(clock),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: OperationsScreen(
                controller: controller,
                arabic: false,
                role: AuthRole.housingSupervisor,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('launch_campus_check_card')),
        findsOneWidget,
      );
      expect(
        find.text(OperationsStrings.startCampusCheckAction(false)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('launch_campus_check_card')));
      await tester.pumpAndSettle();

      expect(find.byType(HousingCheckScreen), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(HousingCheckScreen), findsNothing);
      expect(find.byType(OperationsScreen), findsOneWidget);

      await db.close();
    },
  );
}
