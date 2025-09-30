import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingThresholdScreen extends StatefulWidget {
  final String zona;
  final String namaTanaman;
  final String gambarTanaman;
  final bool aktif;

  const SettingThresholdScreen({
    super.key,
    required this.zona,
    required this.namaTanaman,
    required this.gambarTanaman,
    this.aktif = true,
  });

  @override
  State<SettingThresholdScreen> createState() => _SettingThresholdScreenState();
}

class _SettingThresholdScreenState extends State<SettingThresholdScreen> {
  late bool _aktif;
  late List<RangeValues> _sliderValues;

  @override
  void initState() {
    super.initState();
    _aktif = widget.aktif;
    _sliderValues = List.generate(4, (_) => const RangeValues(0.3, 0.7));
  }

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
            'Setting Threshold',
            style: TextStyle(
              color: const Color(0xFF35591A),
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF35591A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: ListView(
          children: [
            SizedBox(height: 8.h),
            Text(
              widget.zona,
              style: TextStyle(
                color: const Color(0xFF222222),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF35591A),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: Image.asset(
                      widget.gambarTanaman,
                      width: 54.w,
                      height: 54.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.namaTanaman,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Status Threshold',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Aktif',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Switch(
                        value: _aktif,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF7ED957),
                        inactiveThumbColor: const Color(0xFFD9D9D9),
                        inactiveTrackColor: const Color(0xFFBDBDBD),
                        onChanged: (val) {
                          setState(() {
                            _aktif = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            ...List.generate(4, (index) => _thresholdCard(index)),
          ],
        ),
      ),
    );
  }

  Widget _thresholdCard(int index) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Konfigurasi Dasar',
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi', style: TextStyle(fontSize: 13.sp)),
                    Text(
                      'Rekomendasi',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF7ED957),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('900%', style: TextStyle(fontSize: 13.sp)),
                    Text(
                      '1000%',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF7ED957),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('900%', style: TextStyle(fontSize: 13.sp)),
                    Text(
                      '1000%',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF7ED957),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.h,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: const Color(0xFF35591A),
            inactiveTrackColor: const Color(0xFFBDBDBD),
            thumbColor: const Color(0xFF35591A),
          ),
          child: RangeSlider(
            values: _sliderValues[index],
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (values) {
              setState(() {
                _sliderValues[index] = values;
              });
            },
          ),
        ),
        Divider(height: 24.h, thickness: 1, color: const Color(0xFFF2F2F2)),
      ],
    );
  }
}
