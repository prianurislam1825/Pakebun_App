import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/image/splash_1.png",
      "title": "Informasi Terlengkap",
      "subtitle":
          "Berbagai jenis informasi tanaman\n& panduan lengkap belajar berkebun",
      "button": "Lanjut",
    },
    {
      "image": "assets/image/splash_2.png",
      "title": "Analisis Kebutuhan & Kondisi Tanaman",
      "subtitle":
          "Deteksi hama, rekomendasi pupuk,\nkebutuhan air, produktivitas tanaman,\nhingga populasi tanaman",
      "button": "Lanjut",
    },
    {
      "image": "assets/image/splash_3.png",
      "title": "Monitoring Kebun Pintar Berbasis IoT",
      "subtitle":
          "Pemantauan kebun mulai dari iklim,\nkondisi tanah, hingga penyiraman\ndan pemupukan otomatis",
      "button": "Masuk",
    },
  ];

  Future<void> _nextPage() async {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      if (!mounted) return;
      context.go('/login'); // setelah onboarding ke login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return PagePadding(
                    applyTop: true,
                    child: Column(
                      children: [
                        // Gambar utama: dari atas sampai setengah screen
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.asset(
                              page["image"]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        // Judul
                        Text(
                          page["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: const Color(0xFF2B4C00),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Subjudul
                        Text(
                          page["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        // Tombol
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B4C00),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            page["button"]!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.all(4.w),
                  width: _currentIndex == index ? 16.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF2B4C00)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
