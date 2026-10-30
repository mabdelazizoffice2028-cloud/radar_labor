import 'package:radar_labor/core/l10n/bidi.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

abstract final class HousingWhatsappFormatter {
  static String format({
    required String date,
    required List<WhatsappWorkerItem> workers,
    required bool arabic,
  }) {
    final company = workers.where((w) => !w.isRental).toList();
    final rental = workers.where((w) => w.isRental).toList();

    if (!arabic) {
      final lines = <String>['Absent Today: $date', '', 'Company Workers:'];
      if (company.isEmpty) {
        lines.add('0');
      } else {
        for (var i = 0; i < company.length; i++) {
          lines.add('${i + 1}. ${company[i].code} - ${company[i].name}');
        }
      }
      lines.addAll(['', 'Rental Workers:']);
      if (rental.isEmpty) {
        lines.add('0');
      } else {
        for (var i = 0; i < rental.length; i++) {
          lines.add('${i + 1}. ${rental[i].code} - ${rental[i].name}');
        }
      }
      return lines.join('\n');
    }

    final lines = <String>[
      '${Bidi.rlm}غياب اليوم: ${Bidi.isolateLtr(date)}',
      '',
      '${Bidi.rlm}عمال الشركة:',
    ];
    if (company.isEmpty) {
      lines.add('${Bidi.rlm}0');
    } else {
      for (var i = 0; i < company.length; i++) {
        lines.add(
          '${Bidi.rlm}${i + 1}. ${Bidi.isolateLtr(company[i].code)} - ${company[i].name}',
        );
      }
    }
    lines.addAll(['', '${Bidi.rlm}عمال الإيجار:']);
    if (rental.isEmpty) {
      lines.add('${Bidi.rlm}0');
    } else {
      for (var i = 0; i < rental.length; i++) {
        lines.add(
          '${Bidi.rlm}${i + 1}. ${Bidi.isolateLtr(rental[i].code)} - ${rental[i].name}',
        );
      }
    }
    return lines.join('\n');
  }
}
