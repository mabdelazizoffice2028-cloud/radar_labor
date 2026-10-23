import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/operations/data/operations_repository.dart';

final class SiteAttendanceScreen extends StatefulWidget {
  const SiteAttendanceScreen({
    required this.repository,
    required this.arabic,
    super.key,
  });

  final OperationsRepository repository;
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
    stream: widget.repository.watchTeams(),
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
                      child: Text(
                        widget.arabic ? row.nameAr : row.nameEn ?? row.nameAr,
                      ),
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
                    stream: widget.repository.watchTeamWorkers(selected.id),
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
                                widget.arabic
                                    ? worker.nameAr
                                    : worker.nameEn ?? worker.nameAr,
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
    final workers = await widget.repository.watchTeamWorkers(team.id).first;
    final names = workers
        .where((worker) => _present.contains(worker.id))
        .map(
          (worker) =>
              '${widget.arabic ? worker.nameAr : worker.nameEn ?? worker.nameAr} (${worker.code})',
        )
        .toList();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('تأكيد تسجيل الموقع', 'Confirm site attendance')),
        content: Text(
          names.isEmpty
              ? t(
                  'لم تحدد عمالًا. هل تسجل الفريق بصفر حضور؟',
                  'No workers selected. Submit zero present?',
                )
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
    try {
      final undo = await widget.repository.saveSiteAttendance(
        date: businessDateFor(const SystemClock().nowUtc()),
        team: team,
        presentIds: _present,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('تم حفظ تسجيل الفريق محليًا', 'Team submission saved locally'),
          ),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: t('تراجع', 'Undo'),
            onPressed: () => widget.repository.undoSiteAttendance(undo),
          ),
        ),
      );
      setState(() => _present.clear());
    } catch (_) {
      if (mounted) {
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
