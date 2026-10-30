import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final class PreparedHousingCheck {
  const PreparedHousingCheck({
    required this.housing,
    required this.date,
    required this.summary,
  });

  final EntityOption housing;
  final String date;
  final AttendanceSummary summary;
}

final class PreparedSiteAttendance {
  const PreparedSiteAttendance({
    required this.team,
    required this.date,
    required this.summary,
  });

  final EntityOption team;
  final String date;
  final AttendanceSummary summary;
}
