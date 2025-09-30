import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:pakebun_app/features/peralatan/screens/detail_solusi_penyakit_screen.dart';

class DetailTanamanPeralatanScreen extends StatelessWidget {
  final String namaTanaman;
  final String latinTanaman;
  final String gambarBackground;
  const DetailTanamanPeralatanScreen({
    super.key,
    required this.namaTanaman,
    required this.latinTanaman,
    required this.gambarBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.r),
                  bottomRight: Radius.circular(40.r),
                ),
                child: Image.asset(
                  gambarBackground,
                  width: double.infinity,
                  height: 220.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 32.h,
                left: 16.w,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icon/kembali_putih.svg',
                    width: 28.w,
                    height: 28.w,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '$namaTanaman ($latinTanaman)',
            style: AppTheme.heading3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              children: const [
                _FiturPenyakit(
                  image: 'assets/image/layu_bakteri.png',
                  label: 'Layu Bakteri',
                ),
                _FiturPenyakit(
                  image: 'assets/image/bercak_daun.png',
                  label: 'Bercak Daun',
                ),
                _FiturPenyakit(
                  image: 'assets/image/busuk_fusarium.png',
                  label: 'Busuk Fusarium',
                ),
                _FiturPenyakit(
                  image: 'assets/image/virus_daun.png',
                  label: 'Virus Penggulung Daun',
                ),
                _FiturPenyakit(
                  image: 'assets/image/busuk_phytophthora.png',
                  label: 'Busuk Phytophthora',
                ),
                _FiturPenyakit(
                  image: 'assets/image/virus_y.png',
                  label: 'Virus Y',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemSelected: (i) {},
      ),
    );
  }
}

class _FiturPenyakit extends StatelessWidget {
  final String image;
  final String label;

  const _FiturPenyakit({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.w,
      height: 56.h,
      child: Material(
        color: const Color(0xFF466D1D),
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {
            if (label == 'Layu Bakteri') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DetailSolusiPenyakitScreen(),
                ),
              );
            }
            // Tambahkan else if untuk penyakit lain jika perlu
          },
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Image.asset(image, fit: BoxFit.contain),
              ),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
