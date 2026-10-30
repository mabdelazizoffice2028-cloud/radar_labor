import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/features/dashboard/domain/daily_report_generator.dart';

void main() {
  group('DailyReportGenerator (Phase 3 WhatsApp Report)', () {
    test('generates localized text with totals and breakdowns without Iqamas', () {
      final text = DailyReportGenerator.generate(
        date: '2026-10-29',
        totalPresent: 45,
        totalAbsent: 5,
        totalUnreviewed: 2,
        companyPresent: 30,
        rentalPresentByCompany: {'شركة الفرسان': 10, 'شركة الأفق': 5},
        arabic: true,
      );

      expect(text, contains('2026-10-29'));
      expect(text, contains('إجمالي الحضور: 45'));
      expect(text, contains('إجمالي الغياب: 5'));
      expect(text, contains('غير مراجع: 2'));
      expect(text, contains('عمالة الشركة: 30'));
      expect(text, contains('شركة الفرسان: 10'));
      expect(text, contains('شركة الأفق: 5'));
      expect(RegExp(r'\b\d{10}\b').hasMatch(text), isFalse);
    });

    test('generates English report text cleanly', () {
      final text = DailyReportGenerator.generate(
        date: '2026-10-29',
        totalPresent: 20,
        totalAbsent: 2,
        totalUnreviewed: 0,
        companyPresent: 15,
        rentalPresentByCompany: {'Al-Forsan': 5},
        arabic: false,
      );

      expect(text, contains('Daily Operations Report'));
      expect(text, contains('Total Present: 20'));
      expect(text, contains('Total Absent: 2'));
      expect(text, isNot(contains('Unreviewed')));
      expect(text, contains('Company Direct: 15'));
      expect(text, contains('Al-Forsan: 5'));
    });
  });
}
