import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Standardized atomic empty state component with icon, message, and action.
final class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.message,
    this.onPressed,
    this.buttonText,
    super.key,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onPressed;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppTokens.space64,
              color: AppTokens.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTokens.textSecondary,
              ),
            ),
            if (onPressed != null && buttonText != null) ...[
              const SizedBox(height: AppTokens.space16),
              ElevatedButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
