import 'package:radar_labor/features/roster/domain/workforce_row.dart';

final class WorkforceImportValidator {
  static final RegExp _iqamaRegex = RegExp(r'^\d{10}$');

  static void validate(List<WorkforceRow> rows) {
    final seen = <String>{};
    for (final r in rows) {
      final code = r.code.trim();
      if (!_iqamaRegex.hasMatch(code)) {
        throw FormatException('رقم الإقامة غير صالح (يجب 10 أرقام): $code');
      }
      if (!seen.add(code)) {
        throw FormatException('رقم إقامة مكرر داخل ملف الاستيراد: $code');
      }
    }
  }
}
