// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:uuid/uuid.dart';

final class EventDraft {
  const EventDraft({
    required this.type,
    required this.action,
    required this.businessDate,
    this.employeeUid,
    this.teamId,
    this.housingId,
    this.userId,
    this.payload = const {},
  });

  final EventType type;
  final EventAction action;
  final String businessDate;
  final String? employeeUid;
  final String? teamId;
  final String? housingId;
  final String? userId;
  final Map<String, Object?> payload;
}

/// The sole write path for immutable daily status events.
final class EventRepository {
  EventRepository({
    required AppDatabase database,
    required String deviceId,
    required Clock clock,
    this._cutoffHour = 3,
    this._uuid = const Uuid(),
  }) : _database = database,
       _deviceId = deviceId,
       _clock = clock;

  final AppDatabase _database;
  final String _deviceId;
  final Clock _clock;
  final int _cutoffHour;
  final Uuid _uuid;

  Future<LocalEvent> append(EventDraft draft) async {
    return (await appendBatch([draft])).single;
  }

  /// Appends a related group of immutable events and sequence numbers atomically.
  Future<List<LocalEvent>> appendBatch(List<EventDraft> drafts) async {
    if (drafts.isEmpty) return const [];
    for (final draft in drafts) {
      _validateDraft(draft);
    }
    final now = _clock.nowUtc().toUtc();
    final isLate = <bool>[
      for (final draft in drafts)
        draft.businessDate != businessDateFor(now, cutoffHour: _cutoffHour),
    ];

    return _database.transaction(() async {
      final sequenceRow =
          await (_database.select(_database.settings)..where(
                (setting) => setting.key.equals(AppSettingKeys.deviceSequence),
              ))
              .getSingleOrNull();
      final previousSequence = sequenceRow == null
          ? 0
          : int.tryParse(sequenceRow.value);
      if (previousSequence == null) {
        throw StateError('The local event sequence is corrupted.');
      }
      final result = <LocalEvent>[];
      for (var index = 0; index < drafts.length; index++) {
        final draft = drafts[index];
        final eventId = _uuid.v7();
        final deviceSeq = previousSequence + index + 1;
        final event = LocalEvent(
          eventId: eventId,
          deviceSeq: deviceSeq,
          type: draft.type,
          action: draft.action,
          businessDate: draft.businessDate,
          employeeUid: draft.employeeUid,
          teamId: draft.teamId,
          housingId: draft.housingId,
          deviceTimeUtc: now,
          isLate: isLate[index],
        );
        await _database
            .into(_database.events)
            .insert(
              EventsCompanion.insert(
                eventId: eventId,
                deviceId: _deviceId,
                deviceSeq: deviceSeq,
                type: draft.type.name,
                action: draft.action.name,
                businessDate: draft.businessDate,
                employeeUid: Value(draft.employeeUid),
                teamId: Value(draft.teamId),
                housingId: Value(draft.housingId),
                userId: Value(draft.userId),
                payload: Value(jsonEncode(draft.payload)),
                deviceTime: now,
                receivedAt: const Value(null),
                late: Value(isLate[index]),
                eventSchemaVersion: const Value(1),
                syncStatus: const Value('pending'),
              ),
            );
        result.add(event);
      }
      await _database
          .into(_database.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: AppSettingKeys.deviceSequence,
              value: (previousSequence + drafts.length).toString(),
            ),
          );
      return List.unmodifiable(result);
    });
  }

  /// Watches the append-only local event ledger across business dates.
  Stream<List<LocalEvent>> watchAll() => _database
      .select(_database.events)
      .watch()
      .map((rows) => List.unmodifiable(rows.map(_toDomain)));

  Future<List<LocalEvent>> readBusinessDate(String businessDate) async {
    final rows =
        await (_database.select(_database.events)
              ..where((event) => event.businessDate.equals(businessDate))
              ..orderBy([(event) => OrderingTerm.asc(event.deviceSeq)]))
            .get();
    return List.unmodifiable(rows.map(_toDomain));
  }

  Stream<List<LocalEvent>> watchBusinessDate(String businessDate) =>
      (_database.select(_database.events)
            ..where((event) => event.businessDate.equals(businessDate))
            ..orderBy([(event) => OrderingTerm.asc(event.deviceSeq)]))
          .watch()
          .map((rows) => List.unmodifiable(rows.map(_toDomain)));

  LocalEvent _toDomain(Event row) => LocalEvent(
    eventId: row.eventId,
    deviceSeq: row.deviceSeq,
    type: EventType.values.byName(row.type),
    action: EventAction.values.byName(row.action),
    businessDate: row.businessDate,
    employeeUid: row.employeeUid,
    teamId: row.teamId,
    housingId: row.housingId,
    receivedAtUtc: row.receivedAt?.toUtc(),
    deviceTimeUtc: row.deviceTime.toUtc(),
    delivery: EventDelivery.values.byName(row.syncStatus),
    isLate: row.late,
  );

  void _validateDraft(EventDraft draft) {
    if (!_isValidDate(draft.businessDate)) {
      throw ArgumentError.value(
        draft.businessDate,
        'businessDate',
        'must be a real YYYY-MM-DD date',
      );
    }

    final isValid = switch (draft.type) {
      EventType.housingCheck =>
        draft.housingId != null && draft.housingId!.isNotEmpty,
      EventType.housingAbsent =>
        draft.employeeUid != null && draft.housingId != null,
      EventType.sitePresent =>
        draft.employeeUid != null && draft.teamId != null,
      EventType.siteSubmitted => draft.teamId != null,
      EventType.justification ||
      EventType.resolution => draft.employeeUid != null,
    };
    if (!isValid) {
      throw ArgumentError.value(
        draft.type,
        'type',
        'does not contain the required employee, team, or housing key',
      );
    }
  }

  bool _isValidDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }
}
