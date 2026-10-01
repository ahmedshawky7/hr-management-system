import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../departments/data/models/department_model.dart';
import '../../../departments/data/repositories/departments_repository.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employees_repository.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;
  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _positionCtrl;

  // ===== Department state =====
  Department? _selectedDepartment;
  List<Department> _departments = [];
  bool _loadingDepartments = true;
  String? _departmentsError;

  // 🌟 Manager state
  Employee? _selectedManager;
  List<Employee> _managers = [];
  bool _loadingManagers = true;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.employee.firstName);
    _lastNameCtrl = TextEditingController(text: widget.employee.lastName);
    _phoneCtrl = TextEditingController(text: widget.employee.phoneNumber);
    _positionCtrl = TextEditingController(text: widget.employee.position);
    _loadDepartments();
    _loadManagers();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  // ===== Load departments =====
  Future<void> _loadDepartments() async {
    setState(() {
      _loadingDepartments = true;
      _departmentsError = null;
    });
    try {
      final repo = context.read<DepartmentsRepository>();
      final list = await repo.getAll();

      Department? current;
      for (final d in list) {
        if (d.id == widget.employee.departmentId) {
          current = d;
          break;
        }
      }

      setState(() {
        _departments = list;
        _selectedDepartment = current;
        _loadingDepartments = false;
      });
    } catch (e) {
      setState(() {
        _departmentsError = e.toString().replaceFirst('Exception: ', '');
        _loadingDepartments = false;
      });
    }
  }

  // 🌟 Load managers list + preselect current manager
  Future<void> _loadManagers() async {
    setState(() => _loadingManagers = true);
    try {
      final repo = context.read<EmployeesRepository>();
      final list = await repo.getAllForDropdown();

      // شيل الموظف نفسه من القائمة (مش ينفع يكون مدير لنفسه)
      final filtered =
      list.where((e) => e.id != widget.employee.id).toList();

      // حدد المدير الحالي
      Employee? currentManager;
      if (widget.employee.managerId != null) {
        for (final e in filtered) {
          if (e.id == widget.employee.managerId) {
            currentManager = e;
            break;
          }
        }
      }

      setState(() {
        _managers = filtered;
        _selectedManager = currentManager;
        _loadingManagers = false;
      });
    } catch (e) {
      setState(() => _loadingManagers = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      await context.read<EmployeesRepository>().update(
        employeeId: widget.employee.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        departmentId: _selectedDepartment?.id,
        managerId: _selectedManager?.id,
        // 🌟 لو مفيش مدير دلوقتي ومفيش مدير جديد، نعمل clearManager
        clearManager: _selectedManager == null &&
            widget.employee.managerId != null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee updated!'),
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
      appBar: AppBar(
        title: const Text('Edit Employee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingDepartments || _loadingManagers
                ? null
                : () {
              _loadDepartments();
              _loadManagers();
            },
            tooltip: 'Reload',
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Email can\'t be changed. Contact admin for that.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                        (v == null || v.trim().length < 2)
                            ? 'Min 2 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                        (v == null || v.trim().length < 2)
                            ? 'Min 2 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone is required';
                          }
                          if (!RegExp(r'^\+?[0-9]{10,15}$')
                              .hasMatch(v.trim())) {
                            return 'Invalid phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _positionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        validator: (v) =>
                        (v == null || v.trim().length < 2)
                            ? 'Min 2 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ===== Department =====
                      _buildDepartmentField(),
                      const SizedBox(height: 16),

                      // 🌟 Manager
                      _buildManagerField(),
                      const SizedBox(height: 24),

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
                            : const Text('Save Changes'),
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
      onChanged: _submitting
          ? null
          : (value) => setState(() => _selectedDepartment = value),
      validator: (v) => v == null ? 'Department is required' : null,
    );
  }

  // 🌟 Manager dropdown builder
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
          child: Text(
            '— No Manager —',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // كل الموظفين (ممكن يبقوا مديرين)
        ..._managers.map((emp) {
          return DropdownMenuItem<Employee?>(
            value: emp,
            child: Text('${emp.fullName}  •  ${emp.position}'),
          );
        }),
      ],
      onChanged: _submitting
          ? null
          : (value) => setState(() => _selectedManager = value),
      // مش required — Optional
    );
  }
}