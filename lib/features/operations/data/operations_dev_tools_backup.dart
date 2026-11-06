import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

abstract final class OperationsDevToolsBackup {
  static String formatFileName(DateTime time) {
    final y = time.year.toString().padLeft(4, '0');
    final m = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return 'backup_test_data_$y-$m-${d}_$h-$min-$s.json';
  }

  static Future<Directory> resolveDir(Directory? dir) async {
    if (dir != null) return dir;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return Directory.systemTemp;
    }
    try {
      return await getApplicationDocumentsDirectory();
    } on MissingPluginException catch (e) {
      debugPrint('Path provider unavailable: $e');
      return Directory.systemTemp;
    } on Exception catch (e) {
      debugPrint('Failed to get documents dir: $e');
      return Directory.systemTemp;
    }
  }
}
