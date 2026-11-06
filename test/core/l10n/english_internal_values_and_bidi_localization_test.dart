import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/constants/employment_constants.dart';
import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/status/local_event.dart';
import 'package:radar_labor/core/status/worker_status_result.dart';
import 'package:radar_labor/features/operations/domain/housing_whatsapp_formatter.dart';
import 'package:radar_labor/features/operations/domain/site_whatsapp_formatter.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

void main() {
  group('Section 4: English Internal Values (DB & Ledger)', () {
    test('All internal enums and system keys are strictly ASCII English', () {
      final asciiRegex = RegExp(r'^[a-zA-Z0-9_]+$');

      for (final type in EventType.values) {
        expect(type.name, matches(asciiRegex), reason: 'EventType.${type.name} must be English');
      }

      for (final action in EventAction.values) {
        expect(action.name, matches(asciiRegex), reason: 'EventAction.${action.name} must be English');
      }

      for (final res in ResolutionKind.values) {
        expect(res.key, matches(asciiRegex), reason: 'ResolutionKind.${res.key} must be English');
      }

      for (final status in WorkerStatus.values) {
        expect(status.name, matches(asciiRegex), reason: 'WorkerStatus.${status.name} must be English');
      }

      for (final role in AuthRole.values) {
        expect(role.name, matches(asciiRegex), reason: 'AuthRole.${role.name} must be English');
      }

      for (final delivery in EventDelivery.values) {
        expect(delivery.name, matches(asciiRegex), reason: 'EventDelivery.${delivery.name} must be English');
      }

      expect(HousingConstants.defaultHousingId, matches(asciiRegex));
      expect(EmploymentConstants.company, 'company');
      expect(EmploymentConstants.rental, 'rental');
    });

    test('Employment normalization converts Arabic input to internal English values', () {
      expect(EmploymentConstants.normalize('إيجار'), 'rental');
      expect(EmploymentConstants.normalize('ايجار'), 'rental');
      expect(EmploymentConstants.normalize('RENTAL'), 'rental');
      expect(EmploymentConstants.normalize('شركة'), 'company');
      expect(EmploymentConstants.normalize('COMPANY'), 'company');
      expect(EmploymentConstants.normalize('direct_hire'), 'company');
      expect(EmploymentConstants.normalize(null), 'company');
    });
  });

  group('Section 4: Presentation Localization & BiDi Formatting', () {
    test('AuthRole labels provide distinct Arabic and English names without leaking raw keys', () {
      for (final role in AuthRole.values) {
        final ar = role.label(arabic: true);
        final en = role.label(arabic: false);
        expect(ar.isNotEmpty, isTrue);
        expect(en.isNotEmpty, isTrue);
        expect(ar, isNot(equals(role.name)));
        expect(en, isNot(equals(role.name)));
      }
    });

    test('Site WhatsApp report renders correctly in English (LTR) and Arabic (RTL with BiDi)', () {
      final workers = [
        const WhatsappWorkerItem(code: '10987', name: 'أحمد علي', employmentType: EmploymentConstants.company, jobCategory: 'direct_labor'),
        const WhatsappWorkerItem(code: '10988', name: 'سائق رافعة', employmentType: EmploymentConstants.rental, jobCategory: 'operator'),
      ];

      final enReport = SiteWhatsappFormatter.format(
        date: '2026-11-05',
        teamName: 'Team Alpha',
        workers: workers,
        arabic: false,
        supervisorName: 'John Doe',
      );

      expect(enReport, contains('Team Attendance: Team Alpha'));
      expect(enReport, contains('Supervisor: John Doe'));
      expect(enReport, contains('Workers (Labor):'));
      expect(enReport, contains('1. 10987 - أحمد علي'));
      expect(enReport, contains('Equipment Operators (Operator):'));
      expect(enReport, contains('1. 10988 - سائق رافعة'));

      final arReport = SiteWhatsappFormatter.format(
        date: '2026-11-05',
        teamName: 'فريق ألفا',
        workers: workers,
        arabic: true,
        supervisorName: 'مشرف الموقع',
      );

      expect(arReport, contains('حضور فريق: فريق ألفا'));
      expect(arReport, contains('المشرف: مشرف الموقع'));
      expect(arReport, contains('العمال (Labor):'));
      expect(arReport, contains(Bidi.rlm));
      expect(arReport, contains(Bidi.isolateLtr('10987')));
      expect(arReport, contains('أحمد علي'));
      expect(arReport, contains('مشغلي المعدات (Operator):'));
      expect(arReport, contains(Bidi.isolateLtr('10988')));
    });

    test('Housing WhatsApp report separates company and rental in both locales', () {
      final workers = [
        const WhatsappWorkerItem(code: '101', name: 'عامل شركة', employmentType: EmploymentConstants.company),
        const WhatsappWorkerItem(code: '102', name: 'عامل إيجار', employmentType: EmploymentConstants.rental),
      ];

      final enReport = HousingWhatsappFormatter.format(
        date: '2026-11-06',
        workers: workers,
        arabic: false,
      );
      expect(enReport, contains('Absent Today: 2026-11-06'));
      expect(enReport, contains('Company Workers:'));
      expect(enReport, contains('1. 101 - عامل شركة'));
      expect(enReport, contains('Rental Workers:'));
      expect(enReport, contains('1. 102 - عامل إيجار'));

      final arReport = HousingWhatsappFormatter.format(
        date: '2026-11-06',
        workers: workers,
        arabic: true,
      );
      expect(arReport, contains('غياب اليوم:'));
      expect(arReport, contains('عمال الشركة:'));
      expect(arReport, contains('1. ${Bidi.isolateLtr('101')} - عامل شركة'));
      expect(arReport, contains('عمال الإيجار:'));
      expect(arReport, contains('1. ${Bidi.isolateLtr('102')} - عامل إيجار'));
    });
  });
}
