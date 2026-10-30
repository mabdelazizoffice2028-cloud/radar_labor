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
    final b = StringBuffer();
    if (arabic) {
      b.writeln('📋 *تقرير العمليات والتشغيل اليومي*');
      b.writeln('📅 التاريخ: $date\n━━━━━━━━━━━━━━━━━');
      b.writeln('✅ إجمالي الحضور: $totalPresent');
      b.writeln('❌ إجمالي الغياب: $totalAbsent');
      if (totalUnreviewed > 0) b.writeln('⚠️ غير مراجع: $totalUnreviewed');
      b.writeln('━━━━━━━━━━━━━━━━━\n👥 *تفصيل عمالة الحضور:*');
      b.writeln('• عمالة الشركة: $companyPresent');
      if (rentalPresentByCompany.isNotEmpty) {
        b.writeln('• عمالة التأجير:');
        for (final e in rentalPresentByCompany.entries) {
          b.writeln('  - ${e.key.isEmpty ? "أخرى" : e.key}: ${e.value}');
        }
      }
    } else {
      b.writeln('📋 *Daily Operations Report*');
      b.writeln('📅 Date: $date\n━━━━━━━━━━━━━━━━━');
      b.writeln('✅ Total Present: $totalPresent');
      b.writeln('❌ Total Absent: $totalAbsent');
      if (totalUnreviewed > 0) b.writeln('⚠️ Unreviewed: $totalUnreviewed');
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
