import 'package:equatable/equatable.dart';
import '../../data/models/leave_request_model.dart';

abstract class PendingLeavesState extends Equatable {
  const PendingLeavesState();

  @override
  List<Object?> get props => [];
}

class PendingLeavesInitial extends PendingLeavesState {}

class PendingLeavesLoading extends PendingLeavesState {}

class PendingLeavesLoaded extends PendingLeavesState {
  final List<LeaveRequest> leaves;
  const PendingLeavesLoaded(this.leaves);

  @override
  List<Object?> get props => [leaves];
}

class PendingLeavesError extends PendingLeavesState {
  final String message;
  const PendingLeavesError(this.message);

  @override
  List<Object?> get props => [message];
}