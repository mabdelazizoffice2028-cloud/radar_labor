import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Migrates pre-v4 JSON accounts stored in settings to app_users.
Future<void> migrateLegacyJsonAccounts(AppDatabase db) async {
  try {
    final row = await (db.select(
      db.settings,
    )..where((s) => s.key.equals('local_accounts_v1'))).getSingleOrNull();
    if (row == null || row.value.isEmpty) return;

    final decoded = jsonDecode(row.value) as List<Object?>;
    const uuid = Uuid();
    final baseDate = DateTime.utc(2026, 10, 23);

    for (final item in decoded) {
      if (item is! Map<String, Object?>) continue;
      final id = item['id'] as String? ?? uuid.v4();
      await db.into(db.appUsers).insert(
        AppUsersCompanion.insert(
          id: id,
          employeeUid: Value(item['employeeUid'] as String?),
          displayName: item['displayName'] as String? ?? 'User',
          role: item['role'] as String? ?? 'viewer',
          pwHash: item['passwordHash'] as String? ?? '',
          pwSalt: item['salt'] as String? ?? '',
          kdfParams: '{"m":19456,"t":2,"p":1}',
          mustChange: Value(item['mustChangePassword'] as bool? ?? true),
          failedAttempts: const Value(0),
          createdAt: baseDate,
        ),
        mode: InsertMode.insertOrReplace,
      );
      final teamIds = (item['teamIds'] as List<Object?>?) ?? const [];
      for (final tid in teamIds) {
        await db.into(db.userScopes).insert(
          UserScopesCompanion.insert(
            id: uuid.v4(),
            userId: id,
            scopeType: 'team',
            scopeId: tid.toString(),
          ),
        );
      }
      final housingIds = (item['housingIds'] as List<Object?>?) ?? const [];
      for (final hid in housingIds) {
        await db.into(db.userScopes).insert(
          UserScopesCompanion.insert(
            id: uuid.v4(),
            userId: id,
            scopeType: 'housing',
            scopeId: hid.toString(),
          ),
        );
      }
    }
    await (db.delete(db.settings)
          ..where((s) => s.key.equals('local_accounts_v1')))
        .go();
  } on Object catch (error) {
    debugPrint('Legacy accounts migration skipped (${error.runtimeType}).');
  }
}
