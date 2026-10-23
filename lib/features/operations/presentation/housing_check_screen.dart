import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';

final class HousingCheckScreen extends StatefulWidget {
  const HousingCheckScreen({
    required this.repository,
    required this.arabic,
    super.key,
  });

  final OperationsRepository repository;
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
    stream: widget.repository.watchHousings(),
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
                      child: Text(
                        widget.arabic ? row.nameAr : row.nameEn ?? row.nameAr,
                      ),
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
                    stream: widget.repository.watchHousingWorkers(selected.id),
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
                                widget.arabic
                                    ? worker.nameAr
                                    : worker.nameEn ?? worker.nameAr,
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
    final workers = await widget.repository
        .watchHousingWorkers(housing.id)
        .first;
    final names = workers
        .where((worker) => _absent.contains(worker.id))
        .map(
          (worker) =>
              '${widget.arabic ? worker.nameAr : worker.nameEn ?? worker.nameAr} (${worker.code})',
        )
        .toList();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('تأكيد فحص السكن', 'Confirm housing check')),
        content: Text(
          names.isEmpty
              ? t('تأكيد عدم وجود غائبين؟', 'Confirm that nobody is absent?')
              : names.join('\n'),
        ),
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
    final date = businessDateFor(const SystemClock().nowUtc());
    try {
      final undo = await widget.repository.saveHousingCheck(
        date: date,
        housing: housing,
        absentIds: _absent,
      );
      if (!mounted) return;
      final summary = _summary(housing, date, names);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('تم حفظ الفحص محليًا', 'Check saved locally')),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: t('تراجع', 'Undo'),
            onPressed: () => widget.repository.undoHousingCheck(undo),
          ),
        ),
      );
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t('ملخص واتساب', 'WhatsApp summary')),
          content: SelectableText(summary),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: summary));
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
    } catch (_) {
      if (mounted) {
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _summary(EntityOption housing, String date, List<String> names) {
    final name = widget.arabic
        ? housing.nameAr
        : housing.nameEn ?? housing.nameAr;
    final title = widget.arabic ? 'عدد الغائبين' : 'Absent workers';
    final body = names.isEmpty
        ? t('لا يوجد غائبون', 'No absences')
        : names.join('\n');
    return '$name\n$date\n$title: ${names.length}\n$body';
  }
}
