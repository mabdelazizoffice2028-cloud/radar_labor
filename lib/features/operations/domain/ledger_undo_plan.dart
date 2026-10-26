import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/operations/domain/attendance_ledger.dart';

/// Captures the prior effective state of a single [LedgerKey] before a save transaction (PRD §6.3).
final class LedgerKeyRestoreEntry {
  const LedgerKeyRestoreEntry({
    required this.key,
    required this.restoreAction,
    this.resolutionKind,
  });

  final LedgerKey key;
  final EventAction restoreAction;
  final ResolutionKind? resolutionKind;
}

/// Pure undo plan that restores all touched ledger keys (including conflict resolutions and cross-team clears)
/// to their prior effective state by appending compensating events (PRD §6.3).
final class LedgerUndoPlan {
  const LedgerUndoPlan({required this.businessDate, required this.entries});

  final String businessDate;
  final List<LedgerKeyRestoreEntry> entries;

  /// Captures the prior effective state of [touchedKeys] from [ledger] before writing new events.
  factory LedgerUndoPlan.capture({
    required String businessDate,
    required AttendanceLedger ledger,
    required Iterable<LedgerKey> touchedKeys,
  }) {
    final seen = <LedgerKey>{};
    final entries = <LedgerKeyRestoreEntry>[];
    for (final key in touchedKeys) {
      if (!seen.add(key)) continue;
      final active = ledger.activeEventFor(key);
      entries.add(
        LedgerKeyRestoreEntry(
          key: key,
          restoreAction: active != null ? EventAction.set : EventAction.clear,
          resolutionKind: active?.resolutionKind,
        ),
      );
    }
    return LedgerUndoPlan(
      businessDate: businessDate,
      entries: List.unmodifiable(entries),
    );
  }
}
