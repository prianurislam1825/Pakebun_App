import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';

// Import SmartIcon from the existing monitoring screen
import 'monitoring_screen.dart' show SmartIcon;

class MonitoringDashboardScreen extends StatelessWidget {
  const MonitoringDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4C00),
        title: const Text(
          'Monitoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: PagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text(
              'Pilih Kategori Monitoring',
              style: AppTheme.heading2.copyWith(
                color: const Color(0xFF2B4C00),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Monitor berbagai aspek kebun Anda secara real-time',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildMonitoringCard(
                      context,
                      title: 'Monitoring\nTanah',
                      icon: 'assets/monitoring/kelembapan_tanah.svg',
                      description: 'pH, EC, NPK, Kelembapan & Suhu',
                      color: const Color(0xFF8BC34A),
                      route: '/monitoring/soil',
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildMonitoringCard(
                      context,
                      title: 'Cuaca &\nLingkungan',
                      icon: 'assets/monitoring/suhu_udara.svg',
                      description: 'Suhu, Kelembapan, Hujan, Angin & UV',
                      color: const Color(0xFF2196F3),
                      route: '/monitoring/weather',
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringCard(
    BuildContext context, {
    required String title,
    required String icon,
    required String description,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SmartIcon(
                    assetPath: icon,
                    size: 18.w,
                    tintForVector: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10.sp,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 12.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
