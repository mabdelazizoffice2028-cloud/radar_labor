import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_conflict_card.dart';

/// Simplified dialog requiring explicit resolution for same-day conflicts (Phase 6).
class AttendanceConflictDialog extends StatefulWidget {
  const AttendanceConflictDialog({
    required this.conflicts, required this.currentTeamName,
    required this.arabic, this.currentDate, super.key,
  });

  final List<AttendanceConflict> conflicts;
  final String currentTeamName;
  final bool arabic;
  final String? currentDate;

  static Future<Map<String, ConflictResolutionChoice>?> show({
    required BuildContext context, required List<AttendanceConflict> conflicts,
    required String currentTeamName, required bool arabic, String? currentDate,
  }) => showDialog<Map<String, ConflictResolutionChoice>>(
    context: context, barrierDismissible: false,
    builder: (_) => AttendanceConflictDialog(
      conflicts: conflicts, currentTeamName: currentTeamName, arabic: arabic, currentDate: currentDate,
    ),
  );

  @override
  State<AttendanceConflictDialog> createState() => _AttendanceConflictDialogState();
}

class _AttendanceConflictDialogState extends State<AttendanceConflictDialog> {
  final Map<String, ConflictResolutionChoice> _choices = {};
  bool _isSubmitting = false;

  bool get _allResolved => _choices.length == widget.conflicts.length;

  void _onConfirm() {
    if (!_allResolved || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    Navigator.of(context).pop(Map<String, ConflictResolutionChoice>.from(_choices));
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    return AlertDialog(
      title: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppTokens.statusHousingOnly),
        const SizedBox(width: AppTokens.space8),
        Expanded(child: Text(OperationsStrings.localConflictTitle(ar))),
      ]),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min,
            children: [
              Text(OperationsStrings.errUnresolvedConflicts(ar), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppTokens.space12),
              for (final conflict in widget.conflicts) ...[
                AttendanceConflictCard(
                  conflict: conflict, currentTeamName: widget.currentTeamName,
                  currentDate: widget.currentDate, selectedChoice: _choices[conflict.worker.id],
                  arabic: ar,
                  onSelected: (choice) {
                    if (!_isSubmitting) setState(() => _choices[conflict.worker.id] = choice);
                  },
                ),
                const SizedBox(height: AppTokens.space12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(OperationsStrings.reviewAction(ar)),
        ),
        FilledButton(
          onPressed: _allResolved && !_isSubmitting ? _onConfirm : null,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(OperationsStrings.confirmAndSave(ar)),
        ),
      ],
    );
  }
}
