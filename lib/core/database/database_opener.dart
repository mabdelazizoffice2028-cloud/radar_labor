import 'dart:io';
import 'package:drift/native.dart';
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/database_encryption.dart';
import 'package:radar_labor/core/database/database_open_exception.dart';

/// Opens SQLite database in background isolate, decrypting it if encrypted.
Future<AppDatabase> openEncryptedDatabase(File file, String hexKey) async {
  final database = AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (rawDatabase) => applyDecryptionOrOpen(rawDatabase, hexKey),
    ),
  );

  try {
    await database.select(database.settings).get();
    return database;
  } on DriftRemoteException catch (error, stackTrace) {
    await database.close();
    final cause = error.remoteCause;
    if (cause is DatabaseOpenException) {
      Error.throwWithStackTrace(cause, error.remoteStackTrace ?? stackTrace);
    }
    rethrow;
  }
}
