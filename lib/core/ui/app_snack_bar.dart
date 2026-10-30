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
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppTokens.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.space8),
        ),
      ),
    );
  }
}
