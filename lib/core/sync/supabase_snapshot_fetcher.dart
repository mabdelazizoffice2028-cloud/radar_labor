import 'package:flutter/foundation.dart';
import 'package:radar_labor/core/constants/employment_constants.dart';
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
            final supplier = (row['supplier'] ?? row['rental_company'])?.toString();
            final rawType = row['employment_type']?.toString() ??
                (supplier != null && supplier.trim().isNotEmpty
                    ? EmploymentConstants.rental
                    : EmploymentConstants.company);
            employees.add(RemoteEmployeeRow(
              employeeUid: (row['iqama_no'] ?? row['employee_uid'])?.toString() ?? '',
              employeeCode: (row['iqama_no'] ?? row['employee_code'])?.toString() ?? '',
              fullNameAr: row['full_name']?.toString() ?? row['full_name_ar']?.toString() ?? '',
              fullNameEn: row['full_name_en']?.toString(),
              category: (row['job_category'] ?? row['category'])?.toString() ?? 'direct_labor',
              supplier: supplier,
              employmentType: EmploymentConstants.normalize(rawType),
              currentTeamId: row['team_id']?.toString() ?? row['current_team_id']?.toString(),
              housingId: row['housing_id']?.toString(),
              isActive: row['active'] != false && row['is_active'] != false,
              rowVersion: int.tryParse(row['row_version']?.toString() ?? '1') ?? 1,
            ));
          }
        }
      }
      final epoch = await _readRemoteEpoch(client);
      final active = await _readAccountActive(client, actorUserId);
      return RemoteRosterSnapshot(
        rosterEpoch: epoch, accountActive: active, employees: employees,
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

  static Future<int> _readRemoteEpoch(SupabaseClient client) async {
    try {
      final row = await client.from('settings').select('value').eq('key', 'roster_epoch').maybeSingle();
      return int.tryParse(row?['value']?.toString() ?? '1') ?? 1;
    } on Object catch (e) {
      debugPrint('Supabase _readRemoteEpoch fallback: $e');
      return 1;
    }
  }

  static Future<bool> _readAccountActive(SupabaseClient client, String userId) async {
    if (userId.isEmpty) return true;
    try {
      final row = await client.from('app_users').select('active').eq('user_id', userId).maybeSingle();
      return row == null || row['active'] != false;
    } on Object catch (e) {
      debugPrint('Supabase _readAccountActive fallback: $e');
      return true;
    }
  }
}
