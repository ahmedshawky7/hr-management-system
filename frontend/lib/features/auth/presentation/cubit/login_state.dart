import 'package:equatable/equatable.dart';

import '../../data/models/current_user.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final CurrentUser currentUser;

  const LoginSuccess(this.token, this.currentUser);

  @override
  List<Object?> get props => [token, currentUser];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}