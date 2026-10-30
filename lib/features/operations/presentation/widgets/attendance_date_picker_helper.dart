import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';

final class AttendanceDatePickerHelper {
  static Future<void> pickDate({
    required BuildContext context,
    required String todayDate,
    required String selectedDate,
    required ValueChanged<String> onDateSelected,
  }) async {
    final today = DateTime.tryParse(todayDate);
    final initial = DateTime.tryParse(selectedDate) ?? today;
    if (today == null || initial == null) return;
    final firstDate = today.subtract(const Duration(days: OperationsConstants.maxBackdateDays));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : (initial.isAfter(today) ? today : initial),
      firstDate: firstDate,
      lastDate: today,
    );
    if (picked == null) return;
    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    onDateSelected(formatted);
  }
}
