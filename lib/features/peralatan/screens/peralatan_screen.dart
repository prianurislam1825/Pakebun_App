import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:pakebun_app/features/peralatan/screens/pilih_tanaman_screen.dart';

class PeralatanScreen extends StatelessWidget {
  const PeralatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF466D1D),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Peralatan',
          style: AppTheme.heading2.copyWith(
            color: const Color(0xFF466D1D),
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
          ),
        ),
      ),
      body: PagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              alignment: WrapAlignment.center,
              children: [
                _PeralatanItem(
                  image: 'assets/image/deteksi_hama.png',
                  label: 'Deteksi\nHama',
                  jenisPeralatan: 'Deteksi Hama',
                ),
                _PeralatanItem(
                  image: 'assets/image/populasi_tanaman.png',
                  label: 'Populasi\nTanaman',
                  jenisPeralatan: 'Populasi Tanaman',
                ),
                _PeralatanItem(
                  image: 'assets/image/kebutuhan_air.png',
                  label: 'Kebutuhan\nAir',
                  jenisPeralatan: 'Kebutuhan Air',
                ),
                _PeralatanItem(
                  image: 'assets/image/kebutuhan_pupuk.png',
                  label: 'Kebutuhan\nPupuk',
                  jenisPeralatan: 'Kebutuhan Pupuk',
                ),
                _PeralatanItem(
                  image: 'assets/image/produktivitas_tanaman.png',
                  label: 'Produktifitas\nTanaman',
                  jenisPeralatan: 'Produktifitas Tanaman',
                  isWide: true,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
        onItemSelected: _onNavBarTapped,
      ),
    );
  }

  static void _onNavBarTapped(int index) {
    // Implement navigation logic if needed
  }
}

class _PeralatanItem extends StatelessWidget {
  final String image;
  final String label;
  final String jenisPeralatan;
  final bool isWide;

  const _PeralatanItem({
    required this.image,
    required this.label,
    required this.jenisPeralatan,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isWide ? 180.w : 150.w,
      height: 80.h,
      child: Material(
        color: const Color(0xFF466D1D),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PilihTanamanScreen(jenisPeralatan: jenisPeralatan),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(image, width: 32.w, height: 32.w),
              ),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
