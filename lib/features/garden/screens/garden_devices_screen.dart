import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/garden/screens/_device_card.dart';
import 'package:pakebun_app/features/garden/screens/setting_threshold_screen.dart';
import 'package:pakebun_app/features/garden/screens/setting_jadwal_screen.dart';

class GardenDevicesScreen extends StatefulWidget {
  final String gardenName;
  final String gardenImagePath;
  final List<Map<String, dynamic>> devices;
  // Tambahan: daftar zona dan tanaman
  final List<Map<String, String>>
  zones; // [{"zoneName":..., "plantName":..., "plantImage":...}]
  final int initialZoneIndex;

  const GardenDevicesScreen({
    super.key,
    required this.gardenName,
    required this.gardenImagePath,
    required this.devices,
    required this.zones,
    this.initialZoneIndex = 0,
  });

  @override
  State<GardenDevicesScreen> createState() => _GardenDevicesScreenState();
}

class _GardenDevicesScreenState extends State<GardenDevicesScreen> {
  late int _currentZoneIndex;

  @override
  void initState() {
    super.initState();
    _currentZoneIndex = widget.initialZoneIndex;
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zones[_currentZoneIndex];
    final String zoneName = zone['zoneName'] ?? 'Zona';
    final String plantName = zone['plantName'] ?? '-';
    final String plantImage = zone['plantImage'] ?? 'assets/image/cabai.png';
    final String panenStatus = zone['panenStatus'] ?? 'Belum Panen';
    final String updateWaktu = zone['updateWaktu'] ?? 'Baru saja';
    final String prosesPenyiraman = zone['prosesPenyiraman'] ?? 'Otomatis';
    final String metode = zone['metode'] ?? 'Drip';
    final String jadwal = zone['jadwal'] ?? 'Setiap pagi';
    final String durasi = zone['durasi'] ?? '10 menit';
    final String headerUpdateWaktu =
        widget.zones[_currentZoneIndex]['headerUpdateWaktu'] ?? updateWaktu;

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Column(
          children: [
            Text(
              'Detail kebun',
              style: TextStyle(
                color: const Color(0xFF35591A),
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Update terakhir: $headerUpdateWaktu',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 60.h,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu kebun
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    widget.gardenImagePath,
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.gardenName,
                        style: TextStyle(
                          color: const Color(0xFF35591A),
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Aktif',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/icon/live.svg',
                              width: 18.w,
                              height: 18.w,
                            ),
                            label: Text(
                              'Lihat Langsung',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
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
            SizedBox(height: 24.h),
            Text(
              'Informasi Zona',
              style: TextStyle(
                color: const Color(0xFF35591A),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
            // Card zona dengan badge panen, update waktu, dan detail proses
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF35591A),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geser kiri
                  GestureDetector(
                    onTap: _currentZoneIndex > 0
                        ? () {
                            setState(() {
                              _currentZoneIndex--;
                            });
                          }
                        : null,
                    child: SvgPicture.asset(
                      'assets/icon/geser_kiri.svg',
                      width: 28.w,
                      height: 28.w,
                      colorFilter: ColorFilter.mode(
                        _currentZoneIndex > 0
                            ? Colors.white
                            : const Color(0x4DFFFFFF),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Gambar tanaman
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: Image.asset(
                      plantImage,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // Info zona dan proses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              zoneName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: panenStatus == 'Panen'
                                    ? Colors.orange
                                    : const Color(0x33FFFFFF),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                panenStatus,
                                style: TextStyle(
                                  color: panenStatus == 'Panen'
                                      ? Colors.white
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          plantName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              updateWaktu,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        // Detail proses
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Penyiraman: $prosesPenyiraman',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Metode: $metode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Jadwal: $jadwal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.white, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              'Durasi: $durasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Geser kanan
                  GestureDetector(
                    onTap: _currentZoneIndex < widget.zones.length - 1
                        ? () {
                            setState(() {
                              _currentZoneIndex++;
                            });
                          }
                        : null,
                    child: SvgPicture.asset(
                      'assets/icon/geser_kanan.svg',
                      width: 28.w,
                      height: 28.w,
                      colorFilter: ColorFilter.mode(
                        _currentZoneIndex < widget.zones.length - 1
                            ? Colors.white
                            : const Color(0x4DFFFFFF),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35591A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingThresholdScreen(
                            zona: zoneName,
                            namaTanaman: plantName,
                            gambarTanaman: plantImage,
                            aktif: true,
                          ),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      'assets/icon/treshold.svg',
                      width: 20.w,
                      height: 20.w,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'Treshold',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35591A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingJadwalScreen(
                            zona: zoneName,
                            namaTanaman: plantName,
                            gambarTanaman: plantImage,
                          ),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      'assets/icon/jadwal.svg',
                      width: 20.w,
                      height: 20.w,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'Jadwal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peralatan',
                  style: TextStyle(
                    color: const Color(0xFF35591A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFF35591A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              physics: NeverScrollableScrollPhysics(),
              children: [
                DeviceCard(
                  iconPath: 'assets/icon/penyiraman.svg',
                  label: 'Penyiraman',
                  color: Color(0xFF35591A),
                ),
                DeviceCard(
                  iconPath: 'assets/icon/cahaya.svg',
                  label: 'Cahaya',
                  color: Color(0xFF35591A),
                ),
                DeviceCard(
                  iconPath: 'assets/icon/pendinginan.svg',
                  label: 'Pendinginan',
                  color: Color(0xFF35591A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
