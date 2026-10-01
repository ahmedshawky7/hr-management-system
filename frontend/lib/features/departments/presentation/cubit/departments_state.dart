import 'package:equatable/equatable.dart';
import '../../data/models/department_model.dart';

abstract class DepartmentsState extends Equatable {
  const DepartmentsState();

  @override
  List<Object?> get props => [];
}

class DepartmentsInitial extends DepartmentsState {}

class DepartmentsLoading extends DepartmentsState {}

class DepartmentsLoaded extends DepartmentsState {
  final List<Department> departments;
  const DepartmentsLoaded(this.departments);

  @override
  List<Object?> get props => [departments];
}

class DepartmentsError extends DepartmentsState {
  final String message;
  const DepartmentsError(this.message);

  @override
  List<Object?> get props => [message];
}