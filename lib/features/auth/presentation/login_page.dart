import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_core/core/extensions/integer_sizedbox_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/configs/injector/injector_conf.dart';
import '../../../core/constants/key_translate.dart';
import '../../../core/routes/app_route_path.dart';
import '../../../core/themes/app_color.dart';
import '../../../core/themes/app_font.dart';
import '../../../widgets/snackbar_widget.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth_login_form/auth_login_form_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    primaryFocus?.unfocus();
    final authForm = context.read<AuthLoginFormBloc>().state;
    context.read<AuthBloc>().add(
          AuthLoginEvent(authForm.email.trim(), authForm.password.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => getIt<AuthLoginFormBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0A0E21),
                          const Color(0xFF141852),
                          AppColor.navy,
                        ]
                      : [
                          const Color(0xFFF0E6FF),
                          const Color(0xFFE8DAFF),
                          const Color(0xFFDBC5FF),
                        ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Logo / Icon ──
                            _buildLogo(isDark),
                            32.hS,

                            // ── Title ──
                            Text(
                              loginKey.tr(),
                              style: AppFont.bold.s16.copyWith(
                                fontSize: 28.sp,
                                color: isDark ? Colors.white : AppColor.navy,
                                letterSpacing: 1.2,
                              ),
                            ),
                            8.hS,
                            Text(
                              appTitleKey.tr(),
                              style: AppFont.normal.s12.copyWith(
                                color: isDark
                                    ? Colors.white54
                                    : AppColor.purple.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            36.hS,

                            // ── Form Card ──
                            _buildFormCard(context, isDark),
                            24.hS,

                            // ── Register Link ──
                            _buildRegisterLink(context, isDark),
                            20.hS,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.purple,
            AppColor.lightPurple,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.purple.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: 40.sp,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColor.lightPurple.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColor.purple.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Email Field ──
          _buildTextField(
            controller: _emailController,
            label: inputEmailKey.tr(),
            icon: Icons.email_outlined,
            isDark: isDark,
            onChanged: (val) {
              context
                  .read<AuthLoginFormBloc>()
                  .add(LoginFormEmailChangedEvent(val));
            },
          ),
          16.hS,

          // ── Password Field ──
          _buildTextField(
            controller: _passwordController,
            label: inputPasswordKey.tr(),
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            isPassword: true,
            onChanged: (val) {
              context
                  .read<AuthLoginFormBloc>()
                  .add(LoginFormPasswordChangedEvent(val));
            },
          ),
          24.hS,

          // ── Login Button ──
          BlocConsumer<AuthBloc, AuthState>(
            listener: (_, state) {
              if (state is AuthLoginFailureState) {
                appSnackBar(context, Colors.red, state.message);
              } else if (state is AuthLoginSuccessState) {
                final user = state.data;
                context.goNamed(
                  AppRoute.home.name,
                  extra: user,
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoginLoadingState;
              return BlocBuilder<AuthLoginFormBloc, LoginFormState>(
                builder: (context, formState) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: formState.isValid && !isLoading
                          ? () => _login(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.purple,
                        disabledBackgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColor.lightPurple.withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            isDark ? Colors.white38 : AppColor.purple.withValues(alpha: 0.4),
                        elevation: formState.isValid ? 6 : 0,
                        shadowColor: AppColor.purple.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              loginKey.tr(),
                              style: AppFont.bold.s16.copyWith(
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required ValueChanged<String> onChanged,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? Colors.white : AppColor.navy,
        fontSize: 14.sp,
      ),
      cursorColor: AppColor.purple,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark
              ? Colors.white54
              : AppColor.purple.withValues(alpha: 0.6),
          fontSize: 13.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColor.lightPurple : AppColor.purple,
          size: 22.sp,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: isDark
                      ? Colors.white38
                      : AppColor.purple.withValues(alpha: 0.5),
                  size: 22.sp,
                ),
                splashRadius: 20.r,
              )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColor.lightPurple.withValues(alpha: 0.12),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColor.lightPurple.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: AppColor.purple,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Chưa có tài khoản? ",
          style: AppFont.normal.s12.copyWith(
            color: isDark ? Colors.white54 : AppColor.navy.withValues(alpha: 0.6),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.pushReplacementNamed(AppRoute.register.name);
          },
          child: Text(
            registerKey.tr(),
            style: AppFont.bold.s12.copyWith(
              color: isDark ? AppColor.lightPurple : AppColor.purple,
              decoration: TextDecoration.underline,
              decorationColor: isDark ? AppColor.lightPurple : AppColor.purple,
            ),
          ),
        ),
      ],
    );
  }
}
