import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dashboard_strings.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';
import 'package:radar_labor/features/dashboard/presentation/daily_report_button.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_action_handlers.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_date_selector.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_friday_banner.dart';
import 'package:radar_labor/features/dashboard/presentation/dashboard_status_cards.dart';
import 'package:radar_labor/features/dashboard/presentation/iqama_expiry_alert_card.dart';

part 'dashboard_sections.dart';
part 'dashboard_action_sheets.dart';

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
  late String _businessDate = businessDateFor(const SystemClock().nowUtc());
  bool get _ar => widget.arabic;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: DateTime.parse('${_businessDate}T12:00:00'),
      firstDate: DateTime(2020), lastDate: DateTime(2100), helpText: DashboardStrings.chooseBusinessDate(_ar),
    );
    if (mounted && d != null) setState(() => _businessDate = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<StatusSnapshot>(
    stream: widget.statusRepository.watch(arabic: _ar, businessDate: _businessDate),
    builder: (context, state) {
      if (state.hasError) return _MessageState(message: DashboardStrings.couldNotLoadDashboard(_ar), icon: Icons.error_outline);
      if (!state.hasData) return const Center(child: CircularProgressIndicator());
      final snap = state.requireData;
      final el = snap.workers.where((r) => r.isEligible);
      return ListView(padding: const EdgeInsets.all(16), children: [
        IqamaExpiryAlertCard(arabic: _ar),
        if (isFridayBusinessDate(_businessDate)) DashboardFridayBanner(arabic: _ar),
        DashboardDateSelector(date: _businessDate, arabic: _ar, onPressed: _pickDate),
        const SizedBox(height: 12),
        DashboardStatusCards(snapshot: snap, businessDate: _businessDate, arabic: _ar),
        DailyReportButton(snapshot: snap, date: _businessDate, arabic: _ar),
        const SizedBox(height: 12),
        _ConflictSection(rows: [for (final r in el) if (r.flags.contains(StatusFlag.housingSiteConflict) || r.flags.contains(StatusFlag.multipleSiteTeams)) r], arabic: _ar, onResolve: widget.canEdit ? _resolve : null),
        _UnknownSection(rows: [for (final r in el) if (r.status == WorkerStatus.unknown) r], arabic: _ar, onJustify: widget.canEdit ? _justify : null),
        _IntegritySection(rows: [for (final r in snap.workers) if (r.flags.contains(StatusFlag.inactiveWorkerEvent) || r.flags.contains(StatusFlag.eventOutsideEmployment) || r.flags.contains(StatusFlag.lateEvent) || r.flags.contains(StatusFlag.rejectedEvent)) r], arabic: _ar),
      ]);
    },
  );

  Future<void> _resolve(WorkerStatusResult r) => DashboardActionHandlers.resolve(
    context: context, actionsRepository: widget.actionsRepository, row: r, businessDate: _businessDate,
    actorUserId: widget.actorUserId, sheetBuilder: (_) => _ResolutionSheet(arabic: _ar, note: TextEditingController()),
  );

  Future<void> _justify(WorkerStatusResult r) => DashboardActionHandlers.justify(
    context: context, actionsRepository: widget.actionsRepository, row: r, businessDate: _businessDate,
    actorUserId: widget.actorUserId, sheetBuilder: (_) => _JustificationSheet(arabic: _ar, note: TextEditingController()),
  );
}
