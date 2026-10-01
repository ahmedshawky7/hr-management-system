import 'leave_status.dart';

class LeaveRequest {
  final int id;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveStatus status;
  final int employeeId;

  LeaveRequest({
    required this.id,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.employeeId,
  });

  int get daysCount => endDate.difference(startDate).inDays + 1;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as int,
      reason: json['reason'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: LeaveStatus.fromString(json['status'] as String?),
      employeeId: json['employeeId'] as int? ?? 0,
    );
  }
}