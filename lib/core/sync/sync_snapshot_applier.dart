import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/core/time/clock.dart';

final class SyncSnapshotApplier {
  const SyncSnapshotApplier({
    required this.database,
    this.clock = const SystemClock(),
  });

  final AppDatabase database;
  final Clock clock;

  Future<void> apply(RemoteRosterSnapshot snapshot, {required bool epochChanged}) async {
    await database.transaction(() async {
      if (epochChanged) {
        await database.update(database.employees).write(
              EmployeesCompanion(
                archivedAt: Value(clock.nowUtc()),
                currentTeamId: const Value(null),
              ),
            );
      }

      final existingRows = await database.select(database.employees).get();
      final byUid = {for (final e in existingRows) e.employeeUid: e};

      for (final remote in snapshot.employees) {
        final local = byUid[remote.employeeUid];
        final iqama = remote.employeeUid;
        final isRental = remote.supplier != null && remote.supplier!.isNotEmpty;
        if (local == null) {
          await database.into(database.employees).insert(
                EmployeesCompanion.insert(
                  iqamaNo: iqama,
                  fullNameAr: remote.fullNameAr,
                  fullNameEn: Value(remote.fullNameEn),
                  jobTitle: Value(remote.category),
                  jobCategory: Value(remote.category),
                  employmentType: Value(isRental ? 'rental' : 'company'),
                  rentalCompany: Value(remote.supplier),
                  currentTeamId: Value(remote.currentTeamId),
                  archivedAt: Value(remote.isActive ? null : clock.nowUtc()),
                  rowVersion: Value(remote.rowVersion),
                ),
              );
        } else if (remote.rowVersion >= local.rowVersion) {
          await (database.update(database.employees)..where((e) => e.iqamaNo.equals(iqama)))
              .write(
            EmployeesCompanion(
              fullNameAr: Value(remote.fullNameAr),
              fullNameEn: Value(remote.fullNameEn),
              jobTitle: Value(remote.category),
              rentalCompany: Value(remote.supplier),
              employmentType: Value(isRental ? 'rental' : 'company'),
              currentTeamId: Value(remote.currentTeamId),
              archivedAt: Value(remote.isActive ? null : clock.nowUtc()),
              rowVersion: Value(remote.rowVersion),
            ),
          );
        }
      }

      await database.into(database.settings).insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: AppSettingKeys.rosterEpoch,
              value: snapshot.rosterEpoch.toString(),
            ),
          );
    });
  }
}
