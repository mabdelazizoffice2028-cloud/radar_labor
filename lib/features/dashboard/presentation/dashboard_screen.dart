import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/components/app_empty_state.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_action_handlers.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_justification_sheet.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_resolution_sheet.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_view_body.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.statusRepository, required this.coverageRepository,
    required this.actionsRepository, required this.arabic,
    required this.actorUserId, this.canEdit = true, super.key,
  });
  final StatusSnapshotRepository statusRepository;
  final DashboardCoverageRepository coverageRepository;
  final DashboardActionsRepository actionsRepository;
  final bool arabic; final String actorUserId; final bool canEdit;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _businessDate;
  bool get _ar => widget.arabic;

  @override
  void initState() {
    super.initState();
    _businessDate = businessDateFor(widget.statusRepository.clock.nowUtc());
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: DateTime.parse('${_businessDate}T12:00:00'),
      firstDate: DateTime(2020), lastDate: DateTime(2100), helpText: DashboardStrings.chooseBusinessDate(_ar),
    );
    if (mounted && d != null) {
      setState(() => _businessDate = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<StatusSnapshot>(
    stream: widget.statusRepository.watch(arabic: _ar, businessDate: _businessDate),
    builder: (context, state) {
      if (state.hasError) return AppEmptyState(message: DashboardStrings.couldNotLoadDashboard(_ar), icon: Icons.error_outline);
      if (!state.hasData) return const Center(child: CircularProgressIndicator());
      return DashboardViewBody(
        snapshot: state.requireData, businessDate: _businessDate, arabic: _ar,
        onPickDate: _pickDate, onResolve: widget.canEdit ? _resolve : null,
        onJustify: widget.canEdit ? _justify : null,
      );
    },
  );

  Future<void> _resolve(WorkerStatusResult r) => DashboardActionHandlers.resolve(
    context: context, actionsRepository: widget.actionsRepository, row: r,
    businessDate: _businessDate, actorUserId: widget.actorUserId,
    sheetBuilder: (_) => DashboardResolutionSheet(arabic: _ar),
  );

  Future<void> _justify(WorkerStatusResult r) => DashboardActionHandlers.justify(
    context: context, actionsRepository: widget.actionsRepository, row: r,
    businessDate: _businessDate, actorUserId: widget.actorUserId,
    sheetBuilder: (_) => DashboardJustificationSheet(arabic: _ar),
  );
}
