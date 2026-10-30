import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/screens/worker_add_dialog.dart';
import 'package:radar_labor/app/screens/worker_list_view.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class WorkersScreen extends StatefulWidget {
  const WorkersScreen({
    required this.database,
    required this.arabic,
    this.events,
    super.key,
  });

  final AppDatabase database;
  final bool arabic;
  final Object? events;

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

final class _WorkersScreenState extends State<WorkersScreen> {
  String _query = '';

  void _showMessage(String msg) {
    if (!mounted) return;
    AppSnackBar.showWarning(context, message: msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddWorkerDialog(
          context: context,
          database: widget.database,
          arabic: widget.arabic,
          showMessage: _showMessage,
        ),
        icon: const Icon(Icons.person_add),
        label: Text(AppStrings.add(widget.arabic)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTokens.space12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppStrings.searchWorker(widget.arabic),
              ),
            ),
          ),
          Expanded(
            child: WorkerListView(
              stream: widget.database.select(widget.database.employees).watch(),
              query: _query,
              arabic: widget.arabic,
            ),
          ),
        ],
      ),
    );
  }
}
