import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/leave_request_model.dart';

class LeavesRepository {
  final DioClient _dioClient;

  LeavesRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Get leave requests for a specific employee.
  Future<List<LeaveRequest>> getByEmployee(int employeeId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.leaveRequests}/employee/$employeeId',
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        final list = data['data'] as List;
        return list
            .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Create a new leave request.
  /// [startDate] and [endDate] must be in YYYY-MM-DD format.
  Future<LeaveRequest> create({
    required int employeeId,
    required String reason,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.leaveRequests}/employee/$employeeId',
        data: {
          'reason': reason,
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        return LeaveRequest.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Cancel a leave request by ID.
  Future<void> cancel(int leaveRequestId) async {
    try {
      await _dioClient.dio.put(
        '${ApiConstants.leaveRequests}/$leaveRequestId/cancel',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
    /// Get all pending leave requests (scoped by role).
  /// - Admin/HR: all pending
  /// - Manager: pending from direct reports only
  Future<List<LeaveRequest>> getPending() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.leaveRequests}/pending',
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        final list = data['data'] as List;
        return list
            .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  /// Approve or reject a leave request.
  /// [status] must be either 'APPROVED' or 'REJECTED'.
  Future<LeaveRequest> updateStatus({
    required int leaveRequestId,
    required String status,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.leaveRequests}/$leaveRequestId/status',
        data: {'status': status},
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success') {
        return LeaveRequest.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }
}