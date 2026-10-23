part of 'dashboard_screen.dart';

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.date,
    required this.arabic,
    required this.onPressed,
  });
  final String date;
  final bool arabic;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(arabic ? 'يوم العمل' : 'Business date'),
      subtitle: Text(date),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onPressed,
    ),
  );
}

class _StatusCards extends StatelessWidget {
  const _StatusCards({required this.snapshot, required this.arabic});
  final StatusSnapshot snapshot;
  final bool arabic;

  static const _statuses = [
    WorkerStatus.onSite,
    WorkerStatus.housingOnly,
    WorkerStatus.unknown,
    WorkerStatus.justified,
    WorkerStatus.notRecorded,
  ];

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.75,
    children: [
      for (final status in _statuses)
        _StatusCard(
          count: snapshot.count(status),
          label: _label(status),
          icon: _icon(status),
          color: _color(status),
        ),
    ],
  );

  String _label(WorkerStatus status) => switch (status) {
    WorkerStatus.onSite => arabic ? 'في الموقع' : 'On site',
    WorkerStatus.housingOnly => arabic ? 'في السكن فقط' : 'Housing only',
    WorkerStatus.unknown => arabic ? 'غير معلوم' : 'Unknown',
    WorkerStatus.justified => arabic ? 'مبرر' : 'Justified',
    WorkerStatus.notRecorded => arabic ? 'لم يسجل بعد' : 'Not recorded',
  };

  IconData _icon(WorkerStatus status) => switch (status) {
    WorkerStatus.onSite => Icons.check_circle_outline,
    WorkerStatus.housingOnly => Icons.home_outlined,
    WorkerStatus.unknown => Icons.warning_amber_rounded,
    WorkerStatus.justified => Icons.verified_outlined,
    WorkerStatus.notRecorded => Icons.schedule_outlined,
  };

  Color _color(WorkerStatus status) => switch (status) {
    WorkerStatus.onSite => const Color(0xff15803d),
    WorkerStatus.housingOnly => const Color(0xffb45309),
    WorkerStatus.unknown => const Color(0xffb91c1c),
    WorkerStatus.justified => const Color(0xff0e7490),
    WorkerStatus.notRecorded => Colors.blueGrey,
  };
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _CoverageWarnings extends StatelessWidget {
  const _CoverageWarnings({required this.coverage, required this.arabic});
  final DashboardCoverage coverage;
  final bool arabic;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _WarningCard(
        title: arabic ? 'مساكن لم تسجل بعد' : 'Housings not checked',
        rows: coverage.missingHousings,
        arabic: arabic,
      ),
      _WarningCard(
        title: arabic ? 'فرق لم تسجل بعد' : 'Teams not submitted',
        rows: coverage.missingTeams,
        arabic: arabic,
      ),
    ],
  );
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.title,
    required this.rows,
    required this.arabic,
  });
  final String title;
  final List<CoverageWarning> rows;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      color: const Color(0xfffff7ed),
      child: ListTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xffb45309),
        ),
        title: Text('$title (${rows.length})'),
        subtitle: Text(
          rows
              .map((row) => arabic ? row.nameAr : row.nameEn ?? row.nameAr)
              .join('، '),
        ),
      ),
    );
  }
}

class _ConflictSection extends StatelessWidget {
  const _ConflictSection({
    required this.rows,
    required this.arabic,
    required this.onResolve,
  });
  final List<WorkerStatusResult> rows;
  final bool arabic;
  final ValueChanged<WorkerStatusResult> onResolve;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          arabic ? 'تعارضات تحتاج مراجعة' : 'Conflicts to review',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (final row in rows)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.compare_arrows,
                color: Color(0xffb45309),
              ),
              title: Text('${row.worker.fullName} • ${row.worker.code}'),
              subtitle: Text(_conflictLabel(row.flags, arabic)),
              trailing: TextButton(
                onPressed: () => onResolve(row),
                child: Text(arabic ? 'تسوية' : 'Resolve'),
              ),
            ),
          ),
      ],
    );
  }

  String _conflictLabel(Set<StatusFlag> flags, bool arabic) {
    final labels = <String>[];
    if (flags.contains(StatusFlag.housingSiteConflict)) {
      labels.add(
        arabic ? 'غياب سكن مع حضور موقع' : 'Housing absence and site presence',
      );
    }
    if (flags.contains(StatusFlag.multipleSiteTeams)) {
      labels.add(arabic ? 'مسجل في أكثر من فريق' : 'Multiple site teams');
    }
    return labels.join(' • ');
  }
}

class _UnknownSection extends StatelessWidget {
  const _UnknownSection({
    required this.rows,
    required this.arabic,
    required this.onJustify,
  });
  final List<WorkerStatusResult> rows;
  final bool arabic;
  final ValueChanged<WorkerStatusResult> onJustify;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 16, bottom: 4),
          child: Text(
            arabic ? 'عمال غير معلومين' : 'Unknown workers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final row in rows)
          Card(
            child: ListTile(
              leading: Icon(
                row.isSlaBreached
                    ? Icons.timer_off_outlined
                    : Icons.help_outline,
                color: row.isSlaBreached
                    ? const Color(0xffb91c1c)
                    : const Color(0xffb45309),
              ),
              title: Text('${row.worker.fullName} • ${row.worker.code}'),
              subtitle: Text(
                row.isSlaBreached
                    ? (arabic ? 'تجاوز مهلة المتابعة' : 'SLA exceeded')
                    : (arabic
                          ? 'غياب سكن دون تبرير'
                          : 'Housing absence without justification'),
              ),
              trailing: IconButton(
                tooltip: arabic ? 'إضافة تبرير' : 'Add justification',
                onPressed: () => onJustify(row),
                icon: const Icon(Icons.note_add_outlined),
              ),
            ),
          ),
      ],
    );
  }
}

class _IntegritySection extends StatelessWidget {
  const _IntegritySection({required this.rows, required this.arabic});
  final List<WorkerStatusResult> rows;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      child: ExpansionTile(
        title: Text(
          arabic
              ? 'ملاحظات على السجل (${rows.length})'
              : 'Ledger notices (${rows.length})',
        ),
        children: [
          for (final row in rows)
            ListTile(
              title: Text('${row.worker.fullName} • ${row.worker.code}'),
              subtitle: Text(_labels(row.flags, arabic)),
            ),
        ],
      ),
    );
  }

  String _labels(Set<StatusFlag> flags, bool arabic) {
    final values = <String>[];
    if (flags.contains(StatusFlag.inactiveWorkerEvent)) {
      values.add(arabic ? 'حدث لعامل معطل' : 'Event for inactive worker');
    }
    if (flags.contains(StatusFlag.eventOutsideEmployment)) {
      values.add(arabic ? 'حدث خارج فترة العمل' : 'Event outside employment');
    }
    if (flags.contains(StatusFlag.lateEvent)) {
      values.add(arabic ? 'تسجيل بتاريخ سابق' : 'Late entry');
    }
    if (flags.contains(StatusFlag.rejectedEvent)) {
      values.add(arabic ? 'حدث مرفوض' : 'Rejected event');
    }
    return values.join(' • ');
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon), Text(message)],
    ),
  );
}
