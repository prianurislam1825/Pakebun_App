import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';

import '../services/mqtt_service.dart';
import 'monitoring_screen.dart' show SmartIcon;

// Color levels used for numeric badge coloring
enum _Level { green, yellow, red }

class WeatherMonitoringScreen extends StatefulWidget {
  const WeatherMonitoringScreen({super.key});

  @override
  State<WeatherMonitoringScreen> createState() =>
      _WeatherMonitoringScreenState();
}

class _WeatherMonitoringScreenState extends State<WeatherMonitoringScreen> {
  final MqttService _mqtt = MqttService(broker: 'pentarium.id', port: 1883);

  @override
  void initState() {
    super.initState();
    _mqtt.connect().catchError((_) {});
    _mqtt.env.addListener(_onEnvData);
    _mqtt.aws.addListener(_onAwsData);
  }

  void _onEnvData() => setState(() {});
  void _onAwsData() => setState(() {});

  @override
  void dispose() {
    _mqtt.env.removeListener(_onEnvData);
    _mqtt.aws.removeListener(_onAwsData);
    _mqtt.disconnect();
    super.dispose();
  }

  String _formatDateTime(DateTime? d) {
    if (d == null) return '--';
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(d);
  }

  String _displayNum(num? v, {String suffix = ''}) {
    if (v == null) return '--';
    return '${v.toStringAsFixed(1)}$suffix';
  }

  // Approximate dew point using Magnus formula
  double? _calcDewPoint(double? tempC, double? rh) {
    if (tempC == null || rh == null) return null;
    const a = 17.62;
    const b = 243.12; // °C
    final gamma = (a * tempC) / (b + tempC) + math.log(rh / 100.0);
    return (b * gamma) / (a - gamma);
  }

  _Level _levelForWeather(String title, num? v) {
    if (v == null) return _Level.yellow;
    final val = v.toDouble();
    switch (title) {
      case 'Suhu Udara':
        if (val < 15 || val > 35) return _Level.red;
        if (val < 20 || val > 30) return _Level.yellow;
        return _Level.green;
      case 'Kelembapan Udara':
        if (val < 40 || val > 80) return _Level.red;
        if (val < 50 || val > 70) return _Level.yellow;
        return _Level.green;
      case 'Kecepatan Angin':
        if (val > 15) return _Level.red;
        if (val > 8) return _Level.yellow;
        return _Level.green;
      case 'Radiasi UV':
        if (val > 8) return _Level.red;
        if (val > 5) return _Level.yellow;
        return _Level.green;
      default:
        return _Level.yellow;
    }
  }

  (Color, Color) _colorsForLevel(_Level level) {
    switch (level) {
      case _Level.green:
        return (const Color(0xFF64C27B), Colors.white);
      case _Level.yellow:
        return (const Color(0xFFF6C744), Colors.black);
      case _Level.red:
        return (const Color(0xFFE53935), Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final env = _mqtt.env.value;
    final aws = _mqtt.aws.value;
    final isConnected = _mqtt.connected.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'Cuaca & Lingkungan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go('/monitoring'),
        ),
      ),
      body: SingleChildScrollView(
        child: PagePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Connection status
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.blue.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isConnected ? Colors.blue : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.cloud : Icons.cloud_off,
                      color: isConnected ? Colors.blue : Colors.red,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        isConnected
                            ? 'Data Cuaca & Lingkungan Terkini'
                            : 'Tidak Terhubung',
                        style: TextStyle(
                          color: isConnected
                              ? Colors.blue.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (aws?.receivedAt != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                  child: Text(
                    'Update: ${_formatDateTime(aws?.receivedAt)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                SizedBox(height: 24.h),

              // AWS Weather section
              Text(
                'Cuaca AWS (Weather Station)',
                style: AppTheme.heading2.copyWith(
                  color: const Color(0xFF2B4C00),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Data cuaca dari stasiun cuaca AWS',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),

              // AWS Weather cards grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.1,
                children: [
                  _buildWeatherCard(
                    'Suhu Udara (AWS)',
                    'assets/monitoring/suhu_udara.svg',
                    aws?.temp,
                    suffix: '°C',
                    color: const Color(0xFFFF5722),
                  ),
                  _buildWeatherCard(
                    'Kelembapan (AWS)',
                    'assets/monitoring/kelembapan_udara.svg',
                    aws?.hum,
                    suffix: '%',
                    color: const Color(0xFF2196F3),
                  ),
                  _buildWeatherCard(
                    'Kecepatan Angin',
                    'assets/monitoring/kecepatan_angin.svg',
                    aws?.windSpeed,
                    suffix: ' m/s',
                    color: const Color(0xFF607D8B),
                  ),
                  _buildWeatherCard(
                    'Radiasi UV',
                    'assets/monitoring/uv.svg',
                    aws?.uv,
                    suffix: '',
                    color: const Color(0xFF9C27B0),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // AWS Full width cards
              _buildFullWeatherCard(
                'Arah Angin',
                'assets/monitoring/arah_angin.svg',
                aws?.windDir ?? '--',
                color: const Color(0xFF607D8B),
              ),
              SizedBox(height: 12.h),
              _buildFullWeatherCard(
                'Tekanan Udara (AWS)',
                'assets/monitoring/tekanan_udara.svg',
                '${_displayNum(aws?.pressure)} hPa',
                color: const Color(0xFF795548),
              ),
              SizedBox(height: 12.h),
              _buildFullWeatherCard(
                'Intensitas Cahaya (AWS)',
                'assets/monitoring/intesitas_cahaya.svg',
                '${_displayNum(aws?.light)} Lux',
                color: const Color(0xFFFFEB3B),
              ),
              SizedBox(height: 12.h),
              _buildFullWeatherCard(
                'Titik Embun',
                'assets/monitoring/ttitik_embun.svg',
                '${_displayNum(aws?.dewPoint ?? _calcDewPoint(aws?.temp, aws?.hum))} °C',
                color: const Color(0xFF00BCD4),
              ),

              SizedBox(height: 32.h),

              // Environment sensors section
              Text(
                'Sensor Lingkungan Kebun',
                style: AppTheme.heading2.copyWith(
                  color: const Color(0xFF2B4C00),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Data dari sensor BME & BH di sekitar kebun',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),

              // Environment sensors grid (BME280: temp, hum, pressure only)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.1,
                children: [
                  _buildWeatherCard(
                    'Suhu Udara',
                    'assets/monitoring/suhu_udara.svg',
                    env?.temp,
                    suffix: '°C',
                    color: const Color(0xFFFF5722),
                  ),
                  _buildWeatherCard(
                    'Kelembapan Udara',
                    'assets/monitoring/kelembapan_udara.svg',
                    env?.hum,
                    suffix: '%',
                    color: const Color(0xFF2196F3),
                  ),
                  _buildWeatherCard(
                    'Tekanan Udara',
                    'assets/monitoring/tekanan_udara.svg',
                    env?.pressure,
                    suffix: ' hPa',
                    color: const Color(0xFF795548),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Rain section
              Text(
                'Data Curah Hujan',
                style: AppTheme.heading2.copyWith(
                  color: const Color(0xFF2B4C00),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.0,
                children: [
                  _buildRainCard(
                    'Curah 1 Minggu',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainLastWeek ?? aws?.rainToday,
                    suffix: ' mm',
                  ),
                  _buildRainCard(
                    'Curah 1 Hari',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainLastDay ?? aws?.rainLastHour,
                    suffix: ' mm',
                  ),
                  _buildRainCard(
                    'Intensitas 1 Jam',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainRate1h ?? aws?.rainRate10m,
                    suffix: ' mm/h',
                  ),
                  _buildRainCard(
                    'Curah 1 Bulan',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainLastMonth,
                    suffix: ' mm',
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Annual rain card
              _buildFullRainCard(
                'Curah Hujan (Kumulatif 1 Tahun)',
                'assets/monitoring/curah_hujan.svg',
                aws?.rain,
                suffix: ' mm',
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
    String title,
    String icon,
    num? value, {
    String suffix = '',
    required Color color,
  }) {
    final level = _levelForWeather(title, value);
    final colors = _colorsForLevel(level);
    final valueText = _displayNum(value, suffix: suffix);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  size: 20.w,
                  tintForVector: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.$1,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    color: colors.$2,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWeatherCard(
    String title,
    String icon,
    String value, {
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SmartIcon(
              assetPath: icon,
              size: 24.w,
              tintForVector: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainCard(
    String title,
    String icon,
    num? value, {
    String suffix = '',
  }) {
    final valueText = _displayNum(value, suffix: suffix);
    final color = const Color(0xFF3F51B5);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  size: 20.w,
                  tintForVector: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRainCard(
    String title,
    String icon,
    num? value, {
    String suffix = '',
  }) {
    final valueText = _displayNum(value, suffix: suffix);
    final color = const Color(0xFF3F51B5);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SmartIcon(
              assetPath: icon,
              size: 24.w,
              tintForVector: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              valueText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
