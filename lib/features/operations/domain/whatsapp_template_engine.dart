import 'package:radar_labor/core/l10n/attendance_message_strings.dart';
import 'package:radar_labor/features/operations/domain/housing_whatsapp_formatter.dart';
import 'package:radar_labor/features/operations/domain/site_whatsapp_formatter.dart';
import 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

export 'package:radar_labor/features/operations/domain/housing_whatsapp_formatter.dart';
export 'package:radar_labor/features/operations/domain/site_whatsapp_formatter.dart';
export 'package:radar_labor/features/operations/domain/whatsapp_worker_item.dart';

enum WhatsappMessageKind { site, housing }

abstract final class WhatsappTemplateEngine {
  static String format({
    required WhatsappMessageKind kind,
    required String date,
    required String entityName,
    required List<WhatsappWorkerItem> workers,
    required bool arabic,
    AttendanceMessageStrings? strings,
    String? supervisorName,
  }) {
    if (kind == WhatsappMessageKind.housing) {
      return HousingWhatsappFormatter.format(
        date: date,
        workers: workers,
        arabic: arabic,
      );
    }
    return SiteWhatsappFormatter.format(
      date: date,
      teamName: entityName,
      workers: workers,
      supervisorName: supervisorName,
      arabic: arabic,
    );
  }
}
