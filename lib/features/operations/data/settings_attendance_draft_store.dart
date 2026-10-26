import 'dart:convert';

import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';

/// Stores automatic site attendance drafts inside [LocalSettingsRepository] (PRD §8.5).
final class SettingsAttendanceDraftStore implements AttendanceDraftStore {
  const SettingsAttendanceDraftStore({
    required this.settings,
    required this.clock,
    this.onCorruptedDraftType,
  });

  final LocalSettingsRepository settings;
  final Clock clock;
  final void Function(Type errorType)? onCorruptedDraftType;

  static final RegExp _dateSuffixPattern = RegExp(r'_(\d{4}-\d{2}-\d{2})$');

  @override
  Future<AttendanceDraftData?> readDraft({
    required String teamId,
    required String date,
  }) async {
    final key = AppSettingKeys.draftSiteAttendance(teamId, date);
    final raw = await settings.read(key);
    if (raw == null) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Draft root is not a JSON object');
      }
      final version = decoded['v'];
      final idsRaw = decoded['ids'];
      final updatedAtRaw = decoded['updatedAt'];
      if (version != 1 || idsRaw is! List || updatedAtRaw is! String) {
        throw const FormatException('Draft schema mismatch');
      }
      final ids = <String>[];
      for (final item in idsRaw) {
        if (item is! String || item.isEmpty) {
          throw const FormatException('Invalid worker UID in draft');
        }
        ids.add(item);
      }
      final updatedAt = DateTime.parse(updatedAtRaw).toUtc();
      return AttendanceDraftData(
        workerIds: List.unmodifiable(ids),
        updatedAtUtc: updatedAt,
      );
    } on Exception catch (error) {
      // PRD §8.5 & §13: Delete corrupted draft key silently and log only the error type.
      onCorruptedDraftType?.call(error.runtimeType);
      await settings.delete(key);
      return null;
    }
  }

  @override
  Future<void> writeDraft({
    required String teamId,
    required String date,
    required Iterable<String> workerIds,
  }) async {
    final key = AppSettingKeys.draftSiteAttendance(teamId, date);
    final payload = jsonEncode({
      'v': 1,
      'ids': workerIds.toList(growable: false),
      'updatedAt': clock.nowUtc().toUtc().toIso8601String(),
    });
    await settings.write(key, payload);
  }

  @override
  Future<void> deleteDraft({required String teamId, required String date}) =>
      settings.delete(AppSettingKeys.draftSiteAttendance(teamId, date));

  @override
  Future<void> cleanupExpiredDrafts({
    required String todayBusinessDate,
    int retentionDays = OperationsConstants.draftRetentionDays,
  }) async {
    final today = _parseIsoDate(todayBusinessDate);
    if (today == null) return;

    final allKeys = await settings.readKeys();
    for (final key in allKeys) {
      if (!key.startsWith(AppSettingKeys.draftSiteAttendancePrefix)) continue;
      final match = _dateSuffixPattern.firstMatch(key);
      if (match == null) {
        await settings.delete(key);
        continue;
      }
      final draftDate = _parseIsoDate(match.group(1)!);
      if (draftDate == null ||
          today.difference(draftDate).inDays > retentionDays) {
        await settings.delete(key);
      }
    }
  }

  DateTime? _parseIsoDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    final dt = DateTime.utc(y, m, d);
    if (dt.year != y || dt.month != m || dt.day != d) return null;
    return dt;
  }
}
