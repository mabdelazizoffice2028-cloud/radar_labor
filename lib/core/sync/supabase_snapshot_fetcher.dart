import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseSnapshotFetcher {
  static Future<RemoteRosterSnapshot> fetch(
    SupabaseClient client, {
    required String actorUserId,
  }) async {
    try {
      final dynamic res = await client.from('employees').select();
      final employees = <RemoteEmployeeRow>[];
      if (res is List) {
        for (final row in res) {
          if (row is Map<String, dynamic>) {
            employees.add(RemoteEmployeeRow(
              employeeUid: row['employee_uid']?.toString() ?? '',
              employeeCode: row['employee_code']?.toString() ?? '',
              fullNameAr: row['full_name']?.toString() ?? row['full_name_ar']?.toString() ?? '',
              fullNameEn: row['full_name_en']?.toString(),
              category: row['category']?.toString() ?? 'Worker',
              supplier: row['supplier']?.toString(),
              currentTeamId: row['team_id']?.toString() ?? row['current_team_id']?.toString(),
              housingId: row['housing_id']?.toString(),
              isActive: row['active'] != false && row['is_active'] != false,
              rowVersion: int.tryParse(row['row_version']?.toString() ?? '1') ?? 1,
            ));
          }
        }
      }
      return RemoteRosterSnapshot(
        rosterEpoch: 1, accountActive: true, employees: employees,
      );
    } on OperationException {
      rethrow;
    } on Exception catch (error) {
      debugPrint('Supabase fetchSnapshot error: $error');
      throw const OperationException(DatabaseBusy());
    } catch (error) {
      debugPrint('Supabase fetchSnapshot unexpected error: $error');
      throw const OperationException(DatabaseBusy());
    }
  }
}
