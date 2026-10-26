import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';

/// Dialog requiring explicit resolution for every same-day conflict (PRD §10.2).
class AttendanceConflictDialog extends StatefulWidget {
  const AttendanceConflictDialog({
    required this.conflicts,
    required this.currentTeamName,
    required this.arabic,
    super.key,
  });

  final List<AttendanceConflict> conflicts;
  final String currentTeamName;
  final bool arabic;

  static Future<Map<String, ConflictResolutionChoice>?> show({
    required BuildContext context,
    required List<AttendanceConflict> conflicts,
    required String currentTeamName,
    required bool arabic,
  }) {
    return showDialog<Map<String, ConflictResolutionChoice>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceConflictDialog(
        conflicts: conflicts,
        currentTeamName: currentTeamName,
        arabic: arabic,
      ),
    );
  }

  @override
  State<AttendanceConflictDialog> createState() =>
      _AttendanceConflictDialogState();
}

class _AttendanceConflictDialogState extends State<AttendanceConflictDialog> {
  final Map<String, ConflictResolutionChoice> _choices =
      <String, ConflictResolutionChoice>{};

  bool get _allResolved => _choices.length == widget.conflicts.length;

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTokens.statusHousingOnly,
          ),
          const SizedBox(width: AppTokens.space8),
          Expanded(child: Text(OperationsStrings.localConflictTitle(ar))),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 460),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                OperationsStrings.errUnresolvedConflicts(ar),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTokens.space12),
              for (final conflict in widget.conflicts) ...[
                _ConflictCard(
                  conflict: conflict,
                  selectedChoice: _choices[conflict.worker.id],
                  arabic: ar,
                  onSelected: (choice) {
                    setState(() => _choices[conflict.worker.id] = choice);
                  },
                ),
                const SizedBox(height: AppTokens.space12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          height: AppTokens.minTouchTarget,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(OperationsStrings.reviewAction(ar)),
          ),
        ),
        SizedBox(
          height: AppTokens.minTouchTarget,
          child: FilledButton(
            onPressed: _allResolved
                ? () => Navigator.of(context)
                      .pop(Map<String, ConflictResolutionChoice>.from(_choices))
                : null,
            child: Text(OperationsStrings.confirmAndSave(ar)),
          ),
        ),
      ],
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.selectedChoice,
    required this.arabic,
    required this.onSelected,
  });

  final AttendanceConflict conflict;
  final ConflictResolutionChoice? selectedChoice;
  final bool arabic;
  final ValueChanged<ConflictResolutionChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final workerName = conflict.worker.displayName(arabic: arabic);
    final otherTeamName = conflict.otherTeamDisplayName(arabic: arabic);
    final timeHhMm = Bidi.isolateLtr(
      RiyadhTimeFormat.hhMm(conflict.recordedAtUtc),
    );

    return Container(
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: AppTokens.statusHousingOnlySoft,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.statusHousingOnly),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            OperationsStrings.localConflictBody(
              arabic,
              workerName,
              otherTeamName,
            ),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            OperationsStrings.localConflictRecordedAt(arabic, timeHhMm),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTokens.space8),
          _ChoiceTile(
            label: OperationsStrings.resolveAsTransfer(arabic),
            selected:
                selectedChoice == ConflictResolutionChoice.transferDuringDay,
            onTap: () => onSelected(ConflictResolutionChoice.transferDuringDay),
          ),
          _ChoiceTile(
            label: OperationsStrings.resolveAsCorrection(arabic),
            selected:
                selectedChoice == ConflictResolutionChoice.removeFromOtherTeam,
            onTap: () =>
                onSelected(ConflictResolutionChoice.removeFromOtherTeam),
          ),
          _ChoiceTile(
            label: OperationsStrings.resolveSkipWorker(arabic),
            selected: selectedChoice == ConflictResolutionChoice.skipWorker,
            onTap: () => onSelected(ConflictResolutionChoice.skipWorker),
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space4),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        selected: selected,
        button: true,
        label: label,
        child: Material(
          color: selected ? AppTokens.surface : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
            side: BorderSide(
              color: selected ? AppTokens.primary : AppTokens.outline,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppTokens.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space8,
                  vertical: AppTokens.space8,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? AppTokens.primary
                          : AppTokens.statusNotRecorded,
                    ),
                    const SizedBox(width: AppTokens.space8),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
