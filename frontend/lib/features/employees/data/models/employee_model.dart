class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime hireDate;
  final String position;
  final int departmentId;
  final int? managerId;
  final bool isVerified;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.hireDate,
    required this.position,
    required this.departmentId,
    this.managerId,
    required this.isVerified,
  });

  String get fullName => '$firstName $lastName';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      hireDate: DateTime.parse(json['hireDate'] as String),
      position: json['position'] as String? ?? '',
      departmentId: json['departmentId'] as int? ?? 0,
      managerId: json['managerId'] as int?,
      isVerified: json['verified'] as bool? ?? false,
    );
  }
}