part of 'dashboard_screen.dart';

class _ConflictSection extends StatelessWidget {
  const _ConflictSection({
    required this.rows,
    required this.arabic,
    required this.onResolve,
  });
  final List<WorkerStatusResult> rows;
  final bool arabic;
  final ValueChanged<WorkerStatusResult>? onResolve;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DashboardStrings.conflictsToReview(arabic),
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
                onPressed: onResolve == null ? null : () => onResolve!(row),
                child: Text(DashboardStrings.resolve(arabic)),
              ),
            ),
          ),
      ],
    );
  }

  String _conflictLabel(Set<StatusFlag> flags, bool arabic) {
    final labels = <String>[];
    if (flags.contains(StatusFlag.housingSiteConflict)) {
      labels.add(DashboardStrings.conflictHousingAndSite(arabic));
    }
    if (flags.contains(StatusFlag.multipleSiteTeams)) {
      labels.add(DashboardStrings.conflictMultipleTeams(arabic));
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
  final ValueChanged<WorkerStatusResult>? onJustify;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 16, bottom: 4),
          child: Text(
            DashboardStrings.unknownWorkers(arabic),
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
                    ? DashboardStrings.slaExceeded(arabic)
                    : DashboardStrings.campusAbsenceNoJustification(arabic),
              ),
              trailing: IconButton(
                tooltip: DashboardStrings.addJustification(arabic),
                onPressed: onJustify == null ? null : () => onJustify!(row),
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
        title: Text(DashboardStrings.ledgerNotices(arabic, rows.length)),
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
      values.add(DashboardStrings.noticeInactiveWorker(arabic));
    }
    if (flags.contains(StatusFlag.eventOutsideEmployment)) {
      values.add(DashboardStrings.noticeOutsideEmployment(arabic));
    }
    if (flags.contains(StatusFlag.lateEvent)) {
      values.add(DashboardStrings.noticeLateEntry(arabic));
    }
    if (flags.contains(StatusFlag.rejectedEvent)) {
      values.add(DashboardStrings.noticeRejectedEvent(arabic));
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
