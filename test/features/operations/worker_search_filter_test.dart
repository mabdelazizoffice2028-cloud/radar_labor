import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';

void main() {
  group('WorkerSearchFilter (Phase 4 Partial Search & Unified Collation)', () {
    test('Matches digits anywhere in code or iqama (including last 4 digits)', () {
      const code = '1098765432';
      // Substring at end (last 4 digits)
      expect(WorkerSearchFilter.matches(query: '5432', code: code, nameAr: 'محمد'), isTrue);
      // Substring at start or middle
      expect(WorkerSearchFilter.matches(query: '1098', code: code, nameAr: 'محمد'), isTrue);
      expect(WorkerSearchFilter.matches(query: '8765', code: code, nameAr: 'محمد'), isTrue);
      // Non-matching digits
      expect(WorkerSearchFilter.matches(query: '9999', code: code, nameAr: 'محمد'), isFalse);
    });

    test('Matches substring anywhere in name and ignores hamza / diacritics / ya / ta marbuta', () {
      const name = 'أحمد مُحَمَّد عَلِيّ';
      // Substring in middle of full name
      expect(WorkerSearchFilter.matches(query: 'محمد', code: '101', nameAr: name), isTrue);
      // Search without hamza matches name with hamza (أ -> ا)
      expect(WorkerSearchFilter.matches(query: 'احمد', code: '101', nameAr: name), isTrue);
      // Search with alif maqsura matches ya (ى -> ي)
      expect(WorkerSearchFilter.matches(query: 'على', code: '101', nameAr: name), isTrue);
      // Search with ta marbuta vs ha
      expect(WorkerSearchFilter.matches(query: 'فاطمه', code: '102', nameAr: 'فاطمة الزهراء'), isTrue);
      // English substring anywhere
      expect(WorkerSearchFilter.matches(query: 'med', code: '101', nameAr: name, nameEn: 'Ahmed Mohamed'), isTrue);
      // Non-matching query
      expect(WorkerSearchFilter.matches(query: 'خالد', code: '101', nameAr: name), isFalse);
    });

    test('Queries with less than 2 characters match all rows to prevent sluggish filtering', () {
      expect(WorkerSearchFilter.matches(query: '', code: '101', nameAr: 'علي'), isTrue);
      expect(WorkerSearchFilter.matches(query: ' ', code: '101', nameAr: 'علي'), isTrue);
      expect(WorkerSearchFilter.matches(query: 'م', code: '101', nameAr: 'علي'), isTrue);
    });
  });
}
