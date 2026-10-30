import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AuthLanguageButton extends ConsumerWidget {
  const AuthLanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isAr = locale == 'ar';
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppTokens.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: const Icon(Icons.language, size: 20, color: AppTokens.surface),
      label: Text(
        isAr ? 'English' : 'عربي',
        style: const TextStyle(
          color: AppTokens.surface,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
      onPressed: () {
        final next = isAr ? 'en' : 'ar';
        ref.read(appLocaleProvider.notifier).setLocale(next);
      },
    );
  }
}
