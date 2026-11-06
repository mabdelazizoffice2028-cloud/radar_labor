import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/domain/site_attendance_store.dart';
import 'package:radar_labor/features/operations/domain/worker_search_filter.dart';
import 'package:radar_labor/features/operations/presentation/state/site_attendance_state.dart';

void main() {
  group('Phase 4: Partial Search & Unified Arabic Collation', () {
    test('Unified Arabic collation normalizes all hamza forms to alef', () {
      final forms = ['أحمد', 'إحمد', 'آحمد', 'ءحمد', 'ئحمد', 'ؤحمد'];
      final expected = NameCollation.sortKey('احمد');
      for (final form in forms) {
        expect(NameCollation.sortKey(form), equals(expected));
      }
    });

    test('Unified Arabic collation normalizes ya/alif-maqsura and ta-marbuta/ha', () {
      expect(NameCollation.sortKey('عَلِيّ'), equals(NameCollation.sortKey('على')));
      expect(NameCollation.sortKey('فَاطِمَةُ'), equals(NameCollation.sortKey('فاطمه')));
      expect(NameCollation.sortKey('مُصْطَفَى'), equals(NameCollation.sortKey('مصطفي')));
    });

    test('Strips all diacritics, tatweel, and collapses multiple whitespace', () {
      const raw = '  عَبْدُ   اللّٰـهِ   بن   سَعْدٍ  ';
      expect(NameCollation.sortKey(raw), equals('عبد الله بن سعد'));
    });

    test('WorkerSearchFilter matches anywhere in Arabic, English, code, or Iqama', () {
      const nameAr = 'خالد عبد الرحمن النجار';
      const nameEn = 'Khaled Abdulrahman Al-Najjar';
      const code = 'CR-8821';
      const iqama = '2498765432';

      // Middle of Arabic name
      expect(WorkerSearchFilter.matches(query: 'الرحمن', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isTrue);
      // Last part of Arabic name with hamza variant
      expect(WorkerSearchFilter.matches(query: 'النجار', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isTrue);
      // English middle substring
      expect(WorkerSearchFilter.matches(query: 'dulrah', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isTrue);
      // Code middle substring
      expect(WorkerSearchFilter.matches(query: '88', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isTrue);
      // Iqama last 4 digits
      expect(WorkerSearchFilter.matches(query: '5432', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isTrue);
      // Iqama middle digits
      expect(WorkerSearchFilter.matches(query: '8765', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isTrue);
      // Unmatched query
      expect(WorkerSearchFilter.matches(query: 'مروان', code: code, nameAr: nameAr, nameEn: nameEn, iqamaNo: iqama), isFalse);
    });

    test('Multi-selection de-duplication in SiteAttendanceState prevents duplicates', () {
      const worker1 = WorkerOption(id: 'w1', code: '101', nameAr: 'عامل 1');
      const worker2 = WorkerOption(id: 'w2', code: '102', nameAr: 'عامل 2');

      const row1 = AttendanceRow(worker: worker1, isPresent: true, origin: WorkerRowOrigin.member);
      const row2 = AttendanceRow(worker: worker2, isPresent: false, origin: WorkerRowOrigin.member);
      // Attempting to duplicate row1
      const duplicateRow1 = AttendanceRow(worker: worker1, isPresent: true, origin: WorkerRowOrigin.guest);

      const state = SiteAttendanceState(
        selectedDate: '2026-11-06',
        todayDate: '2026-11-06',
        rows: [row1, row2, duplicateRow1],
      );

      // Set accessors must de-duplicate by worker.id
      expect(state.existingWorkerIds, equals({'w1', 'w2'}));
      expect(state.presentWorkerIds, equals({'w1'}));
      expect(state.selectedActiveWorkerIds, equals({'w1'}));
    });
  });
}
