import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/models/housing_option.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

/// Reference data shown on the names & roles administration screen.
final class AccountsAdminData {
  const AccountsAdminData({
    required this.accounts,
    required this.employees,
    required this.teams,
    required this.housings,
  });

  final List<LocalAccount> accounts;
  final List<Employee> employees;
  final List<Team> teams;
  final List<HousingOption> housings;

  bool get hasSupervisors => accounts.any(
    (a) =>
        a.role == AuthRole.siteSupervisor ||
        a.role == AuthRole.housingSupervisor,
  );
}

/// Parsed roster awaiting the administrator's confirmation.
final class ImportPreview {
  const ImportPreview({required this.rows, required this.supervisorCount});
  final List<WorkforceRow> rows;
  final int supervisorCount;
}

/// Values entered in the add/edit account dialog.
final class AccountFormResult {
  const AccountFormResult({
    required this.displayName,
    required this.role,
    this.employeeUid,
    this.teamIds = const [],
    this.housingIds = const [],
  });

  final String? employeeUid;
  final String displayName;
  final AuthRole role;
  final List<String> teamIds;
  final List<String> housingIds;
}

/// Thrown when removing the only active project manager account.
final class LastManagerException implements Exception {
  const LastManagerException();
}
