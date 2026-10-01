import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/leaves_repository.dart';
import 'leaves_state.dart';

class LeavesCubit extends Cubit<LeavesState> {
  final LeavesRepository _repository;
  final int employeeId;

  LeavesCubit(this._repository, this.employeeId) : super(LeavesInitial());

  Future<void> loadLeaves() async {
    emit(LeavesLoading());
    try {
      final leaves = await _repository.getByEmployee(employeeId);
      // Sort: newest first
      leaves.sort((a, b) => b.startDate.compareTo(a.startDate));
      emit(LeavesLoaded(leaves));
    } catch (e) {
      emit(LeavesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> cancelLeave(int leaveId) async {
    try {
      await _repository.cancel(leaveId);
      await loadLeaves();
      return true;
    } catch (e) {
      emit(LeavesError(e.toString().replaceFirst('Exception: ', '')));
      return false;
    }
  }
}