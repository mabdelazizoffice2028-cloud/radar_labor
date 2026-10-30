import 'package:drift/drift.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/site_attendance_save_builder.dart';
import 'package:radar_labor/features/operations/domain/attendance_draft_store.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/domain/ledger_undo_plan.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:uuid/uuid.dart';

final class SiteAttendanceSaver {
  const SiteAttendanceSaver({
    required this.database, required this.events, required this.draftStore, required this.clock,
  });

  final AppDatabase database;
  final EventRepository events;
  final AttendanceDraftStore draftStore;
  final Clock clock;

  Future<({Set<String> finalSelectedIds, LedgerUndoPlan undoPlan, List<EventDraft> drafts})> executeSave({
    required ActorContext actor, required PreparedSiteSave prepared,
    required Map<String, ConflictResolutionChoice> resolutions,
  }) async {
    for (final c in prepared.conflicts) {
      if (!resolutions.containsKey(c.worker.id)) throw const OperationException(UnresolvedConflicts());
    }
    final activeRows = await (database.select(database.employees)..where((r) => r.archivedAt.isNull())).get();
    final activeIds = {for (final emp in activeRows) emp.employeeUid};

    final dayEvents = await events.readBusinessDate(prepared.date);
    final ledger = AttendanceLedger(dayEvents);
    final built = SiteAttendanceSaveBuilder.build(
      prepared: prepared, resolutions: resolutions, ledger: ledger, actorUserId: actor.userId,
    );
    final unavail = built.finalSelectedIds.difference(activeIds);
    if (unavail.isNotEmpty) throw OperationException(WorkersUnavailable(unavail));

    final absentInHousing = ledger.absentWorkerIdsForHousing(HousingConstants.defaultHousingId);
    final autoFixIds = built.finalSelectedIds.intersection(absentInHousing);
    final allDrafts = List<EventDraft>.from(built.drafts);
    for (final wid in autoFixIds) {
      allDrafts.add(EventDraft(
        type: EventType.housingAbsent, action: EventAction.clear, businessDate: prepared.date,
        housingId: HousingConstants.defaultHousingId, employeeUid: wid, userId: actor.userId,
      ));
    }

    await database.transaction(() async {
      await events.appendBatch(allDrafts);
      const uuid = Uuid();
      final now = clock.nowUtc();
      for (final wid in autoFixIds) {
        await database.into(database.workerHistory).insert(WorkerHistoryCompanion.insert(
          historyId: uuid.v4(), iqamaNo: wid, action: 'auto_fix_housing_absence_cleared',
          details: Value('Auto-fix: Cleared housing absence upon site attendance for ${prepared.date}'),
          userId: Value(actor.userId), createdAt: now,
        ));
      }
      await draftStore.deleteDraft(teamId: prepared.team.id, date: prepared.date);
    });
    return built;
  }

  Future<void> undo(LedgerUndoPlan plan, String actorUserId) async {
    if (plan.entries.isNotEmpty) {
      await events.appendBatch(SiteAttendanceSaveBuilder.buildUndoDrafts(plan: plan, actorUserId: actorUserId));
    }
  }
}
