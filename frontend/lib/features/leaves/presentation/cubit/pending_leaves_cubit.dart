import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/leaves_repository.dart';
import 'pending_leaves_state.dart';

class PendingLeavesCubit extends Cubit<PendingLeavesState> {
  final LeavesRepository _repository;

  PendingLeavesCubit(this._repository) : super(PendingLeavesInitial());

  Future<void> loadPending() async {
    emit(PendingLeavesLoading());
    try {
      final leaves = await _repository.getPending();
      emit(PendingLeavesLoaded(leaves));
    } catch (e) {
      emit(PendingLeavesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> approve(int leaveId) async {
    return _updateStatus(leaveId, 'APPROVED');
  }

  Future<bool> reject(int leaveId) async {
    return _updateStatus(leaveId, 'REJECTED');
  }

  Future<bool> _updateStatus(int leaveId, String status) async {
    try {
      await _repository.updateStatus(leaveRequestId: leaveId, status: status);
      await loadPending();
      return true;
    } catch (e) {
      emit(PendingLeavesError(e.toString().replaceFirst('Exception: ', '')));
      return false;
    }
  }
}