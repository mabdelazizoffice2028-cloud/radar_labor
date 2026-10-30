import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/bidi.dart';
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
      employmentType: 'company',
      jobCategory: 'direct_labor',
    ),
    WorkerOption(
      id: 'worker-2',
      code: 'W-02',
      nameAr: 'عامل ثان',
      nameEn: 'Worker Two',
      employmentType: 'company',
      jobCategory: 'direct_labor',
    ),
    WorkerOption(
      id: 'worker-3',
      code: 'W-03',
      nameAr: 'مشغل رافعة',
      nameEn: 'Crane Operator',
      employmentType: 'rental',
      jobCategory: 'operator',
    ),
  ];

  test('siteSummary_usesSelectedWorkersAndEnglishWhatsappTemplate', () {
    final summary = AttendanceSummary.siteAttendance(
      team: team,
      date: '2026-10-23',
      workers: workers,
      presentIds: {'worker-2'},
      arabic: false,
      strings: const AttendanceMessageStrings.english(),
      supervisorName: 'Ahmed',
    );

    expect(summary.workerCount, 1);
    expect(summary.workerIds, {'worker-2'});
    expect(summary.confirmationText, 'Worker Two (W-02)');
    expect(
      summary.messageText,
      [
        '2026-10-23',
        'Team Attendance: Site team',
        'Supervisor: Ahmed',
        '',
        'Workers (Labor):',
        '1. W-02 - Worker Two',
      ].join('\n'),
    );
  });

  test('siteSummary_arabicTemplateIncludesBidiIsolationAndLatinNumbering', () {
    final summary = AttendanceSummary.siteAttendance(
      team: team,
      date: '2026-10-23',
      workers: workers,
      presentIds: {'worker-2', 'worker-1'},
      arabic: true,
      strings: const AttendanceMessageStrings.arabic(),
      supervisorName: 'أحمد',
    );

    expect(summary.workerCount, 2);
    expect(
      summary.messageText,
      [
        '${Bidi.rlm}${Bidi.lri}2026-10-23${Bidi.pdi}',
        '${Bidi.rlm}حضور فريق: فريق الموقع',
        '${Bidi.rlm}المشرف: أحمد',
        '',
        '${Bidi.rlm}العمال (Labor):',
        '${Bidi.rlm}1. ${Bidi.lri}W-01${Bidi.pdi} - عامل أول',
        '${Bidi.rlm}2. ${Bidi.lri}W-02${Bidi.pdi} - عامل ثان',
      ].join('\n'),
    );
  });

  test('siteSummary_withOperatorIncludesOperatorSectionInArabic', () {
    final summary = AttendanceSummary.siteAttendance(
      team: team,
      date: '2026-10-23',
      workers: workers,
      presentIds: {'worker-1', 'worker-3'},
      arabic: true,
      strings: const AttendanceMessageStrings.arabic(),
      supervisorName: 'أحمد',
    );

    expect(summary.workerCount, 2);
    expect(
      summary.messageText,
      [
        '${Bidi.rlm}${Bidi.lri}2026-10-23${Bidi.pdi}',
        '${Bidi.rlm}حضور فريق: فريق الموقع',
        '${Bidi.rlm}المشرف: أحمد',
        '',
        '${Bidi.rlm}العمال (Labor):',
        '${Bidi.rlm}1. ${Bidi.lri}W-01${Bidi.pdi} - عامل أول',
        '',
        '${Bidi.rlm}مشغلي المعدات (Operator):',
        '${Bidi.rlm}1. ${Bidi.lri}W-03${Bidi.pdi} - مشغل رافعة',
      ].join('\n'),
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
      supervisorName: 'أحمد',
    );

    expect(summary.workerCount, 0);
    expect(summary.workerIds, isEmpty);
    expect(
      summary.confirmationText,
      'لم تحدد عمالًا. هل تسجل الفريق بصفر حضور؟',
    );
    expect(
      summary.messageText,
      [
        '${Bidi.rlm}${Bidi.lri}2026-10-23${Bidi.pdi}',
        '${Bidi.rlm}حضور فريق: فريق الموقع',
        '${Bidi.rlm}المشرف: أحمد',
        '',
        '${Bidi.rlm}العمال (Labor):',
        '${Bidi.rlm}0',
      ].join('\n'),
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
      [
        'Absent Today: 2026-10-23',
        '',
        'Company Workers:',
        '0',
        '',
        'Rental Workers:',
        '0',
      ].join('\n'),
    );
  });

  test('housingSummary_arabicAbsenceShowsCompanyAndRentalGroups', () {
    final summary = AttendanceSummary.housingCheck(
      housing: const EntityOption(
        id: 'housing-1',
        nameAr: 'السكن',
        nameEn: 'Housing',
      ),
      date: '2026-10-23',
      workers: workers,
      absentIds: {'worker-1', 'worker-3'},
      arabic: true,
      strings: const AttendanceMessageStrings.arabic(),
    );

    expect(summary.workerCount, 2);
    expect(
      summary.messageText,
      [
        '${Bidi.rlm}غياب اليوم: ${Bidi.lri}2026-10-23${Bidi.pdi}',
        '',
        '${Bidi.rlm}عمال الشركة:',
        '${Bidi.rlm}1. ${Bidi.lri}W-01${Bidi.pdi} - عامل أول',
        '',
        '${Bidi.rlm}عمال الإيجار:',
        '${Bidi.rlm}1. ${Bidi.lri}W-03${Bidi.pdi} - مشغل رافعة',
      ].join('\n'),
    );
  });
}
