import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/time/clock.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';
import 'package:radar_labor/features/dashboard/data/status_snapshot_repository.dart';

part 'dashboard_components.dart';
part 'dashboard_action_sheets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.statusRepository,
    required this.coverageRepository,
    required this.actionsRepository,
    required this.arabic,
    this.canEdit = true,
    super.key,
  });

  final StatusSnapshotRepository statusRepository;
  final DashboardCoverageRepository coverageRepository;
  final DashboardActionsRepository actionsRepository;
  final bool arabic;
  final bool canEdit;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _businessDate = businessDateFor(const SystemClock().nowUtc());
  bool get _ar => widget.arabic;

  Future<void> _pickDate() async {
    final initialDate = DateTime.parse('${_businessDate}T12:00:00');
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: _ar ? 'اختر يوم العمل' : 'Choose business date',
    );
    if (!mounted || selected == null) return;
    setState(() => _businessDate = _toIsoDate(selected));
  }

  String _toIsoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => StreamBuilder<StatusSnapshot>(
    stream: widget.statusRepository.watch(
      arabic: _ar,
      businessDate: _businessDate,
    ),
    builder: (context, state) {
      if (state.hasError) {
        return _MessageState(
          message: _ar ? 'تعذر تحميل لوحة الحالات' : 'Could not load dashboard',
          icon: Icons.error_outline,
        );
      }
      if (!state.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final snapshot = state.requireData;
      final eligible = snapshot.workers.where((row) => row.isEligible);
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DateSelector(date: _businessDate, arabic: _ar, onPressed: _pickDate),
          const SizedBox(height: 12),
          _StatusCards(snapshot: snapshot, arabic: _ar),
          const SizedBox(height: 8),
          StreamBuilder<DashboardCoverage>(
            stream: widget.coverageRepository.watch(_businessDate),
            builder: (context, coverageState) {
              if (coverageState.hasError) {
                return _MessageState(
                  message: _ar
                      ? 'تعذر تحميل تنبيهات التسجيل'
                      : 'Could not load submission warnings',
                  icon: Icons.warning_amber_rounded,
                );
              }
              if (!coverageState.hasData) {
                return const LinearProgressIndicator();
              }
              return _CoverageWarnings(
                coverage: coverageState.requireData,
                arabic: _ar,
              );
            },
          ),
          const SizedBox(height: 12),
          _ConflictSection(
            rows: [
              for (final row in eligible)
                if (row.flags.contains(StatusFlag.housingSiteConflict) ||
                    row.flags.contains(StatusFlag.multipleSiteTeams))
                  row,
            ],
            arabic: _ar,
            onResolve: widget.canEdit ? _resolve : null,
          ),
          _UnknownSection(
            rows: [
              for (final row in eligible)
                if (row.status == WorkerStatus.unknown) row,
            ],
            arabic: _ar,
            onJustify: widget.canEdit ? _justify : null,
          ),
          _IntegritySection(
            rows: [
              for (final row in snapshot.workers)
                if (row.flags.contains(StatusFlag.inactiveWorkerEvent) ||
                    row.flags.contains(StatusFlag.eventOutsideEmployment) ||
                    row.flags.contains(StatusFlag.lateEvent) ||
                    row.flags.contains(StatusFlag.rejectedEvent))
                  row,
            ],
            arabic: _ar,
          ),
        ],
      );
    },
  );

  Future<void> _resolve(WorkerStatusResult row) async {
    final note = TextEditingController();
    try {
      final result =
          await showModalBottomSheet<({ResolutionKind kind, String note})>(
            context: context,
            isScrollControlled: true,
            builder: (context) => _ResolutionSheet(arabic: _ar, note: note),
          );
      if (!mounted || result == null) return;
      await widget.actionsRepository.resolve(
        employeeUid: row.worker.employeeUid,
        businessDate: _businessDate,
        kind: result.kind,
        note: result.note,
      );
    } finally {
      note.dispose();
    }
  }

  Future<void> _justify(WorkerStatusResult row) async {
    final note = TextEditingController();
    try {
      final result = await showModalBottomSheet<({String? quick, String note})>(
        context: context,
        isScrollControlled: true,
        builder: (context) => _JustificationSheet(arabic: _ar, note: note),
      );
      if (!mounted || result == null) return;
      await widget.actionsRepository.justify(
        employeeUid: row.worker.employeeUid,
        businessDate: _businessDate,
        quickReason: result.quick,
        note: result.note,
      );
    } finally {
      note.dispose();
    }
  }
}
