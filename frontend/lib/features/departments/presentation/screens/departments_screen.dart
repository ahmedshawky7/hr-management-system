import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/department_model.dart';
import '../../data/repositories/departments_repository.dart';
import '../cubit/departments_cubit.dart';
import '../cubit/departments_state.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
      DepartmentsCubit(ctx.read<DepartmentsRepository>())..loadDepartments(),
      child: const _DepartmentsView(),
    );
  }
}

class _DepartmentsView extends StatelessWidget {
  const _DepartmentsView();

  // ==================================================
  // Create Department Dialog
  // ==================================================
  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Department'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Department Name',
              prefixIcon: Icon(Icons.business_outlined),
              hintText: 'e.g. IT, HR, Sales',
            ),
            validator: (v) {
              if (v == null || v.trim().length < 2) {
                return 'Min 2 characters';
              }
              if (v.trim().length > 50) {
                return 'Max 50 characters';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created == true && context.mounted) {
      final success = await context
          .read<DepartmentsCubit>()
          .createDepartment(controller.text.trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Department created!' : 'Failed to create'),
            backgroundColor: success ? AppTheme.secondary : AppTheme.error,
          ),
        );
      }
    }

    controller.dispose();
  }

  // ==================================================
  // Delete Confirmation Dialog
  // ==================================================
  Future<void> _confirmDelete(BuildContext context, Department dept) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department?'),
        content: Text(
          'Are you sure you want to delete "${dept.name}"?\n\n'
              '⚠️ You cannot delete a department that has employees assigned to it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success =
    await context.read<DepartmentsCubit>().deleteDepartment(dept.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Department deleted'
              : 'Cannot delete — may have employees'),
          backgroundColor: success ? AppTheme.secondary : AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ==================================================
        // Header — Add + Refresh Buttons
        // ==================================================
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.business, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Departments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // ➕ Add Department
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primary,
                ),
                onPressed: () => _showCreateDialog(context),
                tooltip: 'Add Department',
              ),
              // 🔄 Refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<DepartmentsCubit>().loadDepartments(),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ==================================================
        // Body
        // ==================================================
        Expanded(
          child: BlocConsumer<DepartmentsCubit, DepartmentsState>(
            listener: (context, state) {
              if (state is DepartmentsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is DepartmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DepartmentsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.error,
                      ),
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
                        onPressed: () => context
                            .read<DepartmentsCubit>()
                            .loadDepartments(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is DepartmentsLoaded) {
                if (state.departments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No departments yet'),
                        SizedBox(height: 4),
                        Text(
                          'Tap + to add one',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: state.departments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dept = state.departments[index];
                    return _DepartmentCard(
                      department: dept,
                      onDelete: () => _confirmDelete(context, dept),
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
}

// ==================================================
// Department Card Widget
// ==================================================
class _DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onDelete;

  const _DepartmentCard({
    required this.department,
    required this.onDelete,
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business,
                color: AppTheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${department.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}