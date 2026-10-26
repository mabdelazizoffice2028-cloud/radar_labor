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
          widget.arabic ? 'تسوية التعارض' : 'Resolve conflict',
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
            labelText: widget.arabic ? 'ملاحظة اختيارية' : 'Optional note',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (kind: _kind, note: widget.note.text)),
          child: Text(widget.arabic ? 'حفظ التسوية' : 'Save resolution'),
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
          widget.arabic ? 'تبرير الغياب' : 'Justify absence',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        DropdownButtonFormField<String>(
          initialValue: _quick,
          items: [
            DropdownMenuItem(
              value: 'sick',
              child: Text(widget.arabic ? 'مرض' : 'Sick leave'),
            ),
            DropdownMenuItem(
              value: 'personal_permission',
              child: Text(widget.arabic ? 'إذن شخصي' : 'Personal permission'),
            ),
            DropdownMenuItem(
              value: 'official_errand',
              child: Text(widget.arabic ? 'مأمورية' : 'Official errand'),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Text(widget.arabic ? 'سبب آخر' : 'Other'),
            ),
          ],
          onChanged: (value) => setState(() => _quick = value),
          decoration: InputDecoration(
            labelText: widget.arabic
                ? 'سبب سريع (اختياري)'
                : 'Quick reason (optional)',
          ),
        ),
        TextField(
          controller: widget.note,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: widget.arabic ? 'ملاحظة (اختيارية)' : 'Note (optional)',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (quick: _quick, note: widget.note.text)),
          child: Text(widget.arabic ? 'حفظ التبرير' : 'Save justification'),
        ),
      ],
    ),
  );
}

String _resolutionLabel(ResolutionKind kind, bool arabic) => switch (kind) {
  ResolutionKind.confirmPresentLeftEarly =>
    arabic ? 'اعتماد الحضور، خرج مبكرًا' : 'Confirm present, left early',
  ResolutionKind.movedDuringDay =>
    arabic ? 'انتقل خلال اليوم' : 'Moved during the day',
  ResolutionKind.housingError => arabic ? 'خطأ من السكن' : 'Campus error',
  ResolutionKind.siteError => arabic ? 'خطأ من الموقع' : 'Site error',
  ResolutionKind.officialErrand =>
    arabic ? 'مأمورية أو إذن' : 'Official errand or permission',
};
