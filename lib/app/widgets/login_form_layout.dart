import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/login_error_banner.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class LoginFormLayout extends StatelessWidget {
  const LoginFormLayout({
    required this.arabic,
    required this.child,
    this.banner,
    super.key,
  });

  final bool arabic;
  final Widget child;
  final String? banner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.login(arabic),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.space12),
          child,
          if (banner != null) ...[
            const SizedBox(height: AppTokens.space12),
            LoginErrorBanner(message: banner!),
          ],
        ],
      ),
    );
  }
}
