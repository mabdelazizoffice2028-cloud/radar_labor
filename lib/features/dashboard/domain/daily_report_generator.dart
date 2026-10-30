import 'package:radar_labor/core/time/business_date.dart';

final class DailyReportGenerator {
  static String generate({
    required String date,
    required int totalPresent,
    required int totalAbsent,
    required int totalUnreviewed,
    required int companyPresent,
    required Map<String, int> rentalPresentByCompany,
    bool arabic = true,
  }) {
    final isFriday = isFridayBusinessDate(date);
    final b = StringBuffer();
    if (arabic) {
      b.writeln(isFriday ? '📋 *تقرير العمل الإضافي — يوم الجمعة*' : '📋 *تقرير العمليات والتشغيل اليومي*');
      b.writeln('📅 التاريخ: $date\n━━━━━━━━━━━━━━━━━');
      b.writeln(isFriday ? '✅ إجمالي عمالة الإضافي: $totalPresent' : '✅ إجمالي الحضور: $totalPresent');
      if (!isFriday) b.writeln('❌ إجمالي الغياب: $totalAbsent');
      if (totalUnreviewed > 0 && !isFriday) b.writeln('⚠️ غير مراجع: $totalUnreviewed');
      b.writeln('━━━━━━━━━━━━━━━━━\n👥 *تفصيل عمالة الحضور:*');
      b.writeln('• عمالة الشركة: $companyPresent');
      if (rentalPresentByCompany.isNotEmpty) {
        b.writeln('• عمالة التأجير:');
        for (final e in rentalPresentByCompany.entries) {
          b.writeln('  - ${e.key.isEmpty ? "أخرى" : e.key}: ${e.value}');
        }
      }
    } else {
      b.writeln(isFriday ? '📋 *Friday Overtime Report*' : '📋 *Daily Operations Report*');
      b.writeln('📅 Date: $date\n━━━━━━━━━━━━━━━━━');
      b.writeln(isFriday ? '✅ Total Overtime Workers: $totalPresent' : '✅ Total Present: $totalPresent');
      if (!isFriday) b.writeln('❌ Total Absent: $totalAbsent');
      if (totalUnreviewed > 0 && !isFriday) b.writeln('⚠️ Unreviewed: $totalUnreviewed');
      b.writeln('━━━━━━━━━━━━━━━━━\n👥 *Present Breakdown:*');
      b.writeln('• Company Direct: $companyPresent');
      if (rentalPresentByCompany.isNotEmpty) {
        b.writeln('• Rental Workforce:');
        for (final e in rentalPresentByCompany.entries) {
          b.writeln('  - ${e.key.isEmpty ? "Other" : e.key}: ${e.value}');
        }
      }
    }
    return b.toString().trim();
  }
}
