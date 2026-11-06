import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/attendance_diff.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/attendance_diff_group_card.dart';

/// Pre-save diff confirmation dialog (PRD §9.2).
class AttendanceDiffDialog extends StatelessWidget {
  const AttendanceDiffDialog({
    required this.team, required this.date, required this.diff, required this.arabic, super.key,
  });

  final EntityOption team;
  final String date;
  final AttendanceDiffResult diff;
  final bool arabic;

  static Future<bool> show({
    required BuildContext context, required EntityOption team, required String date,
    required AttendanceDiffResult diff, required bool arabic,
  }) async => (await showDialog<bool>(
    context: context,
    builder: (_) => AttendanceDiffDialog(team: team, date: date, diff: diff, arabic: arabic),
  )) ?? false;

  @override
  Widget build(BuildContext context) {
    final teamName = team.displayName(arabic: arabic);
    final hasBaseline = diff.baseline.kind != BaselineKind.none;

    return AlertDialog(
      title: Text('${OperationsStrings.confirmSiteAttendanceTitle(arabic)} — $teamName'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 420),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min,
            children: [
              Text(diff.totalLine(arabic), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppTokens.space4),
              Text(diff.baselineLabel(arabic), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTokens.textSecondary)),
              if (diff.totalPresent == 0) ...[
                const SizedBox(height: AppTokens.space12),
                Container(
                  padding: const EdgeInsets.all(AppTokens.space12),
                  decoration: BoxDecoration(
                    color: AppTokens.statusUnknownSoft, borderRadius: BorderRadius.circular(AppTokens.radius12),
                    border: Border.all(color: AppTokens.statusUnknown),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTokens.statusUnknown),
                    const SizedBox(width: AppTokens.space8),
                    Expanded(child: Text(OperationsStrings.zeroWorkersConfirmation(arabic), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                  ]),
                ),
              ],
              if (hasBaseline) ...[
                const SizedBox(height: AppTokens.space12),
                if (!diff.hasChanges)
                  Container(
                    padding: const EdgeInsets.all(AppTokens.space12),
                    decoration: BoxDecoration(color: AppTokens.background, borderRadius: BorderRadius.circular(AppTokens.radius12)),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline, color: AppTokens.statusOnSite),
                      const SizedBox(width: AppTokens.space8),
                      Expanded(child: Text(OperationsStrings.diffNoChanges(arabic))),
                    ]),
                  ),
                if (diff.addedWorkers.isNotEmpty) ...[
                  AttendanceDiffGroupCard(
                    title: '${OperationsStrings.diffAddedTitle(arabic)} (${Bidi.isolateLtr('+${diff.addedWorkers.length}')})',
                    workers: diff.addedWorkers, arabic: arabic,
                    backgroundColor: AppTokens.statusOnSiteSoft, borderColor: AppTokens.statusOnSite,
                    icon: Icons.add_circle_outline, iconColor: AppTokens.statusOnSite,
                  ),
                  const SizedBox(height: AppTokens.space8),
                ],
                if (diff.removedWorkers.isNotEmpty)
                  AttendanceDiffGroupCard(
                    title: '${OperationsStrings.diffRemovedTitle(arabic)} (${Bidi.isolateLtr('-${diff.removedWorkers.length}')})',
                    workers: diff.removedWorkers, arabic: arabic,
                    backgroundColor: AppTokens.statusUnknownSoft, borderColor: AppTokens.statusUnknown,
                    icon: Icons.remove_circle_outline, iconColor: AppTokens.statusUnknown,
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(height: AppTokens.minTouchTarget, child: TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(OperationsStrings.reviewAction(arabic)))),
        SizedBox(height: AppTokens.minTouchTarget, child: FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(OperationsStrings.confirmAndSave(arabic)))),
      ],
    );
  }
}
