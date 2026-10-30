import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/screens/preferences_dev_tool_card.dart';
import 'package:radar_labor/app/widgets/auth_language_button.dart';
import 'package:radar_labor/app/widgets/notification_badge.dart';
import 'package:radar_labor/app/widgets/notification_providers.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/features/dashboard/domain/dashboard_coverage_models.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await (db.select(db.employees)).get();
    await (db.select(db.events)).get();
    await (db.select(db.workerHistory)).get();
    await (db.select(db.auditLogs)).get();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrapWithScope(Widget child, {List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        remoteSyncGatewayProvider.overrideWithValue(const OfflineRemoteSyncGateway()),
        ...overrides.cast(),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('PreferencesDevToolCard shows dialog and cancels on Cancel', (tester) async {
    await tester.pumpWidget(wrapWithScope(PreferencesDevToolCard(database: db, arabic: true)));
    await tester.pumpAndSettle();

    expect(find.text('مسح بيانات التجارب'), findsOneWidget);
    await tester.tap(find.text('مسح بيانات التجارب'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد مسح البيانات'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد مسح البيانات'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('PreferencesDevToolCard executes clear on Confirm', (tester) async {
    await tester.pumpWidget(wrapWithScope(PreferencesDevToolCard(database: db, arabic: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مسح بيانات التجارب'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مسح البيانات'));
    await tester.pumpAndSettle();

    expect(find.text('تم مسح بيانات التجارب بنجاح'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('AuthLanguageButton switches locale on tap', (tester) async {
    await tester.pumpWidget(wrapWithScope(const AuthLanguageButton()));
    await tester.pumpAndSettle();

    expect(find.text('عربي'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('NotificationBadge opens NotificationsSheet on tap', (tester) async {
    await tester.pumpWidget(wrapWithScope(
      const NotificationBadge(arabic: true),
      overrides: [
        todayCoverageProvider.overrideWith((ref) => Stream.value(
          const DashboardCoverage(
            businessDate: '2026-10-30',
            missingTeams: [],
            missingHousings: [],
          ),
        )),
      ],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('مركز التنبيهات'), findsOneWidget);
    expect(find.text('الوضع المحلي'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
