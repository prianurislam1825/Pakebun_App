import 'package:pakebun_app/features/informasi tanaman/screens/list_tanaman.dart';
import 'package:pakebun_app/features/peralatan/screens/peralatan_screen.dart';
import 'package:pakebun_app/features/peralatan/screens/pilih_tanaman_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  int _currentBanner = 0;
  Timer? _autoScrollTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PagePadding(
              applyTop: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopLogo(),
                  SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
            PagePadding(child: _buildBannerCarousel()),
            PagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppTheme.spacingL),
                  _buildPeralatanSection(),
                  SizedBox(height: AppTheme.spacingL),
                  _buildInformasiTanamanSection(),
                  SizedBox(height: AppTheme.spacingXL),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildTopLogo() {
    return Center(
      child: SvgPicture.asset('assets/vector/logo_pakebun.svg', width: 140.w),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBannerCarousel() {
    final banners = const [
      'assets/image/dashboard_1.png',
      'assets/image/dashboard_2.png',
      'assets/image/dashboard_3.png',
    ];

    // start auto scroll once widgets built
    _autoScrollTimer ??= Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentBanner + 1) % banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });

    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(banners[index], fit: BoxFit.cover),
                    Container(color: Colors.black.withValues(alpha: 0.15)),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _currentBanner == i ? 14.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: _currentBanner == i
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeralatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Peralatan', style: AppTheme.heading3),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PeralatanScreen(),
                  ),
                );
              },
              child: Text(
                'Lihat Semua',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          mainAxisSpacing: AppTheme.spacingM,
          crossAxisSpacing: AppTheme.spacingM,
          children: [
            _equipmentItem(
              'Deteksi\nHama',
              'assets/image/deteksi_hama.png',
              'Deteksi Hama',
            ),
            _equipmentItem(
              'Populasi\nTanaman',
              'assets/image/populasi_tanaman.png',
              'Populasi Tanaman',
            ),
            _equipmentItem(
              'Kebutuhan\nAir',
              'assets/image/kebutuhan_air.png',
              'Kebutuhan Air',
            ),
            _equipmentItem(
              'Kebutuhan\nPupuk',
              'assets/image/kebutuhan_pupuk.png',
              'Kebutuhan Pupuk',
            ),
          ],
        ),
      ],
    );
  }

  Widget _equipmentItem(String title, String imagePath, String jenisPeralatan) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PilihTanamanScreen(jenisPeralatan: jenisPeralatan),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2B4C00),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(6.w),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformasiTanamanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Informasi Tanaman', style: AppTheme.heading3),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ListTanamanScreen(),
                  ),
                );
              },
              child: Text(
                'Lihat Semua',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(child: _plantInfoCard('Melon', 'assets/image/melon.png')),
            SizedBox(width: AppTheme.spacingM),
            Expanded(child: _plantInfoCard('Tomat', 'assets/image/tomat.png')),
          ],
        ),
      ],
    );
  }

  Widget _plantInfoCard(String title, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B4C00),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(10.w),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: 36.w,
                height: 36.w,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
