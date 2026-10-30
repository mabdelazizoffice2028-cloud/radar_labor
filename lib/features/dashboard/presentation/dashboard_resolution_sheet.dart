import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class DashboardResolutionSheet extends StatefulWidget {
  const DashboardResolutionSheet({required this.arabic, this.note, super.key});
  final bool arabic; final TextEditingController? note;

  @override
  State<DashboardResolutionSheet> createState() => _DashboardResolutionSheetState();
}

final class _DashboardResolutionSheetState extends State<DashboardResolutionSheet> {
  ResolutionKind _kind = ResolutionKind.confirmPresentLeftEarly;
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
        Text(DashboardStrings.resolveConflictTitle(widget.arabic), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTokens.space12),
        DropdownButtonFormField<ResolutionKind>(
          initialValue: _kind,
          items: [
            for (final kind in ResolutionKind.values)
              DropdownMenuItem(value: kind, child: Text(_label(kind, widget.arabic))),
          ],
          onChanged: (value) => setState(() => _kind = value ?? _kind),
        ),
        TextField(controller: _noteCtrl, maxLines: 2, decoration: InputDecoration(labelText: DashboardStrings.optionalNote(widget.arabic))),
        const SizedBox(height: AppTokens.space12),
        FilledButton(
          onPressed: () => Navigator.pop(context, (kind: _kind, note: _noteCtrl.text)),
          child: Text(DashboardStrings.saveResolution(widget.arabic)),
        ),
      ],
    ),
  );

  String _label(ResolutionKind kind, bool ar) => switch (kind) {
    ResolutionKind.confirmPresentLeftEarly => DashboardStrings.resolutionConfirmPresentLeftEarly(ar),
    ResolutionKind.movedDuringDay => DashboardStrings.resolutionMovedDuringDay(ar),
    ResolutionKind.housingError => DashboardStrings.resolutionHousingError(ar),
    ResolutionKind.siteError => DashboardStrings.resolutionSiteError(ar),
    ResolutionKind.officialErrand => DashboardStrings.resolutionOfficialErrand(ar),
  };
}
