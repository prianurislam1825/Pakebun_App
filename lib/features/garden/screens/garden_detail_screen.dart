import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'garden_detail_full_screen.dart';

class GardenDetailScreen extends StatefulWidget {
  final Map<String, dynamic> garden;
  const GardenDetailScreen({super.key, required this.garden});

  @override
  State<GardenDetailScreen> createState() => _GardenDetailScreenState();
}

class _GardenDetailScreenState extends State<GardenDetailScreen> {
  int _zoneIndex = 0;

  @override
  Widget build(BuildContext context) {
    final g = widget.garden;
    final name = (g['name'] ?? g['nama'] ?? 'Kebun').toString();
    final imagePath = (g['image'] ?? '').toString();
    final rawStatus = (g['status'] ?? 'Aktif').toString();
    final status = rawStatus.toLowerCase() == 'hidup' ? 'Aktif' : rawStatus;
    List<Map<String, dynamic>> zones = (g['zones'] is List)
        ? List<Map<String, dynamic>>.from(g['zones'])
        : <Map<String, dynamic>>[];
    if (zones.isEmpty) {
      zones = [
        {'zoneName': 'Zona 1', 'plantName': '-', 'plantImage': null},
      ];
    }
    if (_zoneIndex >= zones.length) _zoneIndex = 0;
    final zone = zones.isNotEmpty ? zones[_zoneIndex] : null;

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
          'Detail kebun',
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
                  _buildGardenImage(imagePath),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF35591A),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _StatusBadge(status: status, width: 140.w),
                        SizedBox(height: 6.h),
                        _LiveButton(
                          onTap: () {
                            /* TODO */
                          },
                          width: 140.w,
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
              _ZoneCarousel(
                zone: zone,
                hasPrev: zones.length > 1,
                hasNext: zones.length > 1,
                onPrev: zones.length > 1
                    ? () => setState(() {
                        _zoneIndex =
                            (_zoneIndex - 1 + zones.length) % zones.length;
                      })
                    : null,
                onNext: zones.length > 1
                    ? () => setState(() {
                        _zoneIndex = (_zoneIndex + 1) % zones.length;
                      })
                    : null,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _ActionRectButton(
                      icon: Icons.tune,
                      label: 'Treshold',
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _ActionRectButton(
                      icon: Icons.event_note_outlined,
                      label: 'Jadwal',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              Text(
                'Peralatan',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.center,
                child: _AddDeviceButton(onTap: _showAddDeviceModal),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDeviceModal() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) => const _AddDeviceModal(),
    ).then((selection) {
      if (selection == 'Pilih Semua') {
        if (!mounted) return;
        final g = widget.garden;
        final zones = (g['zones'] is List)
            ? List<Map<String, dynamic>>.from(g['zones'])
            : <Map<String, dynamic>>[];
        final zone = zones.isNotEmpty ? zones[_zoneIndex % zones.length] : null;
        final plantImagePath = (zone?['plantImage'] ?? '').toString();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GardenDetailFullScreen(
              gardenName: (g['name'] ?? g['nama'] ?? 'Kebun').toString(),
              gardenImagePath: (g['image'] ?? '').toString(),
              plantImagePath: plantImagePath,
              zones: zones,
              initialZoneIndex: _zoneIndex,
            ),
          ),
        );
      } else if (selection != null) {
        // Future: handle individual category selection
      }
    });
  }

  Widget _buildGardenImage(String imagePath) {
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
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final double? width;
  const _StatusBadge({required this.status, this.width});

  @override
  Widget build(BuildContext context) {
    // Jika width diberikan, buat full-width rectangle supaya simetris dengan tombol Live
    if (width != null) {
      return Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3A7C16),
          borderRadius: BorderRadius.circular(
            6.r,
          ), // samakan radius dengan Live button
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
    // Default (tanpa lebar khusus) tetap ukuran konten
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

class _LiveButton extends StatelessWidget {
  final VoidCallback onTap;
  final double? width;
  const _LiveButton({required this.onTap, this.width});

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

class _ZoneCarousel extends StatelessWidget {
  final Map<String, dynamic>? zone;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  const _ZoneCarousel({
    required this.zone,
    required this.hasPrev,
    required this.hasNext,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final arrowOverlap = 16.w; // half diameter
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
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
                      zone != null ? (zone!['zoneName'] ?? 'Zona') : 'Zona',
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
            child: _HalfOutsideArrow(
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
            child: _HalfOutsideArrow(
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

class _HalfOutsideArrow extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final bool left;
  const _HalfOutsideArrow({
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

class _ActionRectButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionRectButton({
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

class _AddDeviceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddDeviceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF234102),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tambah Perangkat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(Icons.add_circle, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AddDeviceModal extends StatelessWidget {
  const _AddDeviceModal();

  @override
  Widget build(BuildContext context) {
    // Using ScreenUtil if already initialized upstream
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 14.h,
        bottom: 24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Tambah Perangkat',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF35591A),
                    ),
                  ),
                ),
              ),
              // Close button aligned to right edge (overlay style)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B0E00), // dark red
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          _DeviceOptionGrid(
            options: const [
              'Peralatan',
              'Tanah',
              'Lingkungan',
              'Cuaca',
              'Daya',
              'Pilih Semua',
            ],
            onTap: (label) {
              Navigator.of(context).pop(label);
            },
          ),
        ],
      ),
    );
  }
}

class _DeviceOptionGrid extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onTap;
  const _DeviceOptionGrid({required this.options, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 2 columns x 3 rows layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.w;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: 12.h,
          children: options.map((label) {
            return SizedBox(
              width: itemWidth,
              child: _DeviceOptionItem(label: label, onTap: () => onTap(label)),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DeviceOptionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DeviceOptionItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF234102),
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
