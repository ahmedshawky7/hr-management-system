import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../departments/data/models/department_model.dart';
import '../../../departments/data/repositories/departments_repository.dart';
import '../../data/models/employee_create_request.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employees_repository.dart';

class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();

  DateTime? _hireDate;
  Department? _selectedDepartment;
  List<Department> _departments = [];
  bool _loadingDepartments = true;
  String? _departmentsError;
  bool _submitting = false;
  Employee? _selectedManager;
  List<Employee> _managers = [];
  bool _loadingManagers = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadManagers();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _loadingDepartments = true;
      _departmentsError = null;
    });
    try {
      final repo = context.read<DepartmentsRepository>();
      final list = await repo.getAll();
      setState(() {
        _departments = list;
        _loadingDepartments = false;
      });
    } catch (e) {
      setState(() {
        _departmentsError = e.toString().replaceFirst('Exception: ', '');
        _loadingDepartments = false;
      });
    }
  }
  Future<void> _loadManagers() async {
    setState(() => _loadingManagers = true);
    try {
      final repo = context.read<EmployeesRepository>();
      final list = await repo.getAllForDropdown();
      setState(() {
        _managers = list;
        _loadingManagers = false;
      });
    } catch (e) {
      setState(() => _loadingManagers = false);
    }
  }

  Future<void> _pickHireDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _hireDate = picked);
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_hireDate == null) {
      _snack('Please pick a hire date', isError: true);
      return;
    }
    if (_selectedDepartment == null) {
      _snack('Please select a department', isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      final request = EmployeeCreateRequest(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        hireDate: _fmt(_hireDate!),
        departmentId: _selectedDepartment!.id,
        managerId: _selectedManager?.id,   // 🌟 جديد
      );

      await context.read<EmployeesRepository>().create(request);
      if (mounted) {
        _snack('Employee created! Activation email sent.', isError: false);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Employee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingDepartments ? null : _loadDepartments,
            tooltip: 'Reload departments',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Employee Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'An activation email will be sent automatically.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // === First Name ===
                      TextFormField(
                        controller: _firstNameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
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
                      const SizedBox(height: 16),

                      // === Last Name ===
                      TextFormField(
                        controller: _lastNameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
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
                      const SizedBox(height: 16),

                      // === Email ===
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(
                            r'^[\w\.-]+@[\w\.-]+\.\w+$',
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // === Phone ===
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: '+201234567890',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone is required';
                          }
                          final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
                          if (!phoneRegex.hasMatch(v.trim())) {
                            return 'Invalid phone (10-15 digits)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // === Position ===
                      TextFormField(
                        controller: _positionCtrl,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          prefixIcon: Icon(Icons.work_outline),
                          hintText: 'e.g. Backend Developer',
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
                      const SizedBox(height: 16),

                      // === Hire Date ===
                      InkWell(
                        onTap: _pickHireDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Hire Date',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          child: Text(
                            _hireDate != null
                                ? DateFormat.yMMMd().format(_hireDate!)
                                : 'Pick a date',
                            style: TextStyle(
                              color: _hireDate != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === Department ===
                      _buildDepartmentField(),
                      const SizedBox(height: 16),

                      // === Manager (Optional) ===
                      _buildManagerField(),
                      const SizedBox(height: 24),

                      // === Submit ===
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
                            : const Text('Create Employee'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentField() {
    if (_loadingDepartments) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Department',
          prefixIcon: Icon(Icons.business_outlined),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_departmentsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.business_outlined),
              errorText: 'Failed to load departments',
            ),
            child: const Text('—'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadDepartments,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    if (_departments.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Department',
          prefixIcon: Icon(Icons.business_outlined),
        ),
        child: Text(
          'No departments available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return DropdownButtonFormField<Department>(
      initialValue: _selectedDepartment,
      decoration: const InputDecoration(
        labelText: 'Department',
        prefixIcon: Icon(Icons.business_outlined),
      ),
      items: _departments.map((dept) {
        return DropdownMenuItem<Department>(
          value: dept,
          child: Text(dept.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDepartment = value),
      validator: (v) => v == null ? 'Department is required' : null,
    );
  }

  Widget _buildManagerField() {
    if (_loadingManagers) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Manager (Optional)',
          prefixIcon: Icon(Icons.supervisor_account_outlined),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Employee?>(
      initialValue: _selectedManager,
      decoration: const InputDecoration(
        labelText: 'Manager (Optional)',
        prefixIcon: Icon(Icons.supervisor_account_outlined),
        hintText: 'No manager',
      ),
      items: [
        // 🌟 خيار "بدون مدير"
        const DropdownMenuItem<Employee?>(
          value: null,
          child: Text('— No Manager —', style: TextStyle(color: Colors.grey)),
        ),
        // كل الموظفين
        ..._managers.map((emp) {
          return DropdownMenuItem<Employee?>(
            value: emp,
            child: Text('${emp.fullName}  •  ${emp.position}'),
          );
        }),
      ],
      onChanged: (value) => setState(() => _selectedManager = value),
      // مفيش validator — اختياري
    );
  }
}