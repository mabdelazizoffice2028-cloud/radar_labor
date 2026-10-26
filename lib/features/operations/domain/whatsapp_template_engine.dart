import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/core/l10n/bidi.dart';

enum WhatsappMessageKind { site, housing }

final class WhatsappWorkerItem {
  const WhatsappWorkerItem({required this.code, required this.name});

  final String code;
  final String name;
}

/// Pure WhatsApp message formatter with Unicode bidirectional isolation for Arabic (PRD §12).
abstract final class WhatsappTemplateEngine {
  static String format({
    required WhatsappMessageKind kind,
    required String date,
    required String entityName,
    required List<WhatsappWorkerItem> workers,
    required bool arabic,
    required AttendanceMessageStrings strings,
  }) {
    final count = workers.length;
    if (!arabic) {
      final entityLabel = kind == WhatsappMessageKind.site
          ? strings.teamLabel
          : strings.housingLabel;
      final totalLabel = kind == WhatsappMessageKind.site
          ? strings.totalPresent
          : strings.totalAbsent;
      final emptyText = kind == WhatsappMessageKind.site
          ? strings.noPresence
          : strings.noAbsences;

      final body = workers.isEmpty
          ? emptyText
          : [
              '${strings.workersLabel}:',
              for (var i = 0; i < workers.length; i++)
                '${i + 1}. ${workers[i].code} - ${workers[i].name}',
            ].join('\n');

      return [
        '${strings.dateLabel}: $date',
        '$entityLabel: $entityName',
        '$totalLabel: $count',
        '',
        body,
        '',
        strings.footer,
      ].join('\n');
    }

    final entityLabel = kind == WhatsappMessageKind.site
        ? strings.teamLabel
        : strings.housingLabel;
    final totalLabel = kind == WhatsappMessageKind.site
        ? strings.totalPresent
        : strings.totalAbsent;
    final emptyText = kind == WhatsappMessageKind.site
        ? strings.noPresence
        : strings.noAbsences;

    final isolatedDate = Bidi.isolateLtr(date);
    final bodyLines = workers.isEmpty
        ? <String>[Bidi.rtlLine(emptyText)]
        : <String>[
            Bidi.rtlLine('${strings.workersLabel}:'),
            for (var i = 0; i < workers.length; i++)
              Bidi.rtlLine(
                '${i + 1}. ${Bidi.isolateLtr(workers[i].code)} - ${workers[i].name}',
              ),
          ];

    return [
      Bidi.rtlLine('${strings.dateLabel}: $isolatedDate'),
      Bidi.rtlLine('$entityLabel: $entityName'),
      Bidi.rtlLine('$totalLabel: $count'),
      '',
      ...bodyLines,
      '',
      Bidi.rtlLine(strings.footer),
    ].join('\n');
  }
}
