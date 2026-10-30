import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';

/// Backward compatibility helpers for Employee domain mapping.
extension EmployeeCompat on Employee {
  String get employeeUid => iqamaNo;
  String get employeeCode => iqamaNo;
  bool get isActive => archivedAt == null;
  String? get housingId => HousingConstants.defaultHousingId;
  String? get supplier => rentalCompany;
  String get category => jobCategory;
}

extension EmploymentPeriodCompat on EmploymentPeriod {
  String get employeeUid => iqamaNo;
}
