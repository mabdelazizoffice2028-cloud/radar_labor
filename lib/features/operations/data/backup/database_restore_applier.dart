import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/features/operations/data/backup/database_backup_models.dart';

abstract final class DatabaseRestoreApplier {
  static Future<void> apply(AppDatabase db, ValidatedBackupData data) =>
      db.transaction(() async {
        // Clear existing tables in reverse dependency order
        await db.delete(db.events).go();
        await db.delete(db.userScopes).go();
        await db.delete(db.appUsers).go();
        await db.delete(db.employees).go();
        await db.delete(db.teams).go();
        await db.delete(db.settings).go();

        // Populate in dependency order
        for (final s in data.settings) {
          await db.into(db.settings).insert(s);
        }
        for (final t in data.teams) {
          await db.into(db.teams).insert(t);
        }
        for (final e in data.employees) {
          await db.into(db.employees).insert(e);
        }
        for (final u in data.appUsers) {
          await db.into(db.appUsers).insert(u);
        }
        for (final sc in data.userScopes) {
          await db.into(db.userScopes).insert(sc);
        }
        var maxSeq = 0;
        for (final ev in data.events) {
          await db.into(db.events).insert(ev);
          final seq = ev.deviceSeq.value;
          if (seq > maxSeq) maxSeq = seq;
        }
        if (maxSeq > 0) {
          final existingSeqRow = await (db.select(db.settings)
                ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
              .getSingleOrNull();
          final currentSeq = int.tryParse(existingSeqRow?.value ?? '0') ?? 0;
          if (maxSeq > currentSeq) {
            await db.into(db.settings).insertOnConflictUpdate(
                  SettingsCompanion.insert(
                    key: AppSettingKeys.deviceSequence,
                    value: maxSeq.toString(),
                  ),
                );
          }
        }
      });
}
