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
      title: Text(DashboardStrings.businessDate(arabic)),
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
    WorkerStatus.onSite => DashboardStrings.onSiteStatus(arabic),
    WorkerStatus.housingOnly => DashboardStrings.housingOnlyStatus(arabic),
    WorkerStatus.unknown => DashboardStrings.unknownStatus(arabic),
    WorkerStatus.justified => DashboardStrings.justifiedStatus(arabic),
    WorkerStatus.notRecorded => DashboardStrings.notRecordedStatus(arabic),
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
