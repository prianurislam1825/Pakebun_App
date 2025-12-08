import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';

class EquipmentControlScreen extends StatelessWidget {
  const EquipmentControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        title: const Text(
          'Kontrol Peralatan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go('/monitoring'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'Kontrol Peralatan',
              style: AppTheme.heading2.copyWith(
                color: const Color(0xFF2B4C00),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24.h),

            // Equipment controls
            _buildControlCard(
              'Penyiraman',
              Icons.water_drop,
              'Siram otomatis berdasarkan kelembapan tanah',
              const Color(0xFF2196F3),
            ),
            SizedBox(height: 16.h),
            _buildControlCard(
              'Cahaya',
              Icons.wb_sunny,
              'Kontrol pencahayaan LED untuk tanaman',
              const Color(0xFFFFEB3B),
            ),
            SizedBox(height: 16.h),
            _buildControlCard(
              'Pendinginan',
              Icons.ac_unit,
              'Sistem pendingin untuk suhu optimal',
              const Color(0xFF00BCD4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(
    String title,
    IconData icon,
    String description,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 28.w, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18.w),
        ],
      ),
    );
  }
}
