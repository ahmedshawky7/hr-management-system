import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management_app/features/employees/data/repositories/employees_repository.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/employees_cubit.dart';
import '../cubit/employees_state.dart';

class EmployeesListScreen extends StatelessWidget {
  const EmployeesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          EmployeesCubit(ctx.read<EmployeesRepository>())..loadEmployees(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Builder(
          builder: (innerCtx) => FloatingActionButton.extended(
            onPressed: () async {
              final created = await innerCtx.push<bool>('/employees/new');
              if (created == true && innerCtx.mounted) {
                innerCtx.read<EmployeesCubit>().refresh();
              }
            },
            icon: const Icon(Icons.person_add),
            label: const Text('New Employee'),
          ),
        ),
        body: const _EmployeesListView(),
      ),
    );
  }
}

class _EmployeesListView extends StatelessWidget {
  const _EmployeesListView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Header =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.people, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Employees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<EmployeesCubit>().refresh(),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ===== Body =====
        Expanded(
          child: BlocBuilder<EmployeesCubit, EmployeesState>(
            builder: (context, state) {
              if (state is EmployeesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is EmployeesError) {
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
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<EmployeesCubit>().refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is EmployeesLoaded) {
                if (state.employees.isEmpty) {
                  return const Center(child: Text('No employees found'));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.employees.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final emp = state.employees[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                context.push('/employees/${emp.id}');
                              },
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary,
                                child: Text(
                                  emp.firstName.isNotEmpty
                                      ? emp.firstName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                emp.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(emp.position),
                                  const SizedBox(height: 2),
                                  Text(
                                    emp.email,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hired: ${DateFormat.yMMMd().format(emp.hireDate)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                emp.isVerified
                                    ? Icons.verified
                                    : Icons.pending_outlined,
                                color: emp.isVerified
                                    ? AppTheme.secondary
                                    : Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _PaginationBar(
                      currentPage: state.currentPage + 1,
                      totalPages: state.totalPages,
                      totalItems: state.totalItems,
                      hasNext: state.hasNext,
                      hasPrevious: state.hasPrevious,
                    ),
                  ],
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

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrevious;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $currentPage of $totalPages • $totalItems employees',
            style: const TextStyle(fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                onPressed: hasPrevious
                    ? () => context.read<EmployeesCubit>().previousPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: hasNext
                    ? () => context.read<EmployeesCubit>().nextPage()
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
