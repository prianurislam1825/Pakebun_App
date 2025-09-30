import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';

class DetailArtikelScreen extends StatelessWidget {
  const DetailArtikelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.asset(
                  'assets/image/artikel_background.png',
                  width: double.infinity,
                  height: 260.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 36.h,
                left: 16.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: SvgPicture.asset(
                    'assets/icon/kembali_putih.svg',
                    width: 32.w,
                    height: 32.w,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah Mudah Membuat Pupuk Kandang\nDari Kotoran Kambing',
                      style: AppTheme.heading3,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Pengolahan tanah untuk tanaman tomat dilakukan dengan melakukan pembersihan lahan dari tanaman-tanaman liar dan pembajakan tanah. Pembajakan tanah dilakukan dengan menghancurkan bongkahan-bongkahan tanah sehingga menjadi lebih halus dan lebih gembur.\n\nPengolahan tanah untuk tanaman tomat dilakukan dengan melakukan pembersihan lahan dari tanaman-tanaman liar dan pembajakan tanah. Pembajakan tanah dilakukan dengan menghancurkan bongkahan-bongkahan tanah sehingga menjadi lebih halus dan lebih gembur.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Text(
                          'Sumber Artikel : ',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'www.kompas.com',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
