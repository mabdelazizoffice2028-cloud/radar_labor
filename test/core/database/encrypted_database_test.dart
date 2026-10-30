import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/database_encryption.dart';
import 'package:radar_labor/core/database/database_open_exception.dart';
import 'package:radar_labor/core/database/database_opener.dart';
import 'package:sqlite3/sqlite3.dart';

const _keyA =
    'a1b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90';
const _keyB =
    '0f1e2d3c4b5a69788796a5b4c3d2e1f00f1e2d3c4b5a69788796a5b4c3d2e1f0';
const _plaintextProbe = 'plaintext_probe_value';

AppDatabase _open(File file, String key) => AppDatabase(
  NativeDatabase(file, setup: (raw) => applyDecryptionOrOpen(raw, key)),
);

Future<AppDatabase> _openInBackground(File file, String key) =>
    openEncryptedDatabase(file, key);

void main() {
  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('radar_labor_db_');
    file = File('${directory.path}/${DatabaseConstants.fileName}');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('cipherPragma_isNotEmpty_whenSqlite3mcIsActive', () {
    final raw = sqlite3.openInMemory();
    addTearDown(raw.close);
    expect(raw.select('PRAGMA cipher'), isNotEmpty);
  });

  test('encryption_rejectsKeysWithWrongLengthOrCharacters', () {
    final raw = sqlite3.openInMemory();
    addTearDown(raw.close);

    final nonHexKey = List<String>.filled(
      DatabaseConstants.keyByteLength * 2,
      'g',
    ).join();
    final longKey = List<String>.filled(
      DatabaseConstants.keyByteLength * 2 + 1,
      'a',
    ).join();

    expect(() => applyEncryption(raw, nonHexKey), throwsArgumentError);
    expect(() => applyEncryption(raw, longKey), throwsArgumentError);
  });

  test('schemaVersion_isSix_onFreshDatabase', () async {
    final db = _open(file, _keyA);
    addTearDown(db.close);
    final row = await db.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), DatabaseConstants.schemaVersion);
  });

  test('backgroundOpener_migratesFreshDatabase', () async {
    final db = await _openInBackground(file, _keyA);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    final settingsTable = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'settings'",
        )
        .get();
    final eventTable = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'events'",
        )
        .get();

    expect(version.read<int>('user_version'), DatabaseConstants.schemaVersion);
    expect(settingsTable, hasLength(1));
    expect(eventTable, hasLength(1));
  });

  test('v1Database_migratesToV6AndPreservesSettings', () async {
    final raw = sqlite3.open(file.path);
    applyEncryption(raw, _keyA);
    raw.execute(
      'CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
    );
    raw.execute("INSERT INTO settings (key, value) VALUES ('language', 'ar')");
    raw.execute('PRAGMA user_version = 1');
    raw.close();

    final db = await _openInBackground(file, _keyA);
    addTearDown(db.close);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    final setting = await db.select(db.settings).getSingle();
    final eventsTable = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'events'",
        )
        .get();

    expect(version.read<int>('user_version'), DatabaseConstants.schemaVersion);
    expect(setting.value, 'ar');
    expect(eventsTable, hasLength(1));
  });

  test('v2Database_migratesEmployeesToV6Iqama', () async {
    final raw = sqlite3.open(file.path);
    applyEncryption(raw, _keyA);
    raw.execute('''CREATE TABLE employees (
      employee_uid TEXT NOT NULL PRIMARY KEY,
      employee_code TEXT NOT NULL,
      full_name_ar TEXT NOT NULL,
      full_name_en TEXT NULL,
      category TEXT NOT NULL,
      current_team_id TEXT NULL,
      housing_id TEXT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      row_version INTEGER NOT NULL DEFAULT 1
    )''');
    raw.execute(
      'CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
    );
    raw.execute(
      "INSERT INTO employees (employee_uid, employee_code, full_name_ar, category) VALUES ('e-1', '1', 'Test', 'Worker')",
    );
    raw.execute('PRAGMA user_version = 2');
    raw.close();

    final db = await _openInBackground(file, _keyA);
    addTearDown(db.close);
    final employee = await db.select(db.employees).getSingle();
    expect(employee.iqamaNo, '0000000001');
    expect(employee.rentalCompany, isNull);
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      DatabaseConstants.schemaVersion,
    );
  });

  test('encryptedDatabase_isDecryptedOnOpen_andReadableWithoutKey', () async {
    final raw = sqlite3.open(file.path);
    applyEncryption(raw, _keyA);
    raw.execute('CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
    raw.execute("INSERT INTO settings (key, value) VALUES ('probe', '$_plaintextProbe')");
    raw.close();

    final db = await _openInBackground(file, _keyA);
    await db.close();

    // Now open directly via raw sqlite3 without any encryption key
    final unencryptedRaw = sqlite3.open(file.path);
    final res = unencryptedRaw.select("SELECT value FROM settings WHERE key = 'probe'");
    expect(res.single['value'], _plaintextProbe);
    unencryptedRaw.close();
  });

  test('openWithWrongKey_throwsOpenException', () async {
    final raw = sqlite3.open(file.path);
    applyEncryption(raw, _keyA);
    raw.execute('CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
    raw.execute("INSERT INTO settings (key, value) VALUES ('k', 'v')");
    raw.close();

    final wrong = _open(file, _keyB);
    addTearDown(wrong.close);
    await expectLater(
      wrong.select(wrong.settings).get(),
      throwsA(isA<DatabaseOpenException>()),
    );
  });

  test('backgroundOpener_preservesTypedFailureForWrongKey', () async {
    final raw = sqlite3.open(file.path);
    applyEncryption(raw, _keyA);
    raw.execute('CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
    raw.execute("INSERT INTO settings (key, value) VALUES ('k', 'v')");
    raw.close();

    await expectLater(
      _openInBackground(file, _keyB),
      throwsA(isA<DatabaseOpenException>()),
    );
  });
}
