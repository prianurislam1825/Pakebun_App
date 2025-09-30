import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/monitoring/screens/monitoring_screen.dart';
import 'package:pakebun_app/features/garden/screens/setting_threshold_screen.dart';
import 'package:pakebun_app/features/garden/screens/setting_jadwal_screen.dart';

class GardenDetailFullScreen extends StatefulWidget {
  final String gardenName;
  final String gardenImagePath;
  final String plantImagePath;
  final List<Map<String, dynamic>> zones;
  final int initialZoneIndex;

  const GardenDetailFullScreen({
    super.key,
    required this.gardenName,
    required this.gardenImagePath,
    required this.plantImagePath,
    required this.zones,
    this.initialZoneIndex = 0,
  });

  @override
  State<GardenDetailFullScreen> createState() => _GardenDetailFullScreenState();
}

class _GardenDetailFullScreenState extends State<GardenDetailFullScreen> {
  static const String _dummyUpdate = '03/09/2025 : 19:00:00';
  static const String _dummyUpdateSmall = '03/09/2025 : 18:50:00';
  static const bool _harvestNow = true; // manual placeholder

  // Add device modal & button removed per request (already handled earlier screen)

  late int _currentZoneIndex;

  @override
  void initState() {
    super.initState();
    _currentZoneIndex = widget.initialZoneIndex;
  }

  void _nextZone() {
    if (_currentZoneIndex < widget.zones.length - 1) {
      setState(() {
        _currentZoneIndex++;
      });
    }
  }

  void _prevZone() {
    if (_currentZoneIndex > 0) {
      setState(() {
        _currentZoneIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = widget.zones;
    final currentZone = zones.isNotEmpty
        ? zones[_currentZoneIndex % zones.length]
        : <String, dynamic>{};
    final status = 'Aktif'; // placeholder status
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF35591A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Detail Kebun',
          style: TextStyle(
            color: const Color(0xFF35591A),
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGardenImageSmall(widget.gardenImagePath),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.gardenName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF35591A),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _StatusBadgeFull(status: status, width: 140.w),
                        SizedBox(height: 6.h),
                        _LiveButtonFull(onTap: () {}, width: 140.w),
                        SizedBox(height: 4.h),
                        Text(
                          'Update: $_dummyUpdateSmall',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF3A3A3A),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              Text(
                'Informasi Zona',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
              SizedBox(height: 10.h),
              _ZoneCarouselFull(
                zone: currentZone,
                hasPrev: zones.length > 1,
                hasNext: zones.length > 1,
                onPrev: zones.length > 1 ? _prevZone : null,
                onNext: zones.length > 1 ? _nextZone : null,
                updateText: _dummyUpdateSmall,
                harvestNow: _harvestNow,
                zoneIndex: _currentZoneIndex,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _ActionRectBtnFull(
                      icon: Icons.tune,
                      label: 'Treshold',
                      onTap: () {
                        final zonaName =
                            (currentZone['zoneName'] ??
                                    'Zona ${_currentZoneIndex + 1}')
                                .toString();
                        final plantName =
                            (currentZone['plantName'] ?? widget.gardenName)
                                .toString();
                        final plantImage =
                            (currentZone['plantImage'] ?? widget.plantImagePath)
                                .toString();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingThresholdScreen(
                              zona: zonaName,
                              namaTanaman: plantName,
                              gambarTanaman: plantImage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _ActionRectBtnFull(
                      icon: Icons.event_note_outlined,
                      label: 'Jadwal',
                      onTap: () {
                        final zonaName =
                            (currentZone['zoneName'] ??
                                    'Zona ${_currentZoneIndex + 1}')
                                .toString();
                        final plantName =
                            (currentZone['plantName'] ?? widget.gardenName)
                                .toString();
                        final plantImage =
                            (currentZone['plantImage'] ?? widget.plantImagePath)
                                .toString();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingJadwalScreen(
                              zona: zonaName,
                              namaTanaman: plantName,
                              gambarTanaman: plantImage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              // Tambahan full screen: schedule block
              Text(
                'Penjadwalan',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
              SizedBox(height: 12.h),
              _scheduleInfoBlock(),
              SizedBox(height: 28.h),
              // Peralatan section with shortcuts
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Peralatan',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MonitoringScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF35591A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _deviceShortcutGrid(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods and widgets

  Widget _buildGardenImageSmall(String imagePath) {
    Widget child;
    if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('data:image')) {
        try {
          final base64Data = imagePath.split(',').last;
          final bytes = base64Decode(base64Data);
          child = Image.memory(bytes, fit: BoxFit.cover);
        } catch (_) {
          child = _imgPlaceholder();
        }
      } else if (!kIsWeb && File(imagePath).existsSync()) {
        child = Image.file(File(imagePath), fit: BoxFit.cover);
      } else {
        child = _imgPlaceholder();
      }
    } else {
      child = _imgPlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 110.w,
        height: 90.w,
        color: Colors.white,
        child: child,
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: const Color(0xFFE0E0E0),
    child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
  );

  Widget _scheduleInfoBlock() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF234102),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icon/penjadwalan.svg',
                  width: 28.w,
                  height: 28.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Dalam\nPenjadwalan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF3A3A3A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Container(
            width: 1,
            height: 70.h,
            color: Colors.black.withOpacity(.3),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _schedulePair('Proses', 'Penyiraman')),
                    Expanded(child: _schedulePair('Metode', 'Otomatis')),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _schedulePair('Jadwal', _dummyUpdate)),
                    Expanded(child: _schedulePair('Durasi', '45 Menit')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _schedulePair(String label, String value) => RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 11.sp,
        color: const Color(0xFF3A3A3A),
        height: 1.4,
      ),
      children: [
        TextSpan(text: '$label :\n'),
        TextSpan(
          text: value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
  Widget _deviceShortcutGrid() {
    final items = [
      _DeviceShortcut(icon: 'assets/icon/penyiraman.svg', label: 'Penyiraman'),
      _DeviceShortcut(icon: 'assets/icon/cahaya.svg', label: 'Cahaya'),
      _DeviceShortcut(
        icon: 'assets/icon/pendinginan.svg',
        label: 'Pendinginan',
      ),
    ];
    return Wrap(spacing: 14.w, runSpacing: 12.h, children: items);
  }
} // end of _GardenDetailFullScreenState

// --- Compact layout helper widgets (duplicated from base screen with additions) placed at top-level ---

class _StatusBadgeFull extends StatelessWidget {
  final String status;
  final double? width;
  const _StatusBadgeFull({required this.status, this.width});
  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3A7C16),
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Text(
          status,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3A7C16),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LiveButtonFull extends StatelessWidget {
  final VoidCallback onTap;
  final double? width;
  const _LiveButtonFull({required this.onTap, this.width});
  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2F8DFF),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, size: 16, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              'Lihat Langsung',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    if (width == null) return btn;
    return SizedBox(width: width, child: btn);
  }
}

class _ZoneCarouselFull extends StatelessWidget {
  final Map<String, dynamic>? zone;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final String updateText;
  final bool harvestNow;
  final int zoneIndex;
  const _ZoneCarouselFull({
    required this.zone,
    required this.hasPrev,
    required this.hasNext,
    this.onPrev,
    this.onNext,
    required this.updateText,
    required this.harvestNow,
    required this.zoneIndex,
  });
  @override
  Widget build(BuildContext context) {
    final arrowOverlap = 16.w;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF234102),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (zone != null &&
                  (zone!['plantImage'] ?? '').toString().isNotEmpty)
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage((zone!['plantImage']).toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: const Icon(Icons.image, color: Colors.white54),
                ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone != null
                          ? (zone!['zoneName'] ?? 'Zona ${zoneIndex + 1}')
                          : 'Zona ${zoneIndex + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      zone != null ? (zone!['plantName'] ?? '-') : '-',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Update: $updateText',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        if (harvestNow)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC400),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Waktunya Panen',
                              style: TextStyle(
                                color: const Color(0xFF3A3A3A),
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: -arrowOverlap,
          top: 0,
          bottom: 0,
          child: Center(
            child: _HalfOutsideArrowFull(
              enabled: hasPrev,
              onTap: onPrev,
              left: true,
            ),
          ),
        ),
        Positioned(
          right: -arrowOverlap,
          top: 0,
          bottom: 0,
          child: Center(
            child: _HalfOutsideArrowFull(
              enabled: hasNext,
              onTap: onNext,
              left: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _HalfOutsideArrowFull extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final bool left;
  const _HalfOutsideArrowFull({
    required this.enabled,
    required this.onTap,
    required this.left,
  });
  @override
  Widget build(BuildContext context) {
    final size = 32.w;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF315700)
              : const Color(0xFF315700).withOpacity(.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          left ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionRectBtnFull extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionRectBtnFull({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF234102),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp, color: Colors.white),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceShortcut extends StatelessWidget {
  final String icon;
  final String label;
  const _DeviceShortcut({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF234102),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 20.w, height: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
