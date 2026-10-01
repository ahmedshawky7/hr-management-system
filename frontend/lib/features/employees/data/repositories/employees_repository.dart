import 'package:dio/dio.dart';
import 'package:hr_management_app/features/employees/data/models/employee_create_request.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/employee_model.dart';

class PaginatedResult<T> {
  final List<T> content;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResult({
    required this.content,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });
}

class EmployeesRepository {
  final DioClient _dioClient;

  EmployeesRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Fetch employees with pagination.
  /// [page] is 1-based (default 1)
  Future<PaginatedResult<Employee>> getEmployees({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.employees,
        queryParameters: {'page': page, 'size': size},
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        final paginated = data['data'] as Map<String, dynamic>;
        final content = (paginated['content'] as List)
            .map((e) => Employee.fromJson(e as Map<String, dynamic>))
            .toList();

        return PaginatedResult<Employee>(
          content: content,
          currentPage: paginated['currentPage'] as int? ?? 0,
          totalPages: paginated['totalPages'] as int? ?? 1,
          totalItems: paginated['totalItems'] as int? ?? 0,
          hasNext: paginated['hasNext'] as bool? ?? false,
          hasPrevious: paginated['hasPrevious'] as bool? ?? false,
        );
      }

      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
    Future<Employee> create(EmployeeCreateRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.employees,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        return Employee.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  Future<Employee> getEmployeeById(int id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.employees}/$id');

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        return Employee.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
    /// Update employee basic info.
  Future<Employee> update({
    required int employeeId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String position,
    int? managerId,
    bool clearManager = false,
    int? departmentId,   // 🌟 جديد
  }) async {
    try {
      final map = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'position': position,
      };
      if (clearManager) {
        map['clearManager'] = true;
      } else if (managerId != null) {
        map['managerId'] = managerId;
      }
      if (departmentId != null) {        // 🌟 جديد
        map['departmentId'] = departmentId;
      }

      final response = await _dioClient.dio.put(
        '${ApiConstants.employees}/$employeeId',
        data: map,
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        return Employee.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Update employee role. Requires SUPER_ADMIN or HR_ADMIN.
  Future<void> updateRole({
    required int employeeId,
    required String role, // SUPER_ADMIN, HR_ADMIN, MANAGER, EMPLOYEE
  }) async {
    try {
      await _dioClient.dio.put(
        '${ApiConstants.employees}/$employeeId/role',
        data: {'role': role},
      );
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Delete an employee. Requires SUPER_ADMIN or HR_ADMIN.
  Future<void> delete(int employeeId) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.employees}/$employeeId');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Get a simple list of employees for dropdowns (max 100).
  Future<List<Employee>> getAllForDropdown() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.employees,
        queryParameters: {'page': 1, 'size': 100},
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        final paginated = data['data'] as Map<String, dynamic>;
        return (paginated['content'] as List)
            .map((e) => Employee.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
}