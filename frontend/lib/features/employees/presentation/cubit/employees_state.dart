import 'package:equatable/equatable.dart';
import '../../data/models/employee_model.dart';

abstract class EmployeesState extends Equatable {
  const EmployeesState();

  @override
  List<Object?> get props => [];
}

class EmployeesInitial extends EmployeesState {}

class EmployeesLoading extends EmployeesState {}

class EmployeesLoaded extends EmployeesState {
  final List<Employee> employees;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrevious;

  const EmployeesLoaded({
    required this.employees,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  List<Object?> get props => [
        employees,
        currentPage,
        totalPages,
        totalItems,
        hasNext,
        hasPrevious,
      ];
}

class EmployeesError extends EmployeesState {
  final String message;
  const EmployeesError(this.message);

  @override
  List<Object?> get props => [message];
}