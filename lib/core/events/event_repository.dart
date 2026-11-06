// ignore_for_file: prefer_initializing_formals

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/events/event_domain_mapper.dart';
import 'package:radar_labor/core/events/event_draft.dart';
import 'package:radar_labor/core/events/event_draft_validator.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:uuid/uuid.dart';

export 'package:radar_labor/core/events/event_draft.dart';

final class EventRepository {
  EventRepository({
    required AppDatabase database,
    required String deviceId,
    required Clock clock,
    int cutoffHour = 3,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _deviceId = deviceId,
       _clock = clock,
       _cutoffHour = cutoffHour,
       _uuid = uuid;

  final AppDatabase _database;
  final String _deviceId;
  final Clock _clock;
  final int _cutoffHour;
  final Uuid _uuid;

  Future<LocalEvent> append(EventDraft draft) async => (await appendBatch([draft])).single;

  Future<List<LocalEvent>> appendBatch(List<EventDraft> drafts) async {
    if (drafts.isEmpty) return const [];
    for (final draft in drafts) {
      EventDraftValidator.validate(draft);
    }
    final now = _clock.nowUtc().toUtc();
    final isLate = [for (final d in drafts) d.businessDate != businessDateFor(now, cutoffHour: _cutoffHour)];

    return _database.transaction(() async {
      final sequenceRow = await (_database.select(_database.settings)
            ..where((s) => s.key.equals(AppSettingKeys.deviceSequence)))
          .getSingleOrNull();
      final prevSeq = sequenceRow == null ? 0 : int.tryParse(sequenceRow.value);
      if (prevSeq == null) throw StateError('The local event sequence is corrupted.');
      final result = <LocalEvent>[];
      for (var index = 0; index < drafts.length; index++) {
        final draft = drafts[index];
        final eventId = _uuid.v7();
        final deviceSeq = prevSeq + index + 1;
        final event = LocalEvent(
          eventId: eventId,
          deviceSeq: deviceSeq,
          type: draft.type,
          action: draft.action,
          businessDate: draft.businessDate,
          employeeUid: draft.employeeUid,
          teamId: draft.teamId,
          housingId: draft.housingId,
          userId: draft.userId,
          deviceTimeUtc: now,
          isLate: isLate[index],
          resolutionKind: ResolutionKind.fromKey(draft.payload['kind']),
          employmentType: draft.payload['employmentType'] as String?,
          jobCategory: draft.payload['jobCategory'] as String?,
        );
        await _database.into(_database.events).insert(EventsCompanion.insert(
          eventId: eventId, deviceId: _deviceId, deviceSeq: deviceSeq,
          type: draft.type.name, action: draft.action.name, businessDate: draft.businessDate,
          employeeUid: Value(draft.employeeUid), teamId: Value(draft.teamId),
          housingId: Value(draft.housingId), userId: Value(draft.userId),
          payload: Value(jsonEncode(draft.payload)), deviceTime: now,
          receivedAt: const Value(null), late: Value(isLate[index]),
          eventSchemaVersion: const Value(1), syncStatus: const Value('pending'),
        ));
        result.add(event);
      }
      await _database.into(_database.settings).insertOnConflictUpdate(SettingsCompanion.insert(
        key: AppSettingKeys.deviceSequence, value: (prevSeq + drafts.length).toString(),
      ));
      return List.unmodifiable(result);
    });
  }

  Stream<List<LocalEvent>> watchAll() => _database.select(_database.events).watch().map((r) => List.unmodifiable(r.map(EventDomainMapper.toDomain)));

  Future<List<LocalEvent>> readBusinessDate(String date) async {
    final rows = await (_database.select(_database.events)..where((e) => e.businessDate.equals(date))..orderBy([(e) => OrderingTerm.asc(e.deviceSeq)])).get();
    return List.unmodifiable(rows.map(EventDomainMapper.toDomain));
  }

  Future<List<LocalEvent>> readBusinessDateRange({required String fromDate, required String toDate}) async {
    final rows = await (_database.select(_database.events)..where((e) => e.businessDate.isBiggerOrEqualValue(fromDate) & e.businessDate.isSmallerOrEqualValue(toDate))..orderBy([(e) => OrderingTerm.asc(e.deviceSeq)])).get();
    return List.unmodifiable(rows.map(EventDomainMapper.toDomain));
  }

  Stream<List<LocalEvent>> watchBusinessDate(String date) => (_database.select(_database.events)..where((e) => e.businessDate.equals(date))..orderBy([(e) => OrderingTerm.asc(e.deviceSeq)])).watch().map((r) => List.unmodifiable(r.map(EventDomainMapper.toDomain)));
}
