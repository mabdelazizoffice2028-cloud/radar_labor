import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/worker_list_tile.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

class WorkerListView extends StatelessWidget {
  const WorkerListView({
    required this.stream,
    required this.query,
    required this.arabic,
    super.key,
  });

  final Stream<List<Employee>> stream;
  final String query;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Employee>>(
      stream: stream,
      builder: (context, state) {
        final q = query.trim().toLowerCase();
        final list = (state.data ?? []).where((w) {
          if (q.isEmpty) return true;
          return w.fullNameAr.toLowerCase().contains(q) ||
              w.iqamaNo.toLowerCase().contains(q) ||
              (w.fullNameEn ?? '').toLowerCase().contains(q);
        }).toList();
        if (list.isEmpty) {
          return Center(child: Text(AppStrings.noWorkersYet(arabic)));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: list.length,
          itemBuilder: (context, i) => WorkerListTile(
            worker: list[i],
            arabic: arabic,
          ),
        );
      },
    );
  }
}
