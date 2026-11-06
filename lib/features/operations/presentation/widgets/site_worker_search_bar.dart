import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class SiteWorkerSearchBar extends StatefulWidget {
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
  State<SiteWorkerSearchBar> createState() => _SiteWorkerSearchBarState();
}

final class _SiteWorkerSearchBarState extends State<SiteWorkerSearchBar> {
  late final TextEditingController _controller = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(covariant SiteWorkerSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space4,
      ),
      child: TextField(
        key: const ValueKey('site_worker_search_field'),
        controller: _controller,
        decoration: InputDecoration(
          hintText: OperationsStrings.searchWorkersHint(widget.arabic),
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius12),
          ),
          suffixIcon: widget.query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
