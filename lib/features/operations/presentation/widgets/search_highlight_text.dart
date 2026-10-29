import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/search_match.dart';

/// Text whose search hits get a stable, translucent highlight. The tint is
/// translucent so the row's present/absent colour stays readable underneath.
final class SearchHighlightText extends StatelessWidget {
  const SearchHighlightText({
    required this.text,
    required this.query,
    this.style,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final segment in SearchMatch.split(text, query))
            TextSpan(
              text: segment.text,
              style: segment.matched
                  ? const TextStyle(backgroundColor: AppTokens.searchHighlight)
                  : null,
            ),
        ],
      ),
    );
  }
}
