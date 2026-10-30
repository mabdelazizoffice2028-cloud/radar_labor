import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/database_open_exception.dart';
import 'package:radar_labor/core/errors/failure.dart';
import 'package:sqlite3/sqlite3.dart';

final RegExp _hexOnly = RegExp(r'^[0-9a-fA-F]+$');

/// Decrypts encrypted SQLite database to plaintext for maximum performance.
void applyDecryptionOrOpen(Database rawDatabase, [String? hexKey]) {
  var isEncrypted = false;
  try {
    rawDatabase.select('SELECT count(*) FROM sqlite_master');
  } on SqliteException {
    isEncrypted = true;
  }

  if (isEncrypted) {
    if (hexKey == null || hexKey.isEmpty) {
      throw const DatabaseOpenException(EncryptionKeyRejected());
    }
    applyEncryption(rawDatabase, hexKey);
    // Decrypt database in place to plaintext SQLite
    rawDatabase.execute("PRAGMA rekey = ''");
  }
}

/// Applies encryption key to raw database and verifies key validity.
void applyEncryption(Database rawDatabase, String hexKey) {
  final expectedHexLength = DatabaseConstants.keyByteLength * 2;
  if (hexKey.length != expectedHexLength || !_hexOnly.hasMatch(hexKey)) {
    throw ArgumentError.value(
      hexKey.length,
      'hexKey',
      'must contain $expectedHexLength hexadecimal characters',
    );
  }
  if (rawDatabase.select('PRAGMA cipher').isEmpty) {
    throw const DatabaseOpenException(EncryptionUnavailable());
  }
  rawDatabase.execute("PRAGMA key = '$hexKey'");
  try {
    rawDatabase.select('SELECT count(*) FROM sqlite_master');
  } on SqliteException {
    throw const DatabaseOpenException(EncryptionKeyRejected());
  }
}
