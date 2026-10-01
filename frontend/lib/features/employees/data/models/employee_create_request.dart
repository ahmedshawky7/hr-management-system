class EmployeeCreateRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String position;
  final String hireDate; // YYYY-MM-DD
  final int departmentId;
  final int? managerId;

  EmployeeCreateRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.position,
    required this.hireDate,
    required this.departmentId,
    this.managerId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'position': position,
      'hireDate': hireDate,
      'departmentId': departmentId,
    };
    if (managerId != null) map['managerId'] = managerId;
    return map;
  }
}