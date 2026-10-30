import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/status/staff_category_resolver.dart';

void main() {
  group('StaffCategoryResolver', () {
    test('identifies staff roles in English and Arabic', () {
      expect(StaffCategoryResolver.isAutoPresentStaff('Site Engineer'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('Safety Officer'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('HR Manager'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('Project Admin'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('General Foreman'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('مهندس مدني'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('مسؤول سلامة'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('موارد بشرية'), isTrue);
      expect(StaffCategoryResolver.isAutoPresentStaff('إداري'), isTrue);
    });

    test('rejects direct labor and worker categories', () {
      expect(StaffCategoryResolver.isAutoPresentStaff('direct_labor'), isFalse);
      expect(StaffCategoryResolver.isAutoPresentStaff('worker'), isFalse);
      expect(StaffCategoryResolver.isAutoPresentStaff(''), isFalse);
      expect(StaffCategoryResolver.isAutoPresentStaff('Carpenter'), isFalse);
      expect(StaffCategoryResolver.isAutoPresentStaff('Electrician'), isFalse);
    });
  });
}
