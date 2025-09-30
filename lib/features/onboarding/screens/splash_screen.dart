import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Tahan minimal splash 1.5s agar tidak terlalu cepat flicker
    final wait = Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    await wait; // pastikan minimal delay terpenuhi
    if (!mounted) return;
    if (user != null) {
      context.go('/dashboard');
    } else if (onboardingDone) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Pakebun
              SvgPicture.asset(
                'assets/vector/logo_pakebun.svg',
                width: 234.w,
                height: 61.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24.h),
              // By + Logo Pentarium (PNG-Long.png) dalam satu baris
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'By',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B4C00),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Image.asset(
                    'assets/image/PNG-Long.png',
                    width: 120.w,
                    height: 32.h,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              SizedBox(
                height: 100.h,
              ), // Jarak lebih besar agar tagline lebih ke bawah
              // Tagline
              Text(
                'Semua Bisa Berkebun',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2B4C00),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
