/// Domain model for an approved worker leave period (retroactive or future).
final class WorkerLeave {
  const WorkerLeave({
    required this.leaveId,
    required this.employeeUid,
    required this.startDate,
    required this.endDate,
    this.note,
    this.createdByUserId,
  });

  final String leaveId;
  final String employeeUid;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final String? note;
  final String? createdByUserId;

  bool coversDate(String businessDate) =>
      businessDate.compareTo(startDate) >= 0 &&
      businessDate.compareTo(endDate) <= 0;

  Map<String, dynamic> toJson() => {
    'leaveId': leaveId,
    'employeeUid': employeeUid,
    'startDate': startDate,
    'endDate': endDate,
    if (note != null) 'note': note,
    if (createdByUserId != null) 'createdByUserId': createdByUserId,
  };

  factory WorkerLeave.fromJson(Map<String, dynamic> json) => WorkerLeave(
    leaveId: json['leaveId'] as String,
    employeeUid: json['employeeUid'] as String,
    startDate: json['startDate'] as String,
    endDate: json['endDate'] as String,
    note: json['note'] as String?,
    createdByUserId: json['createdByUserId'] as String?,
  );
}
