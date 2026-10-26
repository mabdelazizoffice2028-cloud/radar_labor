import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/features/operations/domain/history_models.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

/// Immutable UI state for History (PRD §11).
final class HistoryState {
  const HistoryState({
    this.daysWindow = OperationsConstants.historyPageDays,
    this.isLoading = false,
    this.page,
    this.errorMessage,
  });

  final int daysWindow;
  final bool isLoading;
  final HistoryPage? page;
  final String? errorMessage;

  HistoryState copyWith({
    int? daysWindow,
    bool? isLoading,
    HistoryPage? page,
    String? errorMessage,
    bool clearError = false,
  }) => HistoryState(
    daysWindow: daysWindow ?? this.daysWindow,
    isLoading: isLoading ?? this.isLoading,
    page: page ?? this.page,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

/// Controller for paginated supervisor and admin history (PRD §11).
final class HistoryNotifier extends Notifier<HistoryState> {
  ActorContext? _overrideActor;
  ScopeSnapshot? _overrideScope;

  @override
  HistoryState build() => const HistoryState();

  void setOverrideContext({ActorContext? actor, ScopeSnapshot? scope}) {
    _overrideActor = actor;
    _overrideScope = scope;
  }

  bool get _isArabic => ref.read(appLocaleProvider) == 'ar';

  ({ActorContext actor, ScopeSnapshot scope})? _actorAndScope() {
    if (_overrideActor != null && _overrideScope != null) {
      return (actor: _overrideActor!, scope: _overrideScope!);
    }
    final s = ref.read(currentSessionProvider);
    if (s == null) return null;
    final actor = ActorContext(userId: s.id, role: s.role);
    final scope =
        ref.read(userScopesProvider(s.id)).value ??
        ScopeSnapshot(
          teamIds: s.teamIds.toSet(),
          housingIds: s.housingIds.toSet(),
        );
    return (actor: actor, scope: scope);
  }

  Future<void> refresh() => _load(daysWindow: state.daysWindow);

  Future<void> loadMore() =>
      _load(daysWindow: state.daysWindow + OperationsConstants.historyPageDays);

  Future<void> _load({required int daysWindow}) async {
    final ctx = _actorAndScope();
    if (ctx == null) return;
    state = state.copyWith(
      daysWindow: daysWindow,
      isLoading: true,
      clearError: true,
    );
    try {
      final page = await ref
          .read(historyStoreProvider)
          .loadHistory(
            actor: ctx.actor,
            scope: ctx.scope,
            daysWindow: daysWindow,
            arabic: _isArabic,
          );
      state = state.copyWith(isLoading: false, page: page, clearError: true);
    } on OperationException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: OperationFailureMessage.of(error.failure, _isArabic),
      );
    }
  }
}

final historyNotifierProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);
