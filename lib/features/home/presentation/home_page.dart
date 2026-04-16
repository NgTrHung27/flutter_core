import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_route_path.dart';
import '../../auth/domain/entities/user_entity.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              // Add logout logic here later
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user.username ?? user.email}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text('Email: ${user.email}'),
            Text('User ID: ${user.userId}'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.goNamed(AppRoute.profiling.name),
              icon: const Icon(Icons.analytics),
              label: const Text('Go to Profiling Lab'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
