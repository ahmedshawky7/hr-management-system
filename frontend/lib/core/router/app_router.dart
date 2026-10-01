import 'package:go_router/go_router.dart';
import 'package:hr_management_app/features/auth/presentation/screens/home_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/my_dashboard_screen.dart';
import '../../features/employees/data/models/employee_model.dart';
import '../../features/employees/presentation/screens/change_role_screen.dart';
import '../../features/employees/presentation/screens/create_employee_screen.dart';
import '../../features/employees/presentation/screens/edit_employee_screen.dart';
import '../../features/employees/presentation/screens/employee_details_screen.dart';
import '../../features/leaves/presentation/screens/create_leave_screen.dart';
import '../../features/leaves/presentation/screens/leaves_list_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // ===== Auth =====
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ===== Home =====
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ===== Employee Dashboard (for EMPLOYEE role) =====
      GoRoute(
        path: '/my-dashboard',
        name: 'my-dashboard',
        builder: (context, state) {
          final employeeId = state.extra as int?;
          if (employeeId == null) {
            return const LoginScreen();
          }
          return MyDashboardScreen(employeeId: employeeId);
        },
      ),

      // ===== Create Employee (must be BEFORE /employees/:id) =====
      GoRoute(
        path: '/employees/new',
        name: 'create-employee',
        builder: (context, state) => const CreateEmployeeScreen(),
      ),

      // ===== Employee Details + Nested Routes =====
      GoRoute(
        path: '/employees/:id',
        name: 'employee-details',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EmployeeDetailsScreen(employeeId: id);
        },
        routes: [
          // ===== Edit Employee =====
          GoRoute(
            path: 'edit',
            name: 'edit-employee',
            builder: (context, state) {
              final emp = state.extra as Employee?;
              if (emp == null) {
                return const HomeScreen();
              }
              return EditEmployeeScreen(employee: emp);
            },
          ),

          // ===== Change Role =====
          GoRoute(
            path: 'role',
            name: 'change-role',
            builder: (context, state) {
              final emp = state.extra as Employee?;
              if (emp == null) {
                return const HomeScreen();
              }
              return ChangeRoleScreen(employee: emp);
            },
          ),

          // ===== Leaves =====
          GoRoute(
            path: 'leaves',
            name: 'leaves-list',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return LeavesListScreen(employeeId: id);
            },
            routes: [
              GoRoute(
                path: 'new',
                name: 'create-leave',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return CreateLeaveScreen(employeeId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}