import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

/// Housing check workflow for housing supervisors and admins (PRD §14).
final class HousingCheckScreen extends StatefulWidget {
  const HousingCheckScreen({
    required this.controller,
    required this.arabic,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;

  @override
  State<HousingCheckScreen> createState() => _HousingCheckScreenState();
}

final class _HousingCheckScreenState extends State<HousingCheckScreen> {
  String? _housingId;
  final Set<String> _absent = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    return StreamBuilder<List<EntityOption>>(
      stream: widget.controller.watchHousings(),
      builder: (context, housingState) {
        final housings = housingState.data ?? const <EntityOption>[];
        final selected = housings
            .where((row) => row.id == _housingId)
            .firstOrNull;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.space16),
              child: DropdownButtonFormField<String>(
                initialValue: selected?.id,
                decoration: InputDecoration(
                  labelText: OperationsStrings.selectHousing(ar),
                  border: const OutlineInputBorder(),
                ),
                items: housings
                    .map(
                      (row) => DropdownMenuItem(
                        value: row.id,
                        child: Text(row.displayName(arabic: ar)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _housingId = value;
                  _absent.clear();
                }),
              ),
            ),
            Expanded(
              child: selected == null
                  ? Center(child: Text(OperationsStrings.addHousingToStart(ar)))
                  : StreamBuilder<List<WorkerOption>>(
                      stream: widget.controller.watchHousingWorkers(
                        selected.id,
                      ),
                      builder: (context, state) {
                        final workers = state.data ?? const <WorkerOption>[];
                        if (workers.isEmpty) {
                          return Center(
                            child: Text(
                              OperationsStrings.noWorkersInHousing(ar),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: workers.length,
                          itemBuilder: (context, index) {
                            final worker = workers[index];
                            final marked = _absent.contains(worker.id);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppTokens.space12,
                                vertical: AppTokens.space4,
                              ),
                              child: CheckboxListTile(
                                value: marked,
                                onChanged: (value) => setState(() {
                                  if (value ?? false) {
                                    _absent.add(worker.id);
                                  } else {
                                    _absent.remove(worker.id);
                                  }
                                }),
                                title: Text(worker.displayName(arabic: ar)),
                                subtitle: Text(
                                  '${OperationsStrings.codeLabel(ar)}: ${worker.code}',
                                ),
                                secondary: Icon(
                                  marked
                                      ? Icons.person_off_outlined
                                      : Icons.person_outline,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      OperationsStrings.markedAbsentCount(ar, _absent.length),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTokens.space8),
                    FilledButton.icon(
                      onPressed: _saving || selected == null
                          ? null
                          : () => _save(selected),
                      icon: Icon(
                        _absent.isEmpty
                            ? Icons.check_circle_outline
                            : Icons.save_outlined,
                      ),
                      label: Text(
                        _saving
                            ? OperationsStrings.savingLabel(ar)
                            : _absent.isEmpty
                            ? OperationsStrings.noAbsencesSaveCheck(ar)
                            : OperationsStrings.confirmAbsencesAndSave(ar),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppTokens.minTouchTarget,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save(EntityOption housing) async {
    final ar = widget.arabic;
    final PreparedHousingCheck check;
    try {
      check = await widget.controller.prepareHousingCheck(
        housing: housing,
        absentIds: Set.unmodifiable(_absent),
        arabic: ar,
      );
    } on Exception {
      _showSaveError();
      return;
    }
    final summary = check.summary;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(OperationsStrings.confirmHousingCheckTitle(ar)),
        content: Text(summary.confirmationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(OperationsStrings.reviewAction(ar)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(OperationsStrings.confirmAction(ar)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final undo = await widget.controller.saveHousingCheck(check);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(OperationsStrings.housingSavedLocally(ar)),
          duration: OperationsConstants.undoWindow,
          action: SnackBarAction(
            label: OperationsStrings.undoAction(ar),
            onPressed: () => widget.controller.undoHousingCheck(undo),
          ),
        ),
      );
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(OperationsStrings.whatsappSummaryTitle(ar)),
          content: SelectableText(summary.messageText),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: summary.messageText),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(OperationsStrings.copyTextAction(ar)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(OperationsStrings.closeAction(ar)),
            ),
          ],
        ),
      );
      if (!mounted) return;
      setState(() => _absent.clear());
    } on Exception {
      _showSaveError();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSaveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(OperationsStrings.errSaveFailed(widget.arabic))),
    );
  }
}
