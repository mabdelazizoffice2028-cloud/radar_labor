import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class StartupErrorView extends StatelessWidget {
  const StartupErrorView({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppTokens.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTokens.statusUnknown,
                size: AppTokens.space48,
              ),
              const SizedBox(height: AppTokens.space16),
              Text(
                AppStrings.couldNotStart(false),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              Text(
                error.toString(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTokens.space16),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppStrings.retry(false)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
