import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/features/operations/domain/attendance_summary.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

void main() {
  const team = EntityOption(
    id: 'team-1',
    nameAr: 'فريق الموقع',
    nameEn: 'Site team',
  );
  const workers = [
    WorkerOption(
      id: 'worker-1',
      code: 'W-01',
      nameAr: 'عامل أول',
      nameEn: 'Worker One',
    ),
    WorkerOption(
      id: 'worker-2',
      code: 'W-02',
      nameAr: 'عامل ثان',
      nameEn: 'Worker Two',
    ),
  ];

  test('siteSummary_usesSelectedWorkersAndEnglishNames', () {
    final summary = AttendanceSummary.siteAttendance(
      team: team,
      date: '2026-10-23',
      workers: workers,
      presentIds: {'worker-2'},
      arabic: false,
      strings: const AttendanceMessageStrings.english(),
    );

    expect(summary.workerCount, 1);
    expect(summary.workerIds, {'worker-2'});
    expect(summary.confirmationText, 'Worker Two (W-02)');
    expect(
      summary.messageText,
      'Site team\n2026-10-23\nPresent workers: 1\nWorker Two (W-02)',
    );
  });

  test('siteSummary_zeroWorkersHasExplicitArabicMessage', () {
    final summary = AttendanceSummary.siteAttendance(
      team: team,
      date: '2026-10-23',
      workers: workers,
      presentIds: {},
      arabic: true,
      strings: const AttendanceMessageStrings.arabic(),
    );

    expect(summary.workerCount, 0);
    expect(summary.workerIds, isEmpty);
    expect(
      summary.confirmationText,
      'لم تحدد عمالًا. هل تسجل الفريق بصفر حضور؟',
    );
    expect(
      summary.messageText,
      'فريق الموقع\n2026-10-23\nعدد الحاضرين: 0\nلا يوجد حاضرين',
    );
  });

  test('housingSummary_zeroAbsencesHasExplicitEnglishMessage', () {
    final summary = AttendanceSummary.housingCheck(
      housing: const EntityOption(
        id: 'housing-1',
        nameAr: 'السكن',
        nameEn: 'Housing',
      ),
      date: '2026-10-23',
      workers: workers,
      absentIds: {},
      arabic: false,
      strings: const AttendanceMessageStrings.english(),
    );

    expect(summary.workerCount, 0);
    expect(summary.confirmationText, 'Confirm that nobody is absent?');
    expect(
      summary.messageText,
      'Housing\n2026-10-23\nAbsent workers: 0\nNo absences',
    );
  });
}
