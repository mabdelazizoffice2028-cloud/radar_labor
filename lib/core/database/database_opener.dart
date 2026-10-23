import 'dart:io';

import 'package:drift/native.dart';
// Drift 2.35 reports background setup errors through this wrapper; unwrapping
// it here preserves the app's typed database failure at the startup boundary.
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/database_encryption.dart';
import 'package:radar_labor/core/database/database_open_exception.dart';

/// Opens the encrypted database at [file] on a background isolate.
///
/// The file location is injected: resolving the app directory needs
/// path_provider, which is not in PRD §2 (see docs/DECISIONS.md).
Future<AppDatabase> openEncryptedDatabase(File file, String hexKey) async {
  final database = AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (rawDatabase) => applyEncryption(rawDatabase, hexKey),
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
