import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';

final class SiteAttendanceScreen extends StatefulWidget {
  const SiteAttendanceScreen({
    required this.controller,
    required this.arabic,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;

  @override
  State<SiteAttendanceScreen> createState() => _SiteAttendanceScreenState();
}

final class _SiteAttendanceScreenState extends State<SiteAttendanceScreen> {
  String? _teamId;
  final Set<String> _present = {};
  bool _saving = false;

  String t(String ar, String en) => widget.arabic ? ar : en;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<EntityOption>>(
    stream: widget.controller.watchTeams(),
    builder: (context, teamState) {
      final teams = teamState.data ?? const <EntityOption>[];
      final selected = teams.where((row) => row.id == _teamId).firstOrNull;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: selected?.id,
              decoration: InputDecoration(
                labelText: t('اختر الفريق', 'Select team'),
                border: const OutlineInputBorder(),
              ),
              items: teams
                  .map(
                    (row) => DropdownMenuItem(
                      value: row.id,
                      child: Text(row.displayName(arabic: widget.arabic)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _teamId = value;
                _present.clear();
              }),
            ),
          ),
          Expanded(
            child: selected == null
                ? Center(
                    child: Text(
                      t('أضف فريقًا ثم ابدأ التسجيل', 'Add a team to start'),
                    ),
                  )
                : StreamBuilder<List<WorkerOption>>(
                    stream: widget.controller.watchTeamWorkers(selected.id),
                    builder: (context, state) {
                      final workers = state.data ?? const <WorkerOption>[];
                      if (workers.isEmpty) {
                        return Center(
                          child: Text(
                            t(
                              'لا يوجد عمال مسندون لهذا الفريق',
                              'No workers assigned to this team',
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: workers.length,
                        itemBuilder: (context, index) {
                          final worker = workers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: CheckboxListTile(
                              value: _present.contains(worker.id),
                              onChanged: (value) => setState(() {
                                if (value ?? false) {
                                  _present.add(worker.id);
                                } else {
                                  _present.remove(worker.id);
                                }
                              }),
                              title: Text(
                                worker.displayName(arabic: widget.arabic),
                              ),
                              subtitle: Text(
                                '${t('الكود', 'Code')}: ${worker.code}',
                              ),
                              secondary: const Icon(Icons.location_on_outlined),
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
                      'الحاضرون: ${_present.length}',
                      'Present: ${_present.length}',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _saving || selected == null
                        ? null
                        : () => _save(selected),
                    icon: const Icon(Icons.publish_outlined),
                    label: Text(
                      _saving
                          ? t('جارٍ الحفظ…', 'Saving…')
                          : t(
                              'تأكيد وإرسال تسجيل الفريق',
                              'Confirm team submission',
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

  Future<void> _save(EntityOption team) async {
    final PreparedSiteAttendance attendance;
    try {
      attendance = await widget.controller.prepareSiteAttendance(
        team: team,
        presentIds: Set.unmodifiable(_present),
        arabic: widget.arabic,
      );
    } on Exception {
      _showSaveError();
      return;
    }
    final summary = attendance.summary;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('تأكيد تسجيل الموقع', 'Confirm site attendance')),
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
      final undo = await widget.controller.saveSiteAttendance(attendance);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('تم حفظ تسجيل الفريق محليًا', 'Team submission saved locally'),
          ),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: t('تراجع', 'Undo'),
            onPressed: () => widget.controller.undoSiteAttendance(undo),
          ),
        ),
      );
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t('رسالة واتساب للحاضرين', 'WhatsApp message')),
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
      if (!mounted) return;
      setState(() => _present.clear());
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
            'تعذر حفظ التسجيل. أعد المحاولة.',
            'Could not save attendance. Please retry.',
          ),
        ),
      ),
    );
  }
}
