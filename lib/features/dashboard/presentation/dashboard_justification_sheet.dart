import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class DashboardJustificationSheet extends StatefulWidget {
  const DashboardJustificationSheet({required this.arabic, this.note, super.key});
  final bool arabic; final TextEditingController? note;

  @override
  State<DashboardJustificationSheet> createState() => _DashboardJustificationSheetState();
}

final class _DashboardJustificationSheetState extends State<DashboardJustificationSheet> {
  String? _quick;
  late final TextEditingController _noteCtrl;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.note == null;
    _noteCtrl = widget.note ?? TextEditingController();
  }

  @override
  void dispose() {
    if (_ownsController) _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      AppTokens.space20, AppTokens.space20, AppTokens.space20,
      MediaQuery.viewInsetsOf(context).bottom + AppTokens.space20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(DashboardStrings.justifyAbsenceTitle(widget.arabic), style: Theme.of(context).textTheme.titleLarge),
        DropdownButtonFormField<String>(
          initialValue: _quick,
          items: [
            DropdownMenuItem(value: 'sick', child: Text(DashboardStrings.reasonSick(widget.arabic))),
            DropdownMenuItem(value: 'personal_permission', child: Text(DashboardStrings.reasonPersonalPermission(widget.arabic))),
            DropdownMenuItem(value: 'official_errand', child: Text(DashboardStrings.reasonOfficialErrand(widget.arabic))),
            DropdownMenuItem(value: 'other', child: Text(DashboardStrings.reasonOther(widget.arabic))),
          ],
          onChanged: (value) => setState(() => _quick = value),
          decoration: InputDecoration(labelText: DashboardStrings.quickReasonOptional(widget.arabic)),
        ),
        TextField(controller: _noteCtrl, maxLines: 2, decoration: InputDecoration(labelText: DashboardStrings.noteOptional(widget.arabic))),
        const SizedBox(height: AppTokens.space12),
        FilledButton(
          onPressed: () => Navigator.pop(context, (quick: _quick, note: _noteCtrl.text)),
          child: Text(DashboardStrings.saveJustification(widget.arabic)),
        ),
      ],
    ),
  );
}
