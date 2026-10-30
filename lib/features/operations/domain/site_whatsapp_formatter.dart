import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

abstract final class SiteWhatsappFormatter {
  static String format({
    required String date,
    required String teamName,
    required List<WhatsappWorkerItem> workers,
    required bool arabic,
    String? supervisorName,
  }) {
    final labor = workers.where((w) => !w.isOperator).toList();
    final operators = workers.where((w) => w.isOperator).toList();

    if (!arabic) {
      final s = supervisorName?.trim();
      final supervisor = (s != null && s.isNotEmpty) ? s : 'Unassigned';
      final lines = <String>[
        date,
        'Team Attendance: $teamName',
        'Supervisor: $supervisor',
        '',
        'Workers (Labor):',
      ];
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
    final lines = <String>[
      '${Bidi.rlm}${Bidi.isolateLtr(date)}',
      '${Bidi.rlm}حضور فريق: $teamName',
      '${Bidi.rlm}المشرف: $supervisor',
      '',
      '${Bidi.rlm}العمال (Labor):',
    ];
    if (labor.isEmpty) {
      lines.add('${Bidi.rlm}0');
    } else {
      for (var i = 0; i < labor.length; i++) {
        lines.add(
          '${Bidi.rlm}${i + 1}. ${Bidi.isolateLtr(labor[i].code)} - ${labor[i].name}',
        );
      }
    }
    if (operators.isNotEmpty) {
      lines.addAll(['', '${Bidi.rlm}مشغلي المعدات (Operator):']);
      for (var i = 0; i < operators.length; i++) {
        lines.add(
          '${Bidi.rlm}${i + 1}. ${Bidi.isolateLtr(operators[i].code)} - ${operators[i].name}',
        );
      }
    }
    return lines.join('\n');
  }
}
