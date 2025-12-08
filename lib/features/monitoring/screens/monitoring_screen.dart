import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../services/mqtt_service.dart';
import '../services/soil_mqtt_service.dart';

// Color levels used for numeric badge coloring
enum _Level { green, yellow, red }

/// Monitoring screen — wired to a simple MQTT service for live values.
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final MqttService _mqtt = MqttService(broker: 'pentarium.id', port: 1883);
  final SoilMqttService _soilMqtt = SoilMqttService(
    broker: 'pentarium.id',
    port: 1883,
    // username/password can be added here if required later
    deviceId: '08D1F9E050B8',
  );

  @override
  void initState() {
    super.initState();
    // try to connect immediately (defaults can be overridden later)
    _mqtt.connect().catchError((_) {});
    _soilMqtt.connect().catchError((_) {});
    _mqtt.env.addListener(_onEnv);
    _mqtt.aws.addListener(_onAws);
    _soilMqtt.soil.addListener(_onSoil);
  }

  void _onEnv() => setState(() {});
  void _onAws() => setState(() {});
  void _onSoil() => setState(() {});

  @override
  void dispose() {
    _mqtt.env.removeListener(_onEnv);
    _mqtt.aws.removeListener(_onAws);
    _mqtt.disconnect();
    _soilMqtt.soil.removeListener(_onSoil);
    _soilMqtt.disconnect();
    super.dispose();
  }

  String _formatDateTime(DateTime? d) {
    if (d == null) return '--';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(d);
  }

  String _displayNum(num? v, {String suffix = ''}) {
    if (v == null) return '--';
    return '${v.toString()}$suffix';
  }

  // Approximate dew point using Magnus formula (sufficient for UI display)
  double? _calcDewPoint(double? tempC, double? rh) {
    if (tempC == null || rh == null) return null;
    // constants for water over liquid range
    const a = 17.62;
    const b = 243.12; // °C
    final gamma = (a * tempC) / (b + tempC) + math.log(rh / 100.0);
    return (b * gamma) / (a - gamma);
  }

  @override
  Widget build(BuildContext context) {
    final env = _mqtt.env.value;
    final aws = _mqtt.aws.value;
    final soil = _soilMqtt.soil.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B4C00),
        title: const Text('Monitoring'),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.h),
                _sectionTitle('Peralatan'),
                SizedBox(height: 8.h),
                _peralatanRow(context),
                SizedBox(height: 12.h),
                _tambahPerangkatButton(),
                SizedBox(height: 18.h),

                _sectionTitleWithSubtitle(
                  'Monitoring Tanah',
                  'Last update: ${_formatDateTime(soil?.receivedAt)}',
                ),
                SizedBox(height: 8.h),
                _gridWidgets(context, [
                  _cardDataValueColored(
                    'Kelembapan Tanah',
                    'assets/monitoring/kelembapan_tanah.svg',
                    soil?.hum,
                    suffix: ' %',
                  ),
                  _cardDataValueColored(
                    'Suhu Tanah',
                    'assets/monitoring/suhu_tanah.svg',
                    soil?.temp,
                    suffix: ' °C',
                  ),
                  _cardDataValueColored(
                    'pH Tanah',
                    'assets/monitoring/ph.svg',
                    soil?.ph,
                  ),
                  _cardDataValueColored(
                    'Nitrogen',
                    'assets/monitoring/npk.svg',
                    soil?.n,
                  ),
                  _cardDataValueColored(
                    'Electrical Conductivity',
                    'assets/monitoring/status_tanah.svg',
                    soil?.cond,
                    suffix: ' µS/cm',
                  ),
                  _cardDataValueColored(
                    'Fosfor',
                    'assets/monitoring/npk.svg',
                    soil?.p,
                  ),
                  _cardDataValueColored(
                    'Kalium',
                    'assets/monitoring/npk.svg',
                    soil?.k,
                    full: true,
                  ),
                ]),

                SizedBox(height: 18.h),
                _sectionTitleWithSubtitle(
                  'Monitoring Lingkungan',
                  'Last update: ${_formatDateTime(env?.receivedAt)}',
                ),
                SizedBox(height: 8.h),
                _gridWidgets(context, [
                  _cardDataValueColored(
                    'Suhu Udara',
                    'assets/monitoring/suhu_udara.svg',
                    env?.temp,
                    suffix: ' °C',
                  ),
                  _cardDataValueColored(
                    'Kelembapan Udara',
                    'assets/monitoring/kelembapan_udara.svg',
                    env?.hum,
                    suffix: ' % RH',
                  ),
                  _cardDataValueColored(
                    'Tekanan Udara',
                    'assets/monitoring/tekanan_udara.svg',
                    env?.pressure,
                    suffix: ' hPa',
                  ),
                ]),

                SizedBox(height: 18.h),
                _sectionTitleWithSubtitle(
                  'Monitoring Cuaca',
                  'Last update: ${_formatDateTime(aws?.receivedAt)}',
                ),
                SizedBox(height: 8.h),
                _gridWidgets(context, [
                  _cardDataValueColored(
                    'Curah 1 Minggu Terakhir',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainLastWeek ?? aws?.rainToday, // fallback ke lama
                    suffix: ' mm',
                  ),
                  _cardDataValueColored(
                    'Curah 1 Hari Terakhir',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainLastDay ?? aws?.rainLastHour,
                    suffix: ' mm',
                  ),
                  _cardDataValueColored(
                    'Intensitas 1 Jam',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainRate1h ?? aws?.rainRate10m,
                    suffix: ' mm/h',
                  ),
                  _cardDataValueColored(
                    'Suhu Udara',
                    'assets/monitoring/suhu_udara.svg',
                    aws?.temp,
                    suffix: ' °C',
                  ),
                  _cardDataValueColored(
                    'Kelembapan Udara',
                    'assets/monitoring/kelembapan_udara.svg',
                    aws?.hum,
                    suffix: ' %',
                  ),
                  _cardDataValueColored(
                    'Radiasi UV',
                    'assets/monitoring/uv.svg',
                    aws?.uv,
                  ),
                  _cardDataValueColored(
                    'Kecepatan Angin',
                    'assets/monitoring/kecepatan_angin.svg',
                    aws?.windSpeed,
                    suffix: ' m/s',
                  ),
                  _cardDataValue(
                    'Arah Angin',
                    'assets/monitoring/arah_angin.svg',
                    aws?.windDir ?? '--',
                  ),
                  _cardDataValueColored(
                    'Tekanan Udara',
                    'assets/monitoring/tekanan_udara.svg',
                    aws?.pressure,
                    suffix: ' hPa',
                  ),
                  _cardDataValueColored(
                    'Curah Hujan (Kumulatif 1 Tahun)',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rain,
                    suffix: ' mm',
                  ),
                  _cardDataValueColored(
                    'Curah 1 Bulan Terakhir',
                    'assets/monitoring/curah_hujan.svg',
                    aws?.rainLastMonth,
                    suffix: ' mm',
                    full: true,
                  ),
                  _cardDataValueColored(
                    'Intensitas Cahaya',
                    'assets/monitoring/intesitas_cahaya.svg',
                    aws?.light,
                    suffix: ' Lux',
                  ),
                  _cardDataValueColored(
                    'Titik Embun',
                    'assets/monitoring/ttitik_embun.svg',
                    aws?.dewPoint ?? _calcDewPoint(aws?.temp, aws?.hum),
                    suffix: ' °C',
                    full: true,
                  ),
                ]),

                SizedBox(height: 18.h),
                _sectionTitle('Monitoring Daya'),
                SizedBox(height: 8.h),
                _grid(context, [
                  _cardData('Baterai', 'assets/monitoring/baterai.svg'),
                  _cardData(
                    'Panel Surya',
                    'assets/monitoring/panel_surya.svg',
                    full: true,
                  ),
                ]),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2B4C00),
      ),
    );
  }

  Widget _sectionTitleWithSubtitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2B4C00),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _cardDataValue(
    String title,
    String icon,
    String value, {
    bool full = false,
  }) {
    return _CardInfoWidget(title: title, icon: icon, value: value, full: full);
  }

  // Build a value card with automatic badge color based on metric/title and raw value
  Widget _cardDataValueColored(
    String title,
    String icon,
    num? raw, {
    String suffix = '',
    bool full = false,
  }) {
    final valueText = _displayNum(raw, suffix: suffix);
    final level = _levelFor(title, raw);
    final colors = _colorsFor(level);
    return _CardInfoWidget(
      title: title,
      icon: icon,
      value: valueText,
      full: full,
      badgeBg: colors.$1,
      badgeFg: colors.$2,
    );
  }

  _Level _levelFor(String title, num? v) {
    if (v == null) return _Level.yellow;
    final val = v.toDouble();
    switch (title) {
      // Tanah
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
      case 'EC Tanah': // µS/cm
        if (val < 100 || val > 2000) return _Level.red;
        if (val < 200 || val > 1200) return _Level.yellow;
        return _Level.green;
      case 'Nitrogen':
      case 'Fosfor':
      case 'Kalium':
        return _Level.yellow; // tanpa ambang yang jelas, netral

      // Lingkungan & Cuaca
      case 'Suhu Udara':
        if (val < 15 || val > 35) return _Level.red;
        if (val < 20 || val > 30) return _Level.yellow;
        return _Level.green;
      case 'Kelembapan Udara':
        if (val < 30 || val > 80) return _Level.red;
        if (val < 40 || val > 70) return _Level.yellow;
        return _Level.green;
      case 'Tekanan Udara': // hPa
        if (val < 960 || val > 1045) return _Level.red;
        if (val < 980 || val > 1030) return _Level.yellow;
        return _Level.green;
      case 'Radiasi UV': // UV index kira-kira
        if (val > 6) return _Level.red;
        if (val > 3) return _Level.yellow;
        return _Level.green;
      case 'Kecepatan Angin': // m/s
        if (val > 10) return _Level.red;
        if (val > 5) return _Level.yellow;
        return _Level.green;
      case 'Curah Hujan': // mm/h
        if (val > 5) return _Level.red;
        if (val > 0) return _Level.yellow;
        return _Level.green; // 0 mm/h
      case 'Hujan Hari Ini': // mm
        if (val > 50) return _Level.red;
        if (val > 10) return _Level.yellow;
        return _Level.green;
      case 'Curah 1 Jam Terakhir': // mm
        if (val > 10) return _Level.red;
        if (val > 2) return _Level.yellow;
        return _Level.green;
      case 'Curah 1 Hari Terakhir': // mm
        if (val > 50) return _Level.red;
        if (val > 10) return _Level.yellow;
        return _Level.green;
      case 'Curah 1 Minggu Terakhir': // mm
        if (val > 150) return _Level.red;
        if (val > 50) return _Level.yellow;
        return _Level.green;
      case 'Curah 1 Bulan Terakhir': // mm
        if (val > 300) return _Level.red;
        if (val > 100) return _Level.yellow;
        return _Level.green;
      case 'Intensitas 1 Jam': // mm/h
        if (val > 20) return _Level.red;
        if (val > 5) return _Level.yellow;
        return _Level.green;
      case 'Intensitas Cahaya':
        return _Level.yellow; // tergantung konteks, set netral
      case 'Titik Embun':
        if (val < 5 || val > 24) return _Level.red;
        if (val < 10 || val > 20) return _Level.yellow;
        return _Level.green;
      default:
        return _Level.yellow;
    }
  }

  (Color, Color) _colorsFor(_Level level) {
    switch (level) {
      case _Level.green:
        return (const Color(0xFF64C27B), Colors.white);
      case _Level.yellow:
        return (const Color(0xFFF6C744), Colors.black);
      case _Level.red:
        return (const Color(0xFFE53935), Colors.white);
    }
  }

  Widget _peralatanRow(BuildContext context) {
    final items = [
      _peralatanItem('Penyiraman', 'assets/monitoring/penyiraman.svg'),
      _peralatanItem('Cahaya', 'assets/monitoring/cahaya.svg'),
      _peralatanItem('Pendinginan', 'assets/monitoring/pendinginan.svg'),
    ];
    return Wrap(spacing: 12.w, runSpacing: 12.h, children: items);
  }

  Widget _peralatanItem(String label, String icon) {
    return InkWell(
      onTap: () async {
        if (label == 'Penyiraman') {
          final ok = await _soilMqtt.publishPumpCommand(
            type: 'water',
            action: 'on',
            duration: 60,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? 'Perintah penyiraman terkirim'
                    : 'Gagal mengirim perintah penyiraman',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2B4C00),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SmartIcon(
                assetPath: icon,
                size: 18.w,
                tintForVector: const Color(0xFF2B4C00),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tambahPerangkatButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B4C00),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: Text('Tambah Perangkat', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _grid(BuildContext context, List<_CardInfo> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxWidth;
        final double spacing = 12.w;
        const int columns = 2;
        final double itemWidth =
            (available - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((c) {
            final w = c.full ? available : itemWidth;
            return SizedBox(
              width: w,
              child: _monitorCard(context, c.title, c.icon, c.full),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _gridWidgets(BuildContext context, List<Widget> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxWidth;
        final double spacing = 12.w;
        const int columns = 2;
        final double itemWidth =
            (available - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((w) {
            bool full = false;
            if (w is _CardInfoWidget) full = w.full;
            final double wdt = full ? available : itemWidth;
            return SizedBox(width: wdt, child: w);
          }).toList(),
        );
      },
    );
  }

  Widget _monitorCard(
    BuildContext context,
    String title,
    String iconPath,
    bool full,
  ) {
    final badges = <Widget>[];

    Color greenChip = const Color(0xFF64C27B);
    Color yellowChip = const Color(0xFFF6C744);

    void addBadge(String text, Color bg, {Color fg = Colors.black}) {
      badges.add(_valueBadge(text, bg: bg, fg: fg));
    }

    switch (title) {
      case 'Status Tanah':
        addBadge('Baik', greenChip, fg: Colors.white);
        break;
      case 'Baterai':
        addBadge('12.4 V', yellowChip);
        addBadge('70 %', yellowChip);
        break;
      case 'Panel Surya':
        addBadge('18 W', yellowChip);
        addBadge('Mengisi!', yellowChip);
        break;
      default:
        addBadge('--', yellowChip);
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2B4C00),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SmartIcon(
              assetPath: iconPath,
              size: 26.w,
              tintForVector: const Color(0xFF2B4C00),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Wrap(spacing: 8.w, runSpacing: 6.h, children: badges),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfo {
  final String title;
  final String icon;
  final bool full;
  _CardInfo(this.title, this.icon, {this.full = false});
}

_CardInfo _cardData(String title, String icon, {bool full = false}) =>
    _CardInfo(title, icon, full: full);

// Widget for cards that show a value (used by MQTT-driven cards)
class _CardInfoWidget extends StatelessWidget {
  final String title;
  final String icon;
  final String value;
  final bool full;
  final Color? badgeBg;
  final Color? badgeFg;

  const _CardInfoWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.value,
    this.full = false,
    this.badgeBg,
    this.badgeFg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2B4C00),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SmartIcon(
              assetPath: icon,
              size: 26.w,
              tintForVector: const Color(0xFF2B4C00),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _valueBadge(
                      value,
                      bg: badgeBg ?? const Color(0xFFF6C744),
                      fg: badgeFg ?? Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Renders either an SVG (with optional tint) or, if the SVG embeds a PNG image (unsupported by flutter_svg),
// extracts the base64 image and renders it as a raster Image.
class SmartIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? tintForVector;

  const SmartIcon({
    Key? key,
    required this.assetPath,
    required this.size,
    this.tintForVector,
  }) : super(key: key);

  Future<_IconPayload> _load() async {
    try {
      final svg = await rootBundle.loadString(assetPath);
      final match = RegExp(r'data:image/png;base64,([^"\)]+)').firstMatch(svg);
      if (match != null) {
        final b64 = match.group(1)!;
        return _IconPayload.png(b64);
      }
      return _IconPayload.svg(svg);
    } catch (_) {
      // Fallback: try to render as plain SVG from asset path
      return _IconPayload.path(assetPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_IconPayload>(
      future: _load(),
      builder: (context, snapshot) {
        final payload = snapshot.data;
        if (payload == null) {
          return SizedBox(width: size, height: size);
        }
        switch (payload.type) {
          case _IconType.png:
            try {
              return Image.memory(
                payload.pngBytes!,
                width: size,
                height: size,
                filterQuality: FilterQuality.high,
              );
            } catch (_) {
              return SizedBox(width: size, height: size);
            }
          case _IconType.svgString:
            return SvgPicture.string(
              payload.svgString!,
              width: size,
              height: size,
              colorFilter: tintForVector != null
                  ? ColorFilter.mode(tintForVector!, BlendMode.srcIn)
                  : null,
            );
          case _IconType.assetPath:
            return SvgPicture.asset(
              payload.assetPath!,
              width: size,
              height: size,
              colorFilter: tintForVector != null
                  ? ColorFilter.mode(tintForVector!, BlendMode.srcIn)
                  : null,
            );
        }
      },
    );
  }
}

enum _IconType { png, svgString, assetPath }

class _IconPayload {
  final _IconType type;
  final Uint8List? pngBytes;
  final String? svgString;
  final String? assetPath;

  _IconPayload._(this.type, {this.pngBytes, this.svgString, this.assetPath});
  factory _IconPayload.png(String b64) =>
      _IconPayload._(_IconType.png, pngBytes: base64Decode(b64));
  factory _IconPayload.svg(String svg) =>
      _IconPayload._(_IconType.svgString, svgString: svg);
  factory _IconPayload.path(String path) =>
      _IconPayload._(_IconType.assetPath, assetPath: path);
}

// Small rounded badge used for values/status
Widget _valueBadge(
  String text, {
  Color bg = Colors.white,
  Color fg = Colors.black,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 12.sp, fontWeight: FontWeight.w600),
    ),
  );
}
