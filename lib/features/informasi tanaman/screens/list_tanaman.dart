import 'detail_tanaman.dart';
import 'list_artikel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ListTanamanScreen extends StatelessWidget {
  const ListTanamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icon/kembali_hijau.svg',
            width: 24.w,
            height: 24.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Informasi Tanaman',
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
                        hintText: 'Cari Halaman',
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DetailTanamanScreen(),
                        ),
                      );
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
                    image: 'assets/image/jagung.png',
                    title: 'Jagung',
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
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Artikel', style: AppTheme.heading3),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ListArtikelScreen(),
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
            SizedBox(height: 10.h),
            _ArtikelCard(),
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

class _ArtikelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF466D1D),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Image.asset(
              'assets/image/tomat_artikel.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 Jam Yang Lalu',
                  style: AppTheme.caption.copyWith(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tips Mengobati Sakit Pada Tanaman Tomat',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Pengobatan sederhana untuk tanaman tomat dilakukan dengan membersihkan daun-daun yang terinfeksi, serta memberikan nutrisi dan air yang cukup.',
                  style: AppTheme.bodySmall.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
