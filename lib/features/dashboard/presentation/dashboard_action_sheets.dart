part of 'dashboard_screen.dart';

class _ResolutionSheet extends StatefulWidget {
  const _ResolutionSheet({required this.arabic, required this.note});
  final bool arabic;
  final TextEditingController note;

  @override
  State<_ResolutionSheet> createState() => _ResolutionSheetState();
}

class _ResolutionSheetState extends State<_ResolutionSheet> {
  ResolutionKind _kind = ResolutionKind.confirmPresentLeftEarly;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DashboardStrings.resolveConflictTitle(widget.arabic),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ResolutionKind>(
          initialValue: _kind,
          items: [
            for (final kind in ResolutionKind.values)
              DropdownMenuItem(
                value: kind,
                child: Text(_resolutionLabel(kind, widget.arabic)),
              ),
          ],
          onChanged: (value) => setState(() => _kind = value ?? _kind),
        ),
        TextField(
          controller: widget.note,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: DashboardStrings.optionalNote(widget.arabic),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (kind: _kind, note: widget.note.text)),
          child: Text(DashboardStrings.saveResolution(widget.arabic)),
        ),
      ],
    ),
  );
}

class _JustificationSheet extends StatefulWidget {
  const _JustificationSheet({required this.arabic, required this.note});
  final bool arabic;
  final TextEditingController note;

  @override
  State<_JustificationSheet> createState() => _JustificationSheetState();
}

class _JustificationSheetState extends State<_JustificationSheet> {
  String? _quick;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DashboardStrings.justifyAbsenceTitle(widget.arabic),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        DropdownButtonFormField<String>(
          initialValue: _quick,
          items: [
            DropdownMenuItem(
              value: 'sick',
              child: Text(DashboardStrings.reasonSick(widget.arabic)),
            ),
            DropdownMenuItem(
              value: 'personal_permission',
              child: Text(
                DashboardStrings.reasonPersonalPermission(widget.arabic),
              ),
            ),
            DropdownMenuItem(
              value: 'official_errand',
              child: Text(DashboardStrings.reasonOfficialErrand(widget.arabic)),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Text(DashboardStrings.reasonOther(widget.arabic)),
            ),
          ],
          onChanged: (value) => setState(() => _quick = value),
          decoration: InputDecoration(
            labelText: DashboardStrings.quickReasonOptional(widget.arabic),
          ),
        ),
        TextField(
          controller: widget.note,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: DashboardStrings.noteOptional(widget.arabic),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (quick: _quick, note: widget.note.text)),
          child: Text(DashboardStrings.saveJustification(widget.arabic)),
        ),
      ],
    ),
  );
}

String _resolutionLabel(ResolutionKind kind, bool arabic) => switch (kind) {
  ResolutionKind.confirmPresentLeftEarly =>
    DashboardStrings.resolutionConfirmPresentLeftEarly(arabic),
  ResolutionKind.movedDuringDay => DashboardStrings.resolutionMovedDuringDay(
    arabic,
  ),
  ResolutionKind.housingError => DashboardStrings.resolutionHousingError(
    arabic,
  ),
  ResolutionKind.siteError => DashboardStrings.resolutionSiteError(arabic),
  ResolutionKind.officialErrand => DashboardStrings.resolutionOfficialErrand(
    arabic,
  ),
};
