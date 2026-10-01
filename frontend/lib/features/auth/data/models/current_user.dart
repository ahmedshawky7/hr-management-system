import 'package:equatable/equatable.dart';

class CurrentUser extends Equatable {
  final int id;
  final String username;
  final String role;
  final int? employeeId;

  const CurrentUser({
    required this.id,
    required this.username,
    required this.role,
    this.employeeId,
  });

  bool get isEmployee => role == 'EMPLOYEE';
  bool get isAdmin => role == 'SUPER_ADMIN' || role == 'HR_ADMIN';
  bool get isManager => role == 'MANAGER';

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? 'EMPLOYEE',
      employeeId: json['employeeId'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, username, role, employeeId];
}