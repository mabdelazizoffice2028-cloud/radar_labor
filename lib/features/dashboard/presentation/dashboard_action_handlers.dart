import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/status/status_models.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_actions_repository.dart';

abstract final class DashboardActionHandlers {
  static Future<void> resolve({
    required BuildContext context,
    required DashboardActionsRepository actionsRepository,
    required WorkerStatusResult row,
    required String businessDate,
    required String actorUserId,
    required WidgetBuilder sheetBuilder,
  }) async {
    final res = await showModalBottomSheet<({ResolutionKind kind, String note})>(
      context: context,
      isScrollControlled: true,
      builder: sheetBuilder,
    );
    if (res == null) return;
    await actionsRepository.resolve(
      employeeUid: row.worker.employeeUid,
      businessDate: businessDate,
      kind: res.kind,
      actorUserId: actorUserId,
      note: res.note,
    );
  }

  static Future<void> justify({
    required BuildContext context,
    required DashboardActionsRepository actionsRepository,
    required WorkerStatusResult row,
    required String businessDate,
    required String actorUserId,
    required WidgetBuilder sheetBuilder,
  }) async {
    final res = await showModalBottomSheet<({String? quick, String note})>(
      context: context,
      isScrollControlled: true,
      builder: sheetBuilder,
    );
    if (res == null) return;
    await actionsRepository.justify(
      employeeUid: row.worker.employeeUid,
      businessDate: businessDate,
      actorUserId: actorUserId,
      quickReason: res.quick,
      note: res.note,
    );
  }
}
