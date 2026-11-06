import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class PinLoginHeader extends StatelessWidget {
  const PinLoginHeader({required this.account, required this.arabic, super.key});

  final LocalAccount account;
  final bool arabic;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const CircleAvatar(
        radius: 36,
        backgroundColor: AppTokens.primarySoft,
        child: Icon(Icons.lock_person_outlined, size: 40, color: AppTokens.primary),
      ),
      const SizedBox(height: AppTokens.space16),
      Text(
        AuthFlowStrings.welcomeBack(arabic),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTokens.textSecondary),
      ),
      const SizedBox(height: AppTokens.space4),
      Text(
        account.displayName,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold, color: AppTokens.textPrimary,
        ),
      ),
      const SizedBox(height: AppTokens.space8),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space12, vertical: AppTokens.space4,
          ),
          decoration: BoxDecoration(
            color: AppTokens.primarySoft,
            borderRadius: BorderRadius.circular(AppTokens.radiusChip),
          ),
          child: Text(
            account.role.label(arabic: arabic),
            style: const TextStyle(
              color: AppTokens.primaryDark, fontWeight: FontWeight.w600, fontSize: 12,
            ),
          ),
        ),
      ),
    ],
  );
}
