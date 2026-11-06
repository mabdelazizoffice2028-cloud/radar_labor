import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/l10n/conflict_resolution_strings.dart';
import 'package:radar_labor/core/time/time_format.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/conflict_detector.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_conflict_choice_tile.dart';

final class AttendanceConflictCard extends StatelessWidget {
  const AttendanceConflictCard({
    required this.conflict,
    required this.currentTeamName,
    required this.currentDate,
    required this.selectedChoice,
    required this.arabic,
    required this.onSelected,
    super.key,
  });

  final AttendanceConflict conflict;
  final String currentTeamName;
  final String? currentDate;
  final ConflictResolutionChoice? selectedChoice;
  final bool arabic;
  final ValueChanged<ConflictResolutionChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final workerName = conflict.worker.displayName(arabic: arabic);
    final otherTeamName = conflict.otherTeamDisplayName(arabic: arabic);
    final timeHhMm = Bidi.isolateLtr(RiyadhTimeFormat.hhMm(conflict.recordedAtUtc));

    return Container(
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
        border: Border.all(color: AppTokens.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$workerName • ${conflict.worker.code}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: AppTokens.space8),
          Container(
            padding: const EdgeInsets.all(AppTokens.space8),
            decoration: BoxDecoration(
              color: AppTokens.statusHousingOnlySoft,
              borderRadius: BorderRadius.circular(AppTokens.radius12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ConflictResolutionStrings.currentRecordTitle(arabic)}: $currentTeamName'
                  '${currentDate != null ? ' • $currentDate' : ''}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ConflictResolutionStrings.conflictingRecordTitle(arabic)}: $otherTeamName • $timeHhMm',
                  style: const TextStyle(fontSize: 12, color: AppTokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space8),
          ConflictChoiceTile(
            title: ConflictResolutionStrings.resolveAsCorrectionTitle(arabic),
            description: ConflictResolutionStrings.resolveAsCorrectionDesc(arabic),
            selected: selectedChoice == ConflictResolutionChoice.removeFromOtherTeam,
            onTap: () => onSelected(ConflictResolutionChoice.removeFromOtherTeam),
          ),
          ConflictChoiceTile(
            title: ConflictResolutionStrings.resolveAsTransferTitle(arabic),
            description: ConflictResolutionStrings.resolveAsTransferDesc(arabic),
            selected: selectedChoice == ConflictResolutionChoice.transferDuringDay,
            onTap: () => onSelected(ConflictResolutionChoice.transferDuringDay),
          ),
          ConflictChoiceTile(
            title: ConflictResolutionStrings.resolveSkipWorkerTitle(arabic),
            description: ConflictResolutionStrings.resolveSkipWorkerDesc(arabic),
            selected: selectedChoice == ConflictResolutionChoice.skipWorker,
            onTap: () => onSelected(ConflictResolutionChoice.skipWorker),
          ),
        ],
      ),
    );
  }
}
