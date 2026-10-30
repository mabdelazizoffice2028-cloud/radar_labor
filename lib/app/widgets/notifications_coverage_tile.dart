import 'package:material_ui/material_ui.dart';

final class NotificationsCoverageTile extends StatelessWidget {
  const NotificationsCoverageTile({
    required this.icon,
    required this.title,
    required this.supervisors,
    required this.arabic,
    super.key,
  });

  final IconData icon;
  final String title;
  final String supervisors;
  final bool arabic;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    child: ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.amber.shade800),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: supervisors.isNotEmpty
          ? Text(
              '${arabic ? 'المشرف:' : 'Supervisor:'} $supervisors',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          arabic ? 'لم يُرصد' : 'Missing',
          style: TextStyle(
            fontSize: 11,
            color: Colors.amber.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
