import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/widgets/search_highlight_text.dart';

final class HousingWorkerInfo extends StatelessWidget {
  const HousingWorkerInfo({
    required this.worker,
    required this.arabic,
    required this.searchQuery,
    super.key,
  });

  final WorkerOption worker;
  final bool arabic;
  final String searchQuery;

  static const _codeStyle = TextStyle(
    color: AppTokens.textSecondary,
    fontSize: 13,
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      SearchHighlightText(
        text: worker.displayName(arabic: arabic),
        query: searchQuery,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      const SizedBox(height: AppTokens.space2),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(HousingReviewStrings.iqamaLabel(arabic), style: _codeStyle),
          SearchHighlightText(
            text: worker.code,
            query: searchQuery,
            style: _codeStyle,
          ),
        ],
      ),
    ],
  );
}
