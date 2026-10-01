import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management_app/features/departments/data/repositories/departments_repository.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/employees/data/repositories/employees_repository.dart';
import 'features/leaves/data/repositories/leaves_repository.dart';

void main() {
  runApp(const HrManagementApp());
}

class HrManagementApp extends StatefulWidget {
  const HrManagementApp({super.key});

  @override
  State<HrManagementApp> createState() => _HrManagementAppState();
}

class _HrManagementAppState extends State<HrManagementApp> {
  late final TokenStorage _tokenStorage;
  late final DioClient _dioClient;
  late final AuthRepository _authRepository;
  late final EmployeesRepository _employeesRepository;
  late final LeavesRepository _leavesRepository;
  late final DepartmentsRepository _departmentsRepository;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _dioClient = DioClient(_tokenStorage);
    _authRepository = AuthRepository(
      dioClient: _dioClient,
      tokenStorage: _tokenStorage,
    );
    _employeesRepository = EmployeesRepository(dioClient: _dioClient);
    _leavesRepository = LeavesRepository(dioClient: _dioClient);
    _departmentsRepository = DepartmentsRepository(dioClient: _dioClient);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EmployeesRepository>.value(
          value: _employeesRepository,
        ),
        RepositoryProvider<LeavesRepository>.value(value: _leavesRepository),
        RepositoryProvider<DepartmentsRepository>.value(
          value: _departmentsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (_) => LoginCubit(_authRepository))],
        child: MaterialApp.router(
          title: 'HR Management',
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
