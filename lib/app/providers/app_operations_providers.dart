import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/providers/app_core_providers.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';
import 'package:radar_labor/features/operations/data/history_repository.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';
import 'package:radar_labor/features/operations/data/settings_attendance_draft_store.dart';
import 'package:radar_labor/features/operations/data/settings_housing_draft_store.dart';
import 'package:radar_labor/features/operations/data/site_attendance_repository.dart';
import 'package:radar_labor/features/operations/data/team_setup_repository.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/housing_draft_store.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/domain/team_setup_store.dart';

final statusSnapshotRepositoryProvider = Provider<StatusSnapshotRepository>((ref) =>
    StatusSnapshotRepository(database: ref.watch(appDatabaseProvider), events: ref.watch(eventRepositoryProvider), clock: ref.watch(clockProvider)));

final dashboardCoverageRepositoryProvider = Provider<DashboardCoverageRepository>((ref) =>
    DashboardCoverageRepository(database: ref.watch(appDatabaseProvider), events: ref.watch(eventRepositoryProvider)));

final dashboardActionsRepositoryProvider = Provider<DashboardActionsRepository>((ref) =>
    DashboardActionsRepository(ref.watch(eventRepositoryProvider)));

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) =>
    OperationsRepository(database: ref.watch(appDatabaseProvider), events: ref.watch(eventRepositoryProvider)));

final teamSetupStoreProvider = Provider<TeamSetupStore>((ref) =>
    TeamSetupRepository(database: ref.watch(appDatabaseProvider)));

final attendanceDraftStoreProvider = Provider<AttendanceDraftStore>((ref) =>
    SettingsAttendanceDraftStore(settings: ref.watch(settingsRepositoryProvider), clock: ref.watch(clockProvider)));

final housingDraftStoreProvider = Provider<HousingDraftStore>((ref) =>
    SettingsHousingDraftStore(settings: ref.watch(settingsRepositoryProvider), clock: ref.watch(clockProvider)));

final housingLockoutHourProvider = FutureProvider<int>((ref) async {
  final s = ref.watch(settingsRepositoryProvider);
  final v = await s.read(AppSettingKeys.housingLockoutHour);
  return int.tryParse(v ?? '20') ?? 20;
});

final siteAttendanceStoreProvider = Provider<SiteAttendanceStore>((ref) =>
    SiteAttendanceRepository(
      database: ref.watch(appDatabaseProvider),
      events: ref.watch(eventRepositoryProvider),
      draftStore: ref.watch(attendanceDraftStoreProvider),
      clock: ref.watch(clockProvider),
    ));

final historyStoreProvider = Provider<HistoryStore>((ref) =>
    HistoryRepository(database: ref.watch(appDatabaseProvider), events: ref.watch(eventRepositoryProvider), clock: ref.watch(clockProvider)));
