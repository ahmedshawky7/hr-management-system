class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080';

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Employees
  static const String employees = '/employees';
  static const String employeeById = '/employees';  // + /{id}

  // Leave Requests
  static const String leaveRequests = '/leave-requests';

  static const String authMe = '/auth/me';
}