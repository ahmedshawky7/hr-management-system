import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/department_model.dart';

class DepartmentsRepository {
  final DioClient _dioClient;

  DepartmentsRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Department>> getAll() async {
    try {
      final response = await _dioClient.dio.get('/departments');
      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        final list = data['data'] as List;
        return list
            .map((e) => Department.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
  /// Create a new department. Requires SUPER_ADMIN.
  Future<Department> create(String name) async {
    try {
      final response = await _dioClient.dio.post(
        '/departments',
        data: {'name': name},
      );
      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        return Department.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Delete a department by ID. Requires SUPER_ADMIN.
  Future<void> delete(int id) async {
    try {
      await _dioClient.dio.delete('/departments/$id');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
}