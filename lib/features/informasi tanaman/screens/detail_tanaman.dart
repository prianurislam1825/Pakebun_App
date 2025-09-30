import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';

class DetailTanamanScreen extends StatelessWidget {
  const DetailTanamanScreen({super.key});

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
                  'assets/image/tomat_background.png',
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tomat (Solanum)',
                  style: AppTheme.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Text('Keluarga', style: AppTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        'Solanaceae',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Genus', style: AppTheme.bodyMedium)),
                    Expanded(
                      child: Text(
                        'Solanum',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Estimasi Panen', style: AppTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        '± 14-16 Minggu',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Deskripsi',
                  style: AppTheme.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Tomat merupakan buah yang memiliki warna merah menarik serta kaya akan kandungan vitamin seperti vitamin C. Maka tidak salah kalau tomat sangat bermanfaat menjaga sistem imun tubuh.',
                  style: AppTheme.bodyMedium,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Kondisi Terbaik',
                  style: AppTheme.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  children: const [
                    _KondisiItem(value: '30', label: 'Suhu (°C)'),
                    _KondisiItem(value: '198', label: 'Nutrisi Tanah'),
                    _KondisiItem(value: '30', label: 'Kelembapan (%)'),
                    _KondisiItem(value: '10', label: 'Cahaya (Lux)'),
                    _KondisiItem(value: '23', label: 'Kelembapan Tanah (%)'),
                    _KondisiItem(value: '70', label: 'PH (✓)'),
                  ],
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

class _KondisiItem extends StatelessWidget {
  final String value;
  final String label;

  const _KondisiItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.w,
      height: 40.h,
      child: Material(
        color: const Color(0xFF466D1D),
        borderRadius: BorderRadius.circular(8.r),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
