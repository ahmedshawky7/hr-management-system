import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/leave_request_model.dart';
import '../../data/models/leave_status.dart';
import '../../data/repositories/leaves_repository.dart';
import '../cubit/leaves_cubit.dart';
import '../cubit/leaves_state.dart';

class LeavesListScreen extends StatelessWidget {
  final int employeeId;
  const LeavesListScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeavesCubit(
        context.read<LeavesRepository>(),
        employeeId,
      )..loadLeaves(),
      child: _LeavesListView(employeeId: employeeId),
    );
  }
}

class _LeavesListView extends StatelessWidget {
  final int employeeId;
  const _LeavesListView({required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LeavesCubit>().loadLeaves(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>(
            '/employees/$employeeId/leaves/new',
          );
          if (created == true && context.mounted) {
            context.read<LeavesCubit>().loadLeaves();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
      body: BlocBuilder<LeavesCubit, LeavesState>(
        builder: (context, state) {
          if (state is LeavesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeavesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<LeavesCubit>().loadLeaves(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LeavesLoaded) {
            if (state.leaves.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.beach_access_outlined,
                        size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No leave requests yet'),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.leaves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final leave = state.leaves[index];
                return _LeaveCard(
                  leave: leave,
                  onCancel: leave.status == LeaveStatus.pending
                      ? () => _confirmCancel(context, leave.id)
                      : null,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context, int leaveId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text(
            'Are you sure you want to cancel this leave request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<LeavesCubit>().cancelLeave(leaveId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Cancelled' : 'Failed to cancel'),
            backgroundColor: success ? AppTheme.secondary : AppTheme.error,
          ),
        );
      }
    }
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  final VoidCallback? onCancel;

  const _LeaveCard({required this.leave, this.onCancel});

  Color get _statusColor {
    switch (leave.status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return AppTheme.secondary;
      case LeaveStatus.rejected:
        return AppTheme.error;
      case LeaveStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (leave.status) {
      case LeaveStatus.pending:
        return Icons.hourglass_empty;
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
      case LeaveStatus.cancelled:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header: Status Badge + Cancel =====
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 6),
                      Text(
                        leave.status.displayName,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onCancel != null)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== Reason =====
            Text(
              leave.reason,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // ===== Dates =====
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat.yMMMd().format(leave.startDate)} → ${DateFormat.yMMMd().format(leave.endDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${leave.daysCount} day${leave.daysCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}