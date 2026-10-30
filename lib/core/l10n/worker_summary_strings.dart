abstract final class WorkerSummaryStrings {
  static String totalDaysWorked(bool ar) => ar ? 'إجمالي أيام العمل' : 'Total Days Worked';
  static String includesJustified(bool ar) => ar ? 'شامل الغياب المبرر' : 'Includes justified absences';
  static String totalDaysAbsent(bool ar) => ar ? 'إجمالي أيام الغياب' : 'Total Unexcused Absences';
  static String teamsHistory(bool ar) => ar ? 'سجل العمل مع الفرق' : 'Teams History';
  static String noTeamsYet(bool ar) => ar ? 'لا يوجد سجل فرق بعد' : 'No team records yet';
  static String leaveManagement(bool ar) => ar ? 'إدارة الإجازات' : 'Leave Management';
  static String addLeave(bool ar) => ar ? 'إضافة إجازة' : 'Add Leave';
  static String noLeavesYet(bool ar) => ar ? 'لا توجد إجازات مسجلة' : 'No leaves recorded yet';
  static String markAbsentToday(bool ar) => ar ? 'تسجيل غياب اليوم' : 'Mark Absent Today';
  static String clearAbsentToday(bool ar) => ar ? 'إلغاء غياب اليوم' : 'Clear Absence Today';
  static String staffAutoPresent(bool ar) => ar ? 'كادر إداري — حضور تلقائي' : 'Staff — Auto Present';
  static String startDate(bool ar) => ar ? 'تاريخ البدء' : 'Start Date';
  static String endDate(bool ar) => ar ? 'تاريخ الانتهاء' : 'End Date';
  static String note(bool ar) => ar ? 'ملاحظة' : 'Note';
  static String save(bool ar) => ar ? 'حفظ' : 'Save';
  static String cancel(bool ar) => ar ? 'إلغاء' : 'Cancel';
  static String leaveDeleted(bool ar) => ar ? 'تم حذف الإجازة' : 'Leave deleted';
  static String leaveAdded(bool ar) => ar ? 'تمت إضافة الإجازة' : 'Leave added';
  static String invalidDateRange(bool ar) =>
      ar ? 'تاريخ الانتهاء يجب أن يكون بعد أو نفس تاريخ البدء' : 'End date must be on or after start date';
  static String daysCount(bool ar, int count) => ar ? '$count يوم' : '$count days';
}
