import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

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

  String t(String ar, String en) => widget.arabic ? ar : en;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<EntityOption>>(
    stream: widget.controller.watchHousings(),
    builder: (context, housingState) {
      final housings = housingState.data ?? const <EntityOption>[];
      final selected = housings
          .where((row) => row.id == _housingId)
          .firstOrNull;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: selected?.id,
              decoration: InputDecoration(
                labelText: t('اختر السكن', 'Select housing'),
                border: const OutlineInputBorder(),
              ),
              items: housings
                  .map(
                    (row) => DropdownMenuItem(
                      value: row.id,
                      child: Text(row.displayName(arabic: widget.arabic)),
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
                ? Center(
                    child: Text(
                      t(
                        'أضف سكنًا ثم ابدأ الفحص',
                        'Add housing to start a check',
                      ),
                    ),
                  )
                : StreamBuilder<List<WorkerOption>>(
                    stream: widget.controller.watchHousingWorkers(selected.id),
                    builder: (context, state) {
                      final workers = state.data ?? const <WorkerOption>[];
                      if (workers.isEmpty) {
                        return Center(
                          child: Text(
                            t(
                              'لا يوجد عمال مسندون لهذا السكن',
                              'No workers assigned to this housing',
                            ),
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
                              horizontal: 12,
                              vertical: 4,
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
                              title: Text(
                                worker.displayName(arabic: widget.arabic),
                              ),
                              subtitle: Text(
                                '${t('الكود', 'Code')}: ${worker.code}',
                              ),
                              secondary: Icon(
                                marked
                                    ? Icons.person_off_outlined
                                    : Icons.person_outline,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t(
                      'الغياب المحدد: ${_absent.length}',
                      'Marked absent: ${_absent.length}',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
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
                          ? t('جارٍ الحفظ…', 'Saving…')
                          : _absent.isEmpty
                          ? t(
                              'لا يوجد غائبون — حفظ الفحص',
                              'No absences — save check',
                            )
                          : t(
                              'تأكيد الغياب والحفظ',
                              'Confirm absences and save',
                            ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
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

  Future<void> _save(EntityOption housing) async {
    final PreparedHousingCheck check;
    try {
      check = await widget.controller.prepareHousingCheck(
        housing: housing,
        absentIds: Set.unmodifiable(_absent),
        arabic: widget.arabic,
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
        title: Text(t('تأكيد فحص السكن', 'Confirm housing check')),
        content: Text(summary.confirmationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('مراجعة', 'Review')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('تأكيد', 'Confirm')),
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
          content: Text(t('تم حفظ الفحص محليًا', 'Check saved locally')),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: t('تراجع', 'Undo'),
            onPressed: () => widget.controller.undoHousingCheck(undo),
          ),
        ),
      );
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t('ملخص واتساب', 'WhatsApp summary')),
          content: SelectableText(summary.messageText),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: summary.messageText),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(t('نسخ النص', 'Copy text')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('إغلاق', 'Close')),
            ),
          ],
        ),
      );
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
      SnackBar(
        content: Text(
          t(
            'تعذر حفظ الفحص. أعد المحاولة.',
            'Could not save check. Please retry.',
          ),
        ),
      ),
    );
  }
}
