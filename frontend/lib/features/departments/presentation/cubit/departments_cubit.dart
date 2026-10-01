import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/departments_repository.dart';
import 'departments_state.dart';

class DepartmentsCubit extends Cubit<DepartmentsState> {
  final DepartmentsRepository _repository;

  DepartmentsCubit(this._repository) : super(DepartmentsInitial());

  Future<void> loadDepartments() async {
    emit(DepartmentsLoading());
    try {
      final list = await _repository.getAll();
      emit(DepartmentsLoaded(list));
    } catch (e) {
      emit(DepartmentsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> createDepartment(String name) async {
    try {
      await _repository.create(name);
      await loadDepartments();
      return true;
    } catch (e) {
      emit(DepartmentsError(e.toString().replaceFirst('Exception: ', '')));
      return false;
    }
  }

  Future<bool> deleteDepartment(int id) async {
    try {
      await _repository.delete(id);
      await loadDepartments();
      return true;
    } catch (e) {
      emit(DepartmentsError(e.toString().replaceFirst('Exception: ', '')));
      return false;
    }
  }
}