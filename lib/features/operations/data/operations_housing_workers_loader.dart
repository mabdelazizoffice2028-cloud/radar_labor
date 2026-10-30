import 'dart:convert';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/leaves/worker_leave.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

abstract final class OperationsHousingWorkersLoader {
  static Future<List<WorkerOption>> load(
    AppDatabase database,
    String housingId, {
    String? date,
  }) async {
    final rows = await (database.select(database.employees)
          ..where((r) => r.archivedAt.isNull()))
        .get();
    if (date == null) return _toWorkers(rows);

    final leavesSetting = await (database.select(database.settings)
          ..where((s) => s.key.equals(AppSettingKeys.workerLeaves)))
        .getSingleOrNull();
    final onLeave = _parseOnLeave(leavesSetting?.value, date);
    final active = rows.where((r) => !onLeave.contains(r.employeeUid)).toList();
    return _toWorkers(active);
  }

  static Set<String> _parseOnLeave(String? raw, String date) {
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => WorkerLeave.fromJson(e as Map<String, dynamic>))
          .where((l) => l.coversDate(date))
          .map((l) => l.employeeUid)
          .toSet();
    } on Exception {
      return const {};
    }
  }

  static List<WorkerOption> _toWorkers(List<Employee> rows) => List.unmodifiable(
    rows.map((r) => WorkerOption(
      id: r.employeeUid,
      code: r.employeeCode,
      nameAr: r.fullNameAr,
      nameEn: r.fullNameEn,
      employmentType: r.employmentType,
      jobCategory: r.jobCategory,
    )),
  );
}
