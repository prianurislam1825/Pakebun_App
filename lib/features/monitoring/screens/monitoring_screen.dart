import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/common/widgets/base64_svg_image.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Monitoring',
            style: TextStyle(
              color: const Color(0xFF35591A),
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF35591A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            _sectionTitle('Peralatan'),
            SizedBox(height: 8.h),
            _deviceGrid(context),
            SizedBox(height: 12.h),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ED957),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  minimumSize: Size(220.w, 40.h),
                  elevation: 0,
                ),
                onPressed: () {},
                icon: Icon(Icons.add_circle, color: Colors.white, size: 22.sp),
                label: Text(
                  'Tambah Perangkat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            _sectionTitle('Monitoring Tanah'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _monitorCard(
                  context,
                  'Status Tanah',
                  'assets/monitoring/status_tanah.svg',
                  'Baik',
                  const Color(0xFF35591A),
                  const Color(0xFF7ED957),
                ),
                _monitorCard(
                  context,
                  'Kelembapan Tanah',
                  'assets/monitoring/kelembapan_tanah.svg',
                  '60 %',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Suhu Tanah',
                  'assets/monitoring/suhu_tanah.svg',
                  '27°C',
                  const Color(0xFF35591A),
                  const Color(0xFF7ED957),
                ),
                _monitorCard(
                  context,
                  'pH Tanah',
                  'assets/monitoring/ph.svg',
                  '4.5',
                  const Color(0xFF35591A),
                  const Color(0xFFD32F2F),
                ),
                _monitorCard(
                  context,
                  'Nitrogen',
                  'assets/monitoring/npk.svg',
                  'Cukup',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Fosfor',
                  'assets/monitoring/npk.svg',
                  'Cukup',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Kalium',
                  'assets/monitoring/npk.svg',
                  'Cukup',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            _sectionTitle('Monitoring Lingkungan'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _monitorCard(
                  context,
                  'Suhu Udara',
                  'assets/monitoring/suhu_udara.svg',
                  '27°C',
                  const Color(0xFF35591A),
                  const Color(0xFF7ED957),
                ),
                _monitorCard(
                  context,
                  'Kelembapan Udara',
                  'assets/monitoring/kelembapan_udara.svg',
                  '60 % RH',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Tekanan Udara',
                  'assets/monitoring/tekanan_udara.svg',
                  'hpa',
                  const Color(0xFF35591A),
                  const Color(0xFF7ED957),
                ),
                _monitorCard(
                  context,
                  'Intensitas Cahaya',
                  'assets/monitoring/intesitas_cahaya.svg',
                  '2000 Lux',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            _sectionTitle('Monitoring Cuaca'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _monitorCard(
                  context,
                  'Suhu Udara',
                  'assets/monitoring/suhu_udara.svg',
                  '°C',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Kelembaban Udara',
                  'assets/monitoring/kelembapan_udara.svg',
                  '%',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Radiasi UV',
                  'assets/monitoring/uv.svg',
                  'UV',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Kecepatan Angin',
                  'assets/monitoring/kecepatan_angin.svg',
                  'm/s',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Arah Angin',
                  'assets/monitoring/arah_angin.svg',
                  '°N',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Tekanan Udara',
                  'assets/monitoring/tekanan_udara.svg',
                  'hPa',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Curah Hujan',
                  'assets/monitoring/curah_hujan.svg',
                  'mm/h',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Intensitas Cahaya',
                  'assets/monitoring/intesitas_cahaya.svg',
                  'W/m2',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
                _monitorCard(
                  context,
                  'Titik Embun',
                  'assets/monitoring/ttitik_embun.svg',
                  '°C',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            _sectionTitle('Monitoring Daya'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _monitorCard(
                  context,
                  'Baterai',
                  'assets/monitoring/baterai.svg',
                  '12.4 V\n70%',
                  const Color(0xFF35591A),
                  const Color(0xFF7ED957),
                ),
                _monitorCard(
                  context,
                  'Panel Surya',
                  'assets/monitoring/panel_surya.svg',
                  '18 W\nMengisi',
                  const Color(0xFF35591A),
                  const Color(0xFFFFC700),
                ),
              ],
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF35591A),
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
    );
  }

  Widget _deviceGrid(BuildContext context) {
    final data = [
      ('Penyiraman', 'assets/icon/penyiraman.svg'),
      ('Cahaya', 'assets/icon/cahaya.svg'),
      ('Pendinginan', 'assets/icon/pendinginan.svg'),
    ];
    final double horizontalPadding = 20.w;
    final double available =
        MediaQuery.of(context).size.width - (horizontalPadding * 2);
    final double spacing = 12.w;
    const int columns = 2; // 2 sejajar sesuai permintaan
    final double itemWidth = (available - spacing * (columns - 1)) / columns;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: data
          .map((item) => _deviceButton(item.$1, item.$2, width: itemWidth))
          .toList(),
    );
  }

  Widget _deviceButton(String label, String iconPath, {required double width}) {
    return SizedBox(
      width: width,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFF35591A),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(iconPath, width: 22.w, height: 22.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monitorCard(
    BuildContext context,
    String title,
    String iconPath,
    String value,
    Color bgColor,
    Color valueColor, {
    bool isFull = false,
  }) {
    final double horizontalPadding = 20.w; // match parent padding
    final double available =
        MediaQuery.of(context).size.width - (horizontalPadding * 2);
    final double spacing = 12.w;
    final double halfWidth = (available - spacing) / 2;
    final double cardWidth = isFull ? available : halfWidth;
    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _monitoringIcon(iconPath),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.center,
            child: _buildValueBadges(value, valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildValueBadges(String value, Color valueColor) {
    // Split by newline: each line becomes its own badge when there are multiple indicators.
    final parts = value.split('\n');
    if (parts.length == 1) {
      return _valueBadge(parts.first, valueColor);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < parts.length; i++) ...[
          _valueBadge(parts[i], valueColor),
          if (i != parts.length - 1) SizedBox(width: 6.w),
        ],
      ],
    );
  }

  Widget _valueBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _monitoringIcon(String path) {
    // Monitoring icons are SVG wrappers embedding base64 PNGs (unsupported by flutter_svg).
    // Detect by folder path; if monitoring, use Base64SvgImage; else normal SvgPicture.
    if (path.contains('assets/monitoring/')) {
      return Base64SvgImage(path, size: 22.w);
    }
    return SvgPicture.asset(path, width: 22.w, height: 22.w);
  }
}
