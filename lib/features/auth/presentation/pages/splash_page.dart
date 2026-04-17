import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_route_path.dart';
import '../../../../core/themes/app_color.dart';
import '../bloc/auth/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check auth status on start
    context.read<AuthBloc>().add(AuthCheckSignInStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthCheckSignInStatusSuccessState) {
          // If authenticated, go to home
          context.goNamed(AppRoute.home.name, extra: state.data);
        } else if (state is AuthCheckSignInStatusFailureState) {
          // If not authenticated, go to auth landing page
          context.goNamed(AppRoute.auth.name);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColor.purple, AppColor.lightPurple],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Flutter Core Lab',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
