import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(seedColor: AppTokens.primary),
    scaffoldBackgroundColor: AppTokens.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppTokens.primary,
      foregroundColor: AppTokens.onPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTokens.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.space8),
      ),
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}
