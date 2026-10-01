import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../departments/presentation/screens/departments_screen.dart';
import '../../../employees/presentation/screens/employees_list_screen.dart';
import '../../../leaves/presentation/screens/pending_leaves_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);  // 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Employees'),
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.business_outlined), text: 'Departments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EmployeesListScreen(),
          PendingLeavesScreen(),
          DepartmentsScreen(),
        ],
      ),
    );
  }
}