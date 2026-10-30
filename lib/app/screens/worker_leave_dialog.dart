import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/core/l10n/worker_summary_strings.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:uuid/uuid.dart';

class WorkerLeaveDialog extends StatefulWidget {
  const WorkerLeaveDialog({required this.employeeUid, required this.actorUserId, required this.arabic, super.key});
  final String employeeUid;
  final String? actorUserId;
  final bool arabic;

  static Future<WorkerLeave?> show(BuildContext context, {required String employeeUid, required String? actorUserId, required bool arabic}) =>
      showDialog<WorkerLeave>(context: context, builder: (_) => WorkerLeaveDialog(employeeUid: employeeUid, actorUserId: actorUserId, arabic: arabic));

  @override
  State<WorkerLeaveDialog> createState() => _WorkerLeaveDialogState();
}

class _WorkerLeaveDialogState extends State<WorkerLeaveDialog> {
  late DateTime _start;
  late DateTime _end;
  final _noteController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = const SystemClock().nowUtc();
    _start = DateTime.utc(now.year, now.month, now.day);
    _end = DateTime.utc(now.year, now.month, now.day);
  }

  String _fmt(DateTime dt) => '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _pick(bool isStart) async {
    final cur = isStart ? _start : _end;
    final picked = await showDatePicker(context: context, initialDate: cur, firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (picked != null) setState(() => isStart ? _start = picked : _end = picked);
  }

  void _submit() {
    final s = _fmt(_start);
    final e = _fmt(_end);
    if (e.compareTo(s) < 0) {
      setState(() => _error = WorkerSummaryStrings.invalidDateRange(widget.arabic));
      return;
    }
    Navigator.of(context).pop(WorkerLeave(
      leaveId: const Uuid().v4(), employeeUid: widget.employeeUid, startDate: s, endDate: e,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(), createdByUserId: widget.actorUserId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    return AlertDialog(
      title: Text(WorkerSummaryStrings.addLeave(ar)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: Text(WorkerSummaryStrings.startDate(ar)), subtitle: Text(_fmt(_start)), trailing: const Icon(Icons.calendar_today), onTap: () => _pick(true)),
        ListTile(title: Text(WorkerSummaryStrings.endDate(ar)), subtitle: Text(_fmt(_end)), trailing: const Icon(Icons.calendar_today), onTap: () => _pick(false)),
        TextField(controller: _noteController, decoration: InputDecoration(labelText: WorkerSummaryStrings.note(ar))),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: AppTokens.space8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(WorkerSummaryStrings.cancel(ar))),
        FilledButton(onPressed: _submit, child: Text(WorkerSummaryStrings.save(ar))),
      ],
    );
  }
}
