import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class HousingCheckHeader extends StatelessWidget {
  const HousingCheckHeader({
    required this.arabic,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onNoAbsencesPressed,
    this.isSaving = false,
    super.key,
  });

  final bool arabic;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNoAbsencesPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space8),
          child: FilledButton.tonalIcon(
            onPressed: isSaving ? null : onNoAbsencesPressed,
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            label: Text(
              OperationsStrings.noAbsencesTodayAction(arabic),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space4),
          child: TextField(
            key: const ValueKey('housing_worker_search_field'),
            decoration: InputDecoration(
              hintText: OperationsStrings.searchWorkersHint(arabic),
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radius12)),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => onSearchChanged(''))
                  : null,
            ),
            onChanged: onSearchChanged,
          ),
        ),
      ],
    );
  }
}
