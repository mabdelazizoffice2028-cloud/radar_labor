import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/app/screens/worker_leave_dialog.dart';
import 'package:radar_labor/app/screens/worker_summary_header.dart';
import 'package:radar_labor/app/screens/worker_summary_kpi_cards.dart';
import 'package:radar_labor/app/screens/worker_summary_leaves_section.dart';
import 'package:radar_labor/app/screens/worker_summary_loader.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/events/event_repository.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/status/worker_summary_calculator.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

class WorkerSummarySheet extends ConsumerStatefulWidget {
  const WorkerSummarySheet({required this.worker, required this.arabic, super.key});
  final Employee worker;
  final bool arabic;

  static Future<void> show(BuildContext context, {required Employee worker, required bool arabic}) =>
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => WorkerSummarySheet(worker: worker, arabic: arabic));

  @override
  ConsumerState<WorkerSummarySheet> createState() => _WorkerSummarySheetState();
}

class _WorkerSummarySheetState extends ConsumerState<WorkerSummarySheet> {
  WorkerSummary? _summary;
  bool _isAbsentToday = false;
  String? _todayDate;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await WorkerSummaryLoader.load(
      database: ref.read(appDatabaseProvider), events: ref.read(eventRepositoryProvider),
      leaves: ref.read(leaveRepositoryProvider), employeeUid: widget.worker.employeeUid,
      jobCategory: widget.worker.jobCategory, clock: ref.read(clockProvider),
    );
    if (mounted) setState(() { _summary = res.summary; _isAbsentToday = res.isAbsentToday; _todayDate = res.todayDate; _loading = false; });
  }

  Future<void> _toggleAbsenceToday() async {
    if (_todayDate == null) return;
    await ref.read(eventRepositoryProvider).append(EventDraft(
      businessDate: _todayDate!, type: EventType.housingAbsent,
      action: _isAbsentToday ? EventAction.clear : EventAction.set,
      housingId: HousingConstants.defaultHousingId, employeeUid: widget.worker.employeeUid, userId: ref.read(currentSessionProvider)?.id,
    ));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _summary == null) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    final actor = ref.read(currentSessionProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
      builder: (context, c) => ListView(controller: c, padding: const EdgeInsets.all(AppTokens.space16), children: [
        WorkerSummaryHeader(worker: widget.worker, isAbsentToday: _isAbsentToday, arabic: widget.arabic, onToggleAbsenceToday: _toggleAbsenceToday),
        const SizedBox(height: AppTokens.space12),
        WorkerSummaryKpiCards(summary: _summary!, arabic: widget.arabic),
        const SizedBox(height: AppTokens.space8),
        WorkerSummaryLeavesSection(
          leaves: _summary!.activeLeaves, arabic: widget.arabic,
          onAddLeave: () => WorkerLeaveDialog.show(context, employeeUid: widget.worker.employeeUid, actorUserId: actor?.id, arabic: widget.arabic)
              .then((l) => l != null ? ref.read(leaveRepositoryProvider).addLeave(l).then((_) => _load()) : null),
          onDeleteLeave: (id) => ref.read(leaveRepositoryProvider).deleteLeave(id, actorUserId: actor?.id ?? '').then((_) => _load()),
        ),
      ]),
    );
  }
}
