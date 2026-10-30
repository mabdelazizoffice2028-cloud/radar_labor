import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_load_ops.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_roster_ops.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_save_ops.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';
import 'package:radar_labor/features/operations/presentation/state/site_draft_persistence.dart';

export 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart'
    show scopedSiteTeamsProvider;

/// Controller for smart daily site attendance (PRD §8, §9, §10).
final class SiteAttendanceNotifier extends Notifier<SiteAttendanceState>
    with
        SiteDraftPersistence,
        SiteAttendanceLoadOps,
        SiteAttendanceRosterOps,
        SiteAttendanceSaveOps {
  ActorContext? _overrideActor;
  ScopeSnapshot? _overrideScope;

  @override
  SiteAttendanceState build() {
    ref.onDispose(() => draftTimer?.cancel());
    final today = store.currentBusinessDate();
    return SiteAttendanceState(selectedDate: today, todayDate: today);
  }

  @override
  SiteAttendanceStore get store => ref.read(siteAttendanceStoreProvider);
  @override
  bool get isArabic => ref.read(appLocaleProvider) == 'ar';

  void setOverrideContext({ActorContext? actor, ScopeSnapshot? scope}) =>
      (_overrideActor = actor, _overrideScope = scope);

  @override
  ({ActorContext actor, ScopeSnapshot scope})? actorAndScope() {
    if (_overrideActor != null && _overrideScope != null) {
      return (actor: _overrideActor!, scope: _overrideScope!);
    }
    final s = ref.read(currentSessionProvider);
    if (s == null) return null;
    final scope =
        ref.read(userScopesProvider(s.id)).value ??
        ScopeSnapshot(
          teamIds: s.teamIds.toSet(),
          housingIds: s.housingIds.toSet(),
        );
    return (actor: ActorContext(userId: s.id, role: s.role), scope: scope);
  }

  @override
  void setFailure(Exception e) {
    if (e is! OperationException) {
      debugPrint('Site save/load: ${e.runtimeType}');
    }
    final failure = e is OperationException ? e.failure : const SaveFailed();
    state = state.copyWith(
      isLoading: false,
      isSaving: false,
      errorMessage: OperationFailureMessage.of(failure, isArabic),
    );
  }
}

final siteAttendanceNotifierProvider =
    NotifierProvider<SiteAttendanceNotifier, SiteAttendanceState>(
      SiteAttendanceNotifier.new,
    );
