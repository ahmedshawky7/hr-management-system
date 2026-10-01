import 'package:equatable/equatable.dart';
import '../../data/models/leave_request_model.dart';

abstract class LeavesState extends Equatable {
  const LeavesState();

  @override
  List<Object?> get props => [];
}

class LeavesInitial extends LeavesState {}

class LeavesLoading extends LeavesState {}

class LeavesLoaded extends LeavesState {
  final List<LeaveRequest> leaves;
  const LeavesLoaded(this.leaves);

  @override
  List<Object?> get props => [leaves];
}

class LeavesError extends LeavesState {
  final String message;
  const LeavesError(this.message);

  @override
  List<Object?> get props => [message];
}