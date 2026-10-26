import 'dart:convert';

import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/database/local_settings_repository.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/domain/housing_draft_store.dart';

/// Stores automatic 3-state housing check drafts in [LocalSettingsRepository].
final class SettingsHousingDraftStore implements HousingDraftStore {
  const SettingsHousingDraftStore({
    required this.settings,
    required this.clock,
    this.onCorruptedDraftType,
  });

  final LocalSettingsRepository settings;
  final Clock clock;
  final void Function(Type errorType)? onCorruptedDraftType;

  @override
  Future<HousingDraftData?> readDraft({
    required String housingId,
    required String date,
  }) async {
    final key = AppSettingKeys.draftHousingCheck(housingId, date);
    final raw = await settings.read(key);
    if (raw == null) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Housing draft root is not a JSON object');
      }
      final version = decoded['v'];
      final reviewedRaw = decoded['reviewed'];
      final absentRaw = decoded['absent'];
      final updatedAtRaw = decoded['updatedAt'];

      if (version != 1 ||
          reviewedRaw is! List ||
          absentRaw is! List ||
          updatedAtRaw is! String) {
        throw const FormatException('Housing draft schema mismatch');
      }

      final reviewed = <String>[];
      for (final item in reviewedRaw) {
        if (item is String && item.isNotEmpty) reviewed.add(item);
      }
      final absent = <String>[];
      for (final item in absentRaw) {
        if (item is String && item.isNotEmpty) absent.add(item);
      }

      final updatedAt = DateTime.parse(updatedAtRaw).toUtc();
      return HousingDraftData(
        reviewedWorkerIds: List.unmodifiable(reviewed),
        absentWorkerIds: List.unmodifiable(absent),
        updatedAtUtc: updatedAt,
      );
    } on Exception catch (error) {
      onCorruptedDraftType?.call(error.runtimeType);
      await settings.delete(key);
      return null;
    }
  }

  @override
  Future<void> writeDraft({
    required String housingId,
    required String date,
    required Iterable<String> reviewedWorkerIds,
    required Iterable<String> absentWorkerIds,
  }) async {
    final key = AppSettingKeys.draftHousingCheck(housingId, date);
    final payload = jsonEncode({
      'v': 1,
      'reviewed': reviewedWorkerIds.toList(growable: false),
      'absent': absentWorkerIds.toList(growable: false),
      'updatedAt': clock.nowUtc().toUtc().toIso8601String(),
    });
    await settings.write(key, payload);
  }

  @override
  Future<void> deleteDraft({required String housingId, required String date}) =>
      settings.delete(AppSettingKeys.draftHousingCheck(housingId, date));
}
