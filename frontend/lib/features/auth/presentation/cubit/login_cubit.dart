import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/login_request.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(LoginInitial());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      // 1. Login → token
      final token = await _authRepository.login(
        LoginRequest(username: username, password: password),
      );

      // 2. Get current user info
      final currentUser = await _authRepository.getCurrentUser();

      // 3. Emit Success with both
      emit(LoginSuccess(token, currentUser));
    } catch (e) {
      emit(LoginFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() {
    emit(LoginInitial());
  }
}
