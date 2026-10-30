import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/supervisor_task_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/scoped_worker_lookup_sheet.dart';

final class SupervisorTaskTopBar extends StatelessWidget {
  const SupervisorTaskTopBar({
    required this.arabic,
    required this.todayDate,
    required this.controller,
    super.key,
  });

  final bool arabic;
  final String todayDate;
  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            SupervisorTaskStrings.todayApprovedDate(arabic, todayDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTokens.textPrimary),
          ),
        ),
        InkWell(
          onTap: () => ScopedWorkerLookupSheet.show(context: context, arabic: arabic, controller: controller),
          borderRadius: BorderRadius.circular(AppTokens.radius12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: AppTokens.space4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, size: 16, color: AppTokens.primary),
                const SizedBox(width: AppTokens.space4),
                Text(
                  SupervisorTaskStrings.openLookupAction(arabic),
                  style: const TextStyle(fontSize: 12, color: AppTokens.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
