import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employees_repository.dart';

class ChangeRoleScreen extends StatefulWidget {
  final Employee employee;
  const ChangeRoleScreen({super.key, required this.employee});

  @override
  State<ChangeRoleScreen> createState() => _ChangeRoleScreenState();
}

class _ChangeRoleScreenState extends State<ChangeRoleScreen> {
  final _roles = const [
    ('EMPLOYEE', 'Employee', Icons.person),
    ('MANAGER', 'Manager', Icons.supervisor_account),
    ('HR_ADMIN', 'HR Admin', Icons.badge),
    ('SUPER_ADMIN', 'Super Admin', Icons.admin_panel_settings),
  ];

  String? _selectedRole;
  bool _submitting = false;

  Future<void> _submit() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await context.read<EmployeesRepository>().updateRole(
            employeeId: widget.employee.id,
            role: _selectedRole!,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role updated!'),
            backgroundColor: AppTheme.secondary,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Role')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Employee: ${widget.employee.fullName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the new role for this employee.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // 🌟 RadioGroup — بدون null في onChanged
                    RadioGroup<String>(
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        if (_submitting) return; // 🎯 check جوه
                        setState(() => _selectedRole = value);
                      },
                      child: Column(
                        children: _roles.map((role) {
                          final (value, label, icon) = role;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: _submitting
                                  ? null
                                  : () => setState(() => _selectedRole = value),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == value
                                        ? AppTheme.primary
                                        : Colors.grey.shade300,
                                    width: _selectedRole == value ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(icon,
                                        color: AppTheme.primary, size: 22),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Radio<String>(
                                      value: value,
                                      activeColor: AppTheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Update Role'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}