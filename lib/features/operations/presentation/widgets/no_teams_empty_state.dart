import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Guidance shown to a site supervisor who has no assigned team yet.
final class NoTeamsEmptyState extends StatelessWidget {
  const NoTeamsEmptyState({
    required this.arabic,
    required this.onCreateTeam,
    super.key,
  });

  final bool arabic;

  /// Null hides the button when team creation is not available.
  final VoidCallback? onCreateTeam;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_2_outlined,
              size: 56,
              color: AppTokens.textSecondary,
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              OperationsStrings.noTeamsYetSupervisor(arabic),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onCreateTeam != null) ...[
              const SizedBox(height: AppTokens.space24),
              FilledButton.icon(
                key: const ValueKey('create_first_team_button'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
                ),
                icon: const Icon(Icons.group_add_outlined),
                label: Text(OperationsStrings.createNewTeam(arabic)),
                onPressed: onCreateTeam,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
