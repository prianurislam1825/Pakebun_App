import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi!')));
      return;
    }

    if (password != confirmPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi sandi tidak cocok!')),
      );
      return;
    }

    if (password.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: name,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil! Silakan cek email untuk verifikasi.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.go('/login');
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35591A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 48.h),
            SvgPicture.asset(
              'assets/vector/logo_putih.svg',
              width: 120.w,
              height: 48.h,
            ),
            SizedBox(height: 36.h),
            Text(
              'Daftar',
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
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Masukkan Nama',
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
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Konfirmasi Kata Sandi',
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
                  SizedBox(height: 24.h),
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
                      onPressed: _isLoading ? null : _register,
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
                              'Daftar',
                              style: AppTheme.heading3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah memiliki akun? ',
                        style: AppTheme.bodySmall.copyWith(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Masuk',
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
      // Tidak ada bottomNavigationBar di halaman daftar
    );
  }
}
