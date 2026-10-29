import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    required this.busy,
    required this.arabic,
    required this.onSubmit,
    super.key,
  });

  final bool busy;
  final bool arabic;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const ValueKey('login_submit_button'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(96, AppTokens.minTouchTarget),
      ),
      onPressed: busy ? null : onSubmit,
      child: busy
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppTokens.onPrimary,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              AppStrings.login(arabic),
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}
