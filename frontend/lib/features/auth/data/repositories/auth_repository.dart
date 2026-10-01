import 'package:dio/dio.dart';
import 'package:hr_management_app/features/auth/data/models/current_user.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/login_request.dart';

class AuthRepository {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required DioClient dioClient,
    required TokenStorage tokenStorage,
  })  : _dioClient = dioClient,
        _tokenStorage = tokenStorage;

  /// Returns the JWT token on success, throws on failure.
  Future<String> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final data = response.data;
      if (data is Map && data['status'] == 'Success' && data['data'] is String) {
        final token = data['data'] as String;
        await _tokenStorage.saveToken(token);
        return token;
      }

      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      throw Exception(DioClient.extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  Future<bool> isLoggedIn() async {
    return _tokenStorage.hasToken();
  }
  Future<CurrentUser> getCurrentUser() async {
  try {
    final response = await _dioClient.dio.get(ApiConstants.authMe);
    final data = response.data;
    if (data is Map && data['status'] == 'Success') {
      return CurrentUser.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Unexpected response');
  } on DioException catch (e) {
    throw Exception(DioClient.extractErrorMessage(e));
  }
}
}