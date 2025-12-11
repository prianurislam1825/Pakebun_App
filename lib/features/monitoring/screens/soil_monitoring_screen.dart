import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/common/widgets/page_padding.dart';

import '../services/soil_mqtt_service.dart';
import 'monitoring_screen.dart' show SmartIcon;

// Color levels used for numeric badge coloring
enum _Level { green, yellow, red }

class SoilMonitoringScreen extends StatefulWidget {
  const SoilMonitoringScreen({super.key});

  @override
  State<SoilMonitoringScreen> createState() => _SoilMonitoringScreenState();
}

class _SoilMonitoringScreenState extends State<SoilMonitoringScreen> {
  final SoilMqttService _soilMqtt = SoilMqttService(
    broker: 'pentarium.id',
    port: 1883,
    deviceId: 'F0F06D9FE8',
  );

  @override
  void initState() {
    super.initState();
    _soilMqtt
        .connect()
        .then((_) {
          // Request last data from InfluxDB after connected
          _soilMqtt.requestLastData();
        })
        .catchError((_) {});
    _soilMqtt.soil.addListener(_onSoilData);
  }

  void _onSoilData() => setState(() {});

  @override
  void dispose() {
    _soilMqtt.soil.removeListener(_onSoilData);
    _soilMqtt.disconnect();
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

  _Level _levelForSoil(String title, num? v) {
    if (v == null) return _Level.yellow;
    final val = v.toDouble();
    switch (title) {
      case 'Kelembapan Tanah':
        if (val < 30 || val > 80) return _Level.red;
        if (val < 40 || val > 70) return _Level.yellow;
        return _Level.green;
      case 'Suhu Tanah':
        if (val < 15 || val > 35) return _Level.red;
        if (val < 20 || val > 30) return _Level.yellow;
        return _Level.green;
      case 'pH Tanah':
        if (val < 5.0 || val > 7.5) return _Level.red;
        if (val < 5.5 || val > 7.0) return _Level.yellow;
        return _Level.green;
      case 'EC Tanah':
        if (val < 100 || val > 2000) return _Level.red;
        if (val < 200 || val > 1200) return _Level.yellow;
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
    final soil = _soilMqtt.soil.value;
    final isConnected = _soilMqtt.connected.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC34A),
        title: const Text(
          'Monitoring Tanah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go('/monitoring'),
        ),
      ),
      body: PagePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(top: 16.h),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isConnected ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        isConnected ? 'Terhubung ke Sensor' : 'Tidak Terhubung',
                        style: TextStyle(
                          color: isConnected
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (soil?.receivedAt != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                  child: Text(
                    'Update: ${_formatDateTime(soil?.receivedAt)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                SizedBox(height: 24.h),

              // Soil metrics section
              Text(
                'Parameter Tanah',
                style: AppTheme.heading2.copyWith(
                  color: const Color(0xFF2B4C00),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),

              // Soil cards grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.2,
                children: [
                  _buildSoilCard(
                    'Kelembapan Tanah',
                    'assets/monitoring/kelembapan_tanah.svg',
                    soil?.hum,
                    suffix: '%',
                  ),
                  _buildSoilCard(
                    'Suhu Tanah',
                    'assets/monitoring/suhu_tanah.svg',
                    soil?.temp,
                    suffix: '°C',
                  ),
                  _buildSoilCard(
                    'pH Tanah',
                    'assets/monitoring/ph.svg',
                    soil?.ph,
                    suffix: '',
                  ),
                  _buildSoilCard(
                    'Conductivity',
                    'assets/monitoring/status_tanah.svg',
                    soil?.cond,
                    suffix: ' µS',
                  ),
                  _buildNutrientCard(
                    'Nitrogen (N)',
                    'assets/monitoring/npk.svg',
                    soil?.n,
                    suffix: ' mg',
                  ),
                  _buildNutrientCard(
                    'Fosfor (P)',
                    'assets/monitoring/npk.svg',
                    soil?.p,
                    suffix: ' mg',
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Potassium full width card
              _buildNutrientCardFull(
                'Kalium (K)',
                'assets/monitoring/npk.svg',
                soil?.k,
                suffix: ' mg',
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoilCard(
    String title,
    String icon,
    num? value, {
    String suffix = '',
  }) {
    final level = _levelForSoil(title, value);
    final colors = _colorsForLevel(level);
    final valueText = _displayNum(value, suffix: suffix);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2B4C00),
            const Color(0xFF2B4C00).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama parameter di atas
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const Spacer(),
          // Gambar dan nilai di bawah
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SmartIcon(
                  assetPath: icon,
                  size: 24.w,
                  tintForVector: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colors.$1,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    color: colors.$2,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
    String title,
    String icon,
    num? value, {
    String suffix = '',
  }) {
    final valueText = _displayNum(value, suffix: suffix);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF4CAF50).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama parameter di atas
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const Spacer(),
          // Gambar dan nilai di bawah
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SmartIcon(
                  assetPath: icon,
                  size: 24.w,
                  tintForVector: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCardFull(
    String title,
    String icon,
    num? value, {
    String suffix = '',
  }) {
    final valueText = _displayNum(value, suffix: suffix);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF4CAF50).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
