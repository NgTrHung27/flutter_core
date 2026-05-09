import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_route_path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/presentation/bloc/auth/auth_bloc.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccessState) {
          context.goNamed(AppRoute.splash.name);
        } else if (state is AuthLogoutFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutEvent());
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
                'Welcome SHOREBIRD PATCH TEST v2 - ${DateTime.now().hour}:${DateTime.now().minute} - ${user.username ?? user.email}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text('Email: ${user.email}'),
              Text('User ID: ${user.userId}'),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.profiling.name),
                icon: const Icon(Icons.analytics),
                label: const Text('Go to Profiling Lab'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              //Test
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.repaintBoundary.name),
                icon: const Icon(Icons.speed),
                label: const Text('RepaintBoundary Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.isolateDemo.name),
                icon: const Icon(Icons.alt_route),
                label: const Text('Go to Isolate Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.nativeAndroid.name),
                icon: const Icon(Icons.settings_remote),
                label: const Text('Method Channel (Android)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.nativeIos.name),
                icon: const Icon(Icons.settings_remote),
                label: const Text('Method Channel (IOS)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.permission.name),
                icon: const Icon(Icons.lock),
                label: const Text('Permissions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
