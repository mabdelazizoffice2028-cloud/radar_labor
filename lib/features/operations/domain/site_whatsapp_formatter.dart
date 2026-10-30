import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

abstract final class SiteWhatsappFormatter {
  static String format({
    required String date,
    required String teamName,
    required List<WhatsappWorkerItem> workers,
    required bool arabic,
    String? supervisorName,
  }) {
    final isFriday = isFridayBusinessDate(date);
    final labor = workers.where((w) => !w.isOperator).toList();
    final operators = workers.where((w) => w.isOperator).toList();

    if (!arabic) {
      final s = supervisorName?.trim();
      final supervisor = (s != null && s.isNotEmpty) ? s : 'Unassigned';
      final header = isFriday ? 'Friday Overtime: $teamName' : 'Team Attendance: $teamName';
      final laborTitle = isFriday ? 'Overtime Workers (Labor):' : 'Workers (Labor):';
      final lines = <String>[date, header, 'Supervisor: $supervisor', '', laborTitle];
      if (labor.isEmpty) {
        lines.add('0');
      } else {
        for (var i = 0; i < labor.length; i++) {
          lines.add('${i + 1}. ${labor[i].code} - ${labor[i].name}');
        }
      }
      if (operators.isNotEmpty) {
        lines.addAll(['', 'Equipment Operators (Operator):']);
        for (var i = 0; i < operators.length; i++) {
          lines.add('${i + 1}. ${operators[i].code} - ${operators[i].name}');
        }
      }
      return lines.join('\n');
    }

    final s = supervisorName?.trim();
    final supervisor = (s != null && s.isNotEmpty) ? s : 'غير محدد';
    final header = isFriday ? 'إضافي الجمعة - فريق: $teamName' : 'حضور فريق: $teamName';
    final laborTitle = isFriday ? 'عمال الإضافي (Labor):' : 'العمال (Labor):';
    final lines = <String>[
      '${Bidi.rlm}${Bidi.isolateLtr(date)}',
      '${Bidi.rlm}$header',
      '${Bidi.rlm}المشرف: $supervisor',
      '',
      '${Bidi.rlm}$laborTitle',
    ];
    if (labor.isEmpty) {
      lines.add('${Bidi.rlm}0');
    } else {
      for (var i = 0; i < labor.length; i++) {
        lines.add('${Bidi.rlm}${i + 1}. ${Bidi.isolateLtr(labor[i].code)} - ${labor[i].name}');
      }
    }
    if (operators.isNotEmpty) {
      lines.addAll(['', '${Bidi.rlm}مشغلي المعدات (Operator):']);
      for (var i = 0; i < operators.length; i++) {
        lines.add('${Bidi.rlm}${i + 1}. ${Bidi.isolateLtr(operators[i].code)} - ${operators[i].name}');
      }
    }
    return lines.join('\n');
  }
}
