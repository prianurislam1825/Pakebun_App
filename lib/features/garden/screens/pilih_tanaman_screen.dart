import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';

class PilihTanamanScreen extends StatelessWidget {
  PilihTanamanScreen({super.key});

  final List<Map<String, String>> tanamanList = [
    {
      'title': 'Semangka',
      'latin': '(Citrullus)',
      'image': 'assets/image/semangka.png',
    },
    {
      'title': 'Jagung',
      'latin': '(Cucumis)',
      'image': 'assets/image/jagung.png',
    },
    {'title': 'Tomat', 'latin': '(Solanum)', 'image': 'assets/image/tomat.png'},
    {
      'title': 'Terong',
      'latin': '(Solanum)',
      'image': 'assets/image/terong.png',
    },
    {'title': 'Melon', 'latin': '(Cucumis)', 'image': 'assets/image/melon.png'},
    {
      'title': 'Kentang',
      'latin': '(Solanum)',
      'image': 'assets/image/kentang.png',
    },
    {
      'title': 'Cabai',
      'latin': '(Capsicum)',
      'image': 'assets/image/cabai.png',
    },
    {
      'title': 'Jagung',
      'latin': '(Cucumis)',
      'image': 'assets/image/timun.png',
    },
    {
      'title': 'Kangkung',
      'latin': '(Glycine)',
      'image': 'assets/image/kangkung.png',
    },
    {'title': 'Sawi', 'latin': '(Glycine)', 'image': 'assets/image/sawi.png'},
  ];

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
          'Pilih Tanaman',
          style: AppTheme.heading2.copyWith(
            color: const Color(0xFF466D1D),
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
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
          ),
          SizedBox(height: 18.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 2.8,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: tanamanList.map((tanaman) {
                return _TanamanItem(
                  image: tanaman['image']!,
                  title: tanaman['title']!,
                  subtitle: tanaman['latin']!,
                  onTap: () {
                    Navigator.of(context).pop(tanaman['title']!);
                  },
                );
              }).toList(),
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
        onTap: onTap,
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
