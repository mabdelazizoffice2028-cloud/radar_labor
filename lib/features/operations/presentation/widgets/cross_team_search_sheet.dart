import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';

/// Modal bottom sheet to search and add a guest worker from another team (PRD §8.6).
class CrossTeamSearchSheet extends StatefulWidget {
  const CrossTeamSearchSheet({
    required this.arabic,
    required this.onSearch,
    required this.onWorkerSelected,
    super.key,
  });

  final bool arabic;
  final Future<List<CrossTeamWorkerOption>> Function(String query) onSearch;
  final ValueChanged<CrossTeamWorkerOption> onWorkerSelected;

  static Future<void> show({
    required BuildContext context,
    required bool arabic,
    required Future<List<CrossTeamWorkerOption>> Function(String query)
    onSearch,
    required ValueChanged<CrossTeamWorkerOption> onWorkerSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CrossTeamSearchSheet(
        arabic: arabic,
        onSearch: onSearch,
        onWorkerSelected: onWorkerSelected,
      ),
    );
  }

  @override
  State<CrossTeamSearchSheet> createState() => _CrossTeamSearchSheetState();
}

class _CrossTeamSearchSheetState extends State<CrossTeamSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  List<CrossTeamWorkerOption> _results = const <CrossTeamWorkerOption>[];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleQueryChanged(String value) async {
    final trimmed = value.trim();
    if (trimmed.length < OperationsConstants.crossTeamSearchMinChars) {
      setState(() {
        _results = const <CrossTeamWorkerOption>[];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final items = await widget.onSearch(trimmed);
    if (!mounted || _controller.text.trim() != trimmed) return;
    setState(() {
      _results = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final query = _controller.text.trim();
    final hasMinChars =
        query.length >= OperationsConstants.crossTeamSearchMinChars;

    return Padding(
      padding: EdgeInsets.only(
        left: AppTokens.space16,
        right: AppTokens.space16,
        top: AppTokens.space16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppTokens.space16,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  OperationsStrings.addFromAnotherTeam(ar),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space8),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: OperationsStrings.crossTeamSearchHint(ar),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _handleQueryChanged,
            ),
            const SizedBox(height: AppTokens.space12),
            Expanded(
              child: !hasMinChars
                  ? Center(
                      child: Text(
                        OperationsStrings.crossTeamSearchHint(ar),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? Center(
                      child: Text(
                        OperationsStrings.noSearchResults(ar),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        final teamName =
                            item.teamDisplayName(arabic: ar) ??
                            OperationsStrings.noTeam(ar);
                        final badge = OperationsStrings.fromTeamBadge(
                          ar,
                          teamName,
                        );
                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: AppTokens.minRowHeight,
                          ),
                          child: ListTile(
                            title: Text(item.worker.displayName(arabic: ar)),
                            subtitle: Text('${item.worker.code} • $badge'),
                            trailing: const Icon(Icons.person_add_alt_1),
                            onTap: () {
                              widget.onWorkerSelected(item);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
