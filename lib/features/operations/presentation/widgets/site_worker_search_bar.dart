import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class SiteWorkerSearchBar extends StatelessWidget {
  const SiteWorkerSearchBar({
    required this.arabic,
    required this.query,
    required this.onChanged,
    super.key,
  });

  final bool arabic;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space4,
      ),
      child: TextField(
        key: const ValueKey('site_worker_search_field'),
        decoration: InputDecoration(
          hintText: OperationsStrings.searchWorkersHint(arabic),
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(''),
                )
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
