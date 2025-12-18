import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/core/services/auth_service.dart';
import 'package:pakebun_app/features/auth/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _googleLoading = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!mounted) return;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(email: email, password: password);

      if (mounted) {
        context.go('/garden');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35591A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 48.h),
            // Logo pakebun putih
            SvgPicture.asset(
              'assets/vector/logo_putih.svg',
              width: 120.w,
              height: 48.h,
            ),
            SizedBox(height: 36.h),
            Text(
              'Masuk',
              style: AppTheme.heading2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan Email',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: const Color(0xFFBDBDBD),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan Kata Sandi',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: const Color(0xFFBDBDBD),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lupa sandi ? ',
                        style: AppTheme.bodySmall.copyWith(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/reset-sandi');
                        },
                        child: Text(
                          'Reset sandi',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FC12B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Masuk',
                              style: AppTheme.heading3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  // Divider OR
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.white24),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          'atau',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.white24),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white54,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 12.w,
                        ),
                      ),
                      icon: _googleLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: Colors.white,
                            ),
                      label: Text(
                        _googleLoading ? 'Memproses...' : 'Masuk dengan Google',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _googleLoading
                          ? null
                          : () async {
                              setState(() => _googleLoading = true);
                              try {
                                final cred = await AuthController.instance
                                    .signInWithGoogle();
                                if (!mounted) return;
                                if (cred != null) {
                                  context.go('/dashboard');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal login Google'),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted)
                                  setState(() => _googleLoading = false);
                              }
                            },
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum memiliki akun? ',
                        style: AppTheme.bodySmall.copyWith(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/register');
                        },
                        child: Text(
                          'Daftar',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Tidak ada bottomNavigationBar di halaman login
    );
  }
}
