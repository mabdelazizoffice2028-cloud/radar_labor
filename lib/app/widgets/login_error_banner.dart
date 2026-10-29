import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Compact inline error banner for the login forms.
final class LoginErrorBanner extends StatelessWidget {
  const LoginErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(AppTokens.space8),
      decoration: BoxDecoration(
        color: AppTokens.statusUnknownSoft,
        borderRadius: BorderRadius.circular(AppTokens.radius12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTokens.statusUnknown,
            size: 20,
          ),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTokens.statusUnknown,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
