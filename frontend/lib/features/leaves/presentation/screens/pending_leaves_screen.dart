import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/leave_request_model.dart';
import '../../data/repositories/leaves_repository.dart';
import '../cubit/pending_leaves_cubit.dart';
import '../cubit/pending_leaves_state.dart';

class PendingLeavesScreen extends StatelessWidget {
  const PendingLeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          PendingLeavesCubit(ctx.read<LeavesRepository>())..loadPending(),
      child: const _PendingLeavesView(),
    );
  }
}

class _PendingLeavesView extends StatelessWidget {
  const _PendingLeavesView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Header =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.pending_actions, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Pending Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<PendingLeavesCubit>().loadPending(),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ===== Body =====
        Expanded(
          child: BlocConsumer<PendingLeavesCubit, PendingLeavesState>(
            listener: (context, state) {
              if (state is PendingLeavesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is PendingLeavesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PendingLeavesError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<PendingLeavesCubit>().loadPending(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is PendingLeavesLoaded) {
                if (state.leaves.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No pending requests'),
                        SizedBox(height: 4),
                        Text(
                          'All caught up! 🎉',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.leaves.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final leave = state.leaves[index];
                    return _PendingLeaveCard(
                      leave: leave,
                      onApprove: () => _handleAction(
                        context,
                        () => context
                            .read<PendingLeavesCubit>()
                            .approve(leave.id),
                        'Approved',
                      ),
                      onReject: () => _handleAction(
                        context,
                        () =>
                            context.read<PendingLeavesCubit>().reject(leave.id),
                        'Rejected',
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Future<bool> Function() action,
    String successMessage,
  ) async {
    final success = await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? successMessage : 'Action failed'),
          backgroundColor: success ? AppTheme.secondary : AppTheme.error,
        ),
      );
    }
  }
}

class _PendingLeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingLeaveCard({
    required this.leave,
    required this.onApprove,
    required this.onReject,
  });

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
            // ===== Header: Employee ID badge =====
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_empty,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        'Employee #${leave.employeeId}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 16),

            // ===== Actions =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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