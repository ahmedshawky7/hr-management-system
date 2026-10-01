import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/employees_repository.dart';
import 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final EmployeesRepository _repository;
  int _currentPage = 1;
  static const int _pageSize = 5;

  EmployeesCubit(this._repository) : super(EmployeesInitial());

  Future<void> loadEmployees({int page = 1}) async {
    emit(EmployeesLoading());
    try {
      final result = await _repository.getEmployees(page: page, size: _pageSize);
      _currentPage = page;
      emit(EmployeesLoaded(
        employees: result.content,
        currentPage: result.currentPage,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
        hasNext: result.hasNext,
        hasPrevious: result.hasPrevious,
      ));
    } catch (e) {
      emit(EmployeesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> nextPage() async {
    final currentState = state;
    if (currentState is EmployeesLoaded && currentState.hasNext) {
      await loadEmployees(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    final currentState = state;
    if (currentState is EmployeesLoaded && currentState.hasPrevious) {
      await loadEmployees(page: _currentPage - 1);
    }
  }

  Future<void> refresh() async {
    await loadEmployees(page: _currentPage);
  }
}