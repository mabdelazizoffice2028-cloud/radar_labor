import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class HousingCheckHeader extends StatelessWidget {
  const HousingCheckHeader({
    required this.arabic, required this.searchQuery, required this.onSearchChanged,
    required this.onNoAbsencesPressed, this.isSaving = false, this.isFriday = false, super.key,
  });

  final bool arabic, isSaving, isFriday;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNoAbsencesPressed;

  Widget _fridayBanner() => Container(
    margin: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space8),
    padding: const EdgeInsets.all(AppTokens.space12),
    decoration: BoxDecoration(color: AppTokens.primarySoft, borderRadius: BorderRadius.circular(AppTokens.radius12)),
    child: Row(children: [
      const Icon(Icons.info_outline, color: AppTokens.primary),
      const SizedBox(width: AppTokens.space8),
      Expanded(child: Text(OperationsStrings.errFridayAbsenceNotAllowed(arabic), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
    ]),
  );

  Widget _noAbsencesBtn() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space8),
    child: FilledButton.tonalIcon(
      onPressed: isSaving ? null : onNoAbsencesPressed,
      icon: const Icon(Icons.check_circle_outline, color: AppTokens.statusOnSite),
      label: Text(OperationsStrings.noAbsencesTodayAction(arabic), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppTokens.space48)),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (isFriday) _fridayBanner() else _noAbsencesBtn(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12, vertical: AppTokens.space4),
        child: TextField(
          key: const ValueKey('housing_worker_search_field'),
          decoration: InputDecoration(
            hintText: OperationsStrings.searchWorkersHint(arabic),
            prefixIcon: const Icon(Icons.search, size: AppTokens.space20),
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
