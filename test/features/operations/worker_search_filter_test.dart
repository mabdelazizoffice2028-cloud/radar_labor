import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';

void main() {
  group('WorkerSearchFilter (Phase 3 Suffix & Name Matching)', () {
    test('4+ digits matches iqama suffix only', () {
      const code = '1098765432';
      expect(WorkerSearchFilter.matches(query: '5432', code: code, nameAr: 'محمد'), isTrue);
      expect(WorkerSearchFilter.matches(query: '65432', code: code, nameAr: 'محمد'), isTrue);
      expect(WorkerSearchFilter.matches(query: '1098', code: code, nameAr: 'محمد'), isFalse);
      expect(WorkerSearchFilter.matches(query: '9876', code: code, nameAr: 'محمد'), isFalse);
    });

    test('Less than 4 digits matches substring in code or names', () {
      const code = '1098765432';
      expect(WorkerSearchFilter.matches(query: '109', code: code, nameAr: 'سعد'), isTrue);
      expect(WorkerSearchFilter.matches(query: '765', code: code, nameAr: 'سعد'), isTrue);
      expect(WorkerSearchFilter.matches(query: 'سعد', code: code, nameAr: 'سعد علي'), isTrue);
      expect(WorkerSearchFilter.matches(query: 'Ali', code: code, nameAr: 'سعد علي', nameEn: 'Saad Ali'), isTrue);
      expect(WorkerSearchFilter.matches(query: 'خالد', code: code, nameAr: 'سعد علي'), isFalse);
    });

    test('Empty query matches all rows', () {
      expect(WorkerSearchFilter.matches(query: '', code: '101', nameAr: 'علي'), isTrue);
      expect(WorkerSearchFilter.matches(query: '   ', code: '101', nameAr: 'علي'), isTrue);
    });
  });
}
