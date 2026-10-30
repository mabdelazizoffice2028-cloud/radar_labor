import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AppSnackBar {
  const AppSnackBar._();

  static const Duration defaultDuration = Duration(seconds: 3);

  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = defaultDuration,
    SnackBarAction? action,
    IconData? icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTokens.onPrimary, size: AppTokens.space20),
              const SizedBox(width: AppTokens.space8),
            ],
            Expanded(child: Text(message, style: const TextStyle(color: AppTokens.onPrimary))),
          ],
        ),
        backgroundColor: backgroundColor ?? AppTokens.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.space8)),
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) => show(
    context, message: message, backgroundColor: AppTokens.statusOnSite,
    duration: duration, action: action, icon: Icons.check_circle_outline,
  );

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) => show(
    context, message: message, backgroundColor: AppTokens.statusUnknown,
    duration: duration, action: action, icon: Icons.error_outline,
  );

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) => show(
    context, message: message, backgroundColor: AppTokens.statusHousingOnly,
    duration: duration, action: action, icon: Icons.warning_amber_rounded,
  );
}
