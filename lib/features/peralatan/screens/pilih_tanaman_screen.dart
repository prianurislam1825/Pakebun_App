import 'package:pakebun_app/features/peralatan/screens/detail_tanaman_peralatan.dart';
import 'package:pakebun_app/features/peralatan/screens/kebutuhan_pupuk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';

class PilihTanamanScreen extends StatelessWidget {
  final String jenisPeralatan;
  const PilihTanamanScreen({super.key, required this.jenisPeralatan});

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
          jenisPeralatan,
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
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFFBDBDBD)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Tanaman',
                        border: InputBorder.none,
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: const Color(0xFFBDBDBD),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 2.8,
                children: [
                  _TanamanItem(
                    image: 'assets/image/semangka.png',
                    title: 'Semangka',
                    subtitle: '(Citrullus)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/jagung.png',
                    title: 'Jagung',
                    subtitle: '(Cucumis)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/tomat.png',
                    title: 'Tomat',
                    subtitle: '(Solanum)',
                    onTap: () {
                      if (jenisPeralatan == 'Kebutuhan Pupuk') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const KebutuhanPupukScreen(
                              namaTanaman: 'Tomat',
                              latinTanaman: 'Solanum',
                              gambarBackground:
                                  'assets/image/tomat_background.png',
                            ),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailTanamanPeralatanScreen(
                              namaTanaman: 'Tomat',
                              latinTanaman: 'Solanum',
                              gambarBackground:
                                  'assets/image/tomat_background.png',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _TanamanItem(
                    image: 'assets/image/terong.png',
                    title: 'Terong',
                    subtitle: '(Solanum)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/melon.png',
                    title: 'Melon',
                    subtitle: '(Cucumis)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/kentang.png',
                    title: 'Kentang',
                    subtitle: '(Solanum)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/cabai.png',
                    title: 'Cabai',
                    subtitle: '(Capsicum)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/timun.png',
                    title: 'Timun',
                    subtitle: '(Cucumis)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/kangkung.png',
                    title: 'Kangkung',
                    subtitle: '(Glycine)',
                  ),
                  _TanamanItem(
                    image: 'assets/image/sawi.png',
                    title: 'Sawi',
                    subtitle: '(Glycine)',
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tampilkan Lebih Banyak',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemSelected: (i) {},
      ),
    );
  }
}

class _TanamanItem extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _TanamanItem({
    required this.image,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF466D1D),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap ?? () {},
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
