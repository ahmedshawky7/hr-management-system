import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employees_repository.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final int employeeId;
  const EmployeeDetailsScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  late Future<Employee> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadEmployee();
  }

  Future<Employee> _loadEmployee() {
    final repo = context.read<EmployeesRepository>();
    return repo.getEmployeeById(widget.employeeId);
  }
    Future<void> _confirmDelete(BuildContext context, Employee emp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee?'),
        content: Text(
          'Are you sure you want to delete "${emp.fullName}"?\n'
          'This action cannot be undone.',
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
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<EmployeesRepository>().delete(emp.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee deleted'),
            backgroundColor: AppTheme.secondary,
          ),
        );
        context.pop(); // ارجع للقائمة
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _reload() {
    setState(() {
      _future = _loadEmployee();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<Employee>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final emp = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // ===== Header Card =====
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                emp.firstName.isNotEmpty
                                    ? emp.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              emp.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              emp.position,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _VerifiedBadge(isVerified: emp.isVerified),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ===== Info Card =====
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: emp.email,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: emp.phoneNumber,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Hire Date',
                              value: DateFormat.yMMMMd().format(emp.hireDate),
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.business_outlined,
                              label: 'Department ID',
                              value: emp.departmentId.toString(),
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.supervisor_account_outlined,
                              label: 'Manager ID',
                              value: emp.managerId?.toString() ?? '—',
                            ),

                          ],
                        ),
                      ),
                    ),
                                        const SizedBox(height: 24),

                    // ===== View Leave Requests Button =====
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/employees/${emp.id}/leaves');
                        },
                        icon: const Icon(Icons.beach_access_outlined),
                        label: const Text('View Leave Requests'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                              color: AppTheme.primary, width: 2),
                          foregroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                                        const SizedBox(height: 12),

                    // ===== Edit + Role + Delete (Row) =====
                    Row(
                      children: [
                        // Edit
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated = await context.push<bool>(
                                '/employees/${emp.id}/edit',
                                extra: emp,
                              );
                              if (updated == true && context.mounted) {
                                _reload();
                              }
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(
                                  color: AppTheme.primary, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Role
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated = await context.push<bool>(
                                '/employees/${emp.id}/role',
                                extra: emp,
                              );
                              if (updated == true && context.mounted) {
                                _reload();
                              }
                            },
                            icon: const Icon(Icons.admin_panel_settings_outlined),
                            label: const Text('Role'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(
                                  color: Colors.orange, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Delete
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmDelete(context, emp),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: const BorderSide(
                                  color: AppTheme.error, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  const _VerifiedBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppTheme.secondary : Colors.orange;
    final text = isVerified ? 'Verified Account' : 'Pending Verification';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}