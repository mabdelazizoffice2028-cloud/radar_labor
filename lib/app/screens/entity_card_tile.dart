import 'package:material_ui/material_ui.dart';

class EntityCardTile extends StatelessWidget {
  const EntityCardTile({required this.title, required this.isTeam, super.key});

  final String title;
  final bool isTeam;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(isTeam ? Icons.groups_2 : Icons.apartment),
        title: Text(title),
      ),
    );
  }
}
