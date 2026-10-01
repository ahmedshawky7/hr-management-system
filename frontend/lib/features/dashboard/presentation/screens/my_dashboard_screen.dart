import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyDashboardScreen extends StatelessWidget {
  final int employeeId;
  const MyDashboardScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Welcome!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/employees/$employeeId');
              },
              icon: const Icon(Icons.person_outline),
              label: const Text('My Profile'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/employees/$employeeId/leaves');
              },
              icon: const Icon(Icons.beach_access),
              label: const Text('My Leave Requests'),
            ),
          ],
        ),
      ),
    );
  }
}