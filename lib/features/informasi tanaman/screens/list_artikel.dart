import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'detail_artikel.dart';

class ListArtikelScreen extends StatelessWidget {
  const ListArtikelScreen({super.key});

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
          'Artikel',
          style: AppTheme.heading2.copyWith(
            color: const Color(0xFF466D1D),
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView.separated(
          itemCount: 5,
          separatorBuilder: (context, i) => SizedBox(height: 16.h),
          itemBuilder: (context, i) => _ArtikelCard(
            onTap: i == 0
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DetailArtikelScreen(),
                      ),
                    );
                  }
                : null,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemSelected: (i) {},
      ),
    );
  }
}

class _ArtikelCard extends StatelessWidget {
  final VoidCallback? onTap;
  const _ArtikelCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                'assets/image/artikel_background.png',
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
                    'Langkah Mudah Membuat Pupuk Kandang Dari Kotoran Kambing',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Pengolahan tanah untuk tanaman tomat dilakukan dengan melakukan pembersihan lahan dari tanaman-tanaman liar dan pembajakan tanah.',
                    style: AppTheme.bodySmall.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
