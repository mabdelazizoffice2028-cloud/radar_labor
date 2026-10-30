import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class ChangeTemporaryPasswordFields extends StatelessWidget {
  const ChangeTemporaryPasswordFields({
    required this.arabic,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscure,
    required this.onToggleObscure,
    this.errorMessage,
    super.key,
  });

  final bool arabic;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AuthFlowStrings.changeTemporaryPasswordDescription(arabic),
          style: const TextStyle(fontSize: 13, color: AppTokens.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordCtrl,
          obscureText: obscure,
          maxLength: AuthConstants.maxPasswordLength,
          decoration: InputDecoration(
            labelText: AppStrings.newPassword(arabic),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmCtrl,
          obscureText: obscure,
          maxLength: AuthConstants.maxPasswordLength,
          decoration: InputDecoration(
            labelText: AppStrings.confirmPassword(arabic),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            style: const TextStyle(color: AppTokens.statusUnknown, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
