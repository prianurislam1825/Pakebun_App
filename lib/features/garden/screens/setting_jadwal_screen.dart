import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model jadwal terstruktur
class ScheduleItem {
  final String id;
  final String jam; // HH:MM
  final String tipe; // Penyiraman | Pendinginan | Cahaya
  final String media; // Air | Matahari | '-'
  final List<bool> hari; // length 7 (Senin..Minggu / label disederhanakan)
  bool aktif;

  ScheduleItem({
    required this.id,
    required this.jam,
    required this.tipe,
    required this.media,
    required List<bool> hari,
    required this.aktif,
  }) : hari = List<bool>.from(hari);

  int get _minutes =>
      int.parse(jam.substring(0, 2)) * 60 + int.parse(jam.substring(3));

  Map<String, dynamic> toJson() => {
    'id': id,
    'jam': jam,
    'tipe': tipe,
    'media': media,
    'hari': hari,
    'aktif': aktif,
  };
  factory ScheduleItem.fromJson(Map<String, dynamic> j) => ScheduleItem(
    id: j['id'] as String,
    jam: j['jam'] as String,
    tipe: j['tipe'] as String,
    media: j['media'] as String? ?? '-',
    hari: (j['hari'] as List<dynamic>).map((e) => e as bool).toList(),
    aktif: j['aktif'] as bool? ?? true,
  );
  ScheduleItem copyWith({
    String? jam,
    String? tipe,
    String? media,
    List<bool>? hari,
    bool? aktif,
  }) => ScheduleItem(
    id: id,
    jam: jam ?? this.jam,
    tipe: tipe ?? this.tipe,
    media: media ?? this.media,
    hari: hari ?? this.hari,
    aktif: aktif ?? this.aktif,
  );
}

class SettingJadwalScreen extends StatefulWidget {
  final String zona;
  final String namaTanaman;
  final String gambarTanaman;
  final bool aktif;
  final int lamaSiramAir;
  final int lamaPendinginan;
  final int lamaSiramPupuk;

  const SettingJadwalScreen({
    super.key,
    required this.zona,
    required this.namaTanaman,
    required this.gambarTanaman,
    this.aktif = true,
    this.lamaSiramAir = 0,
    this.lamaPendinginan = 0,
    this.lamaSiramPupuk = 0,
  });

  @override
  State<SettingJadwalScreen> createState() => _SettingJadwalScreenState();
}

class _SettingJadwalScreenState extends State<SettingJadwalScreen> {
  static const List<String> _dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  final List<ScheduleItem> _jadwal = [];
  String get _prefsKey =>
      'jadwal_${widget.zona.toLowerCase().replaceAll(' ', '_')}';

  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((m) => ScheduleItem.fromJson(m))
          .toList();
      setState(() {
        _jadwal
          ..clear()
          ..addAll(list);
        _sort();
      });
    } catch (_) {
      // silent
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_jadwal.map((e) => e.toJson()).toList()),
    );
  }

  void _sort() => _jadwal.sort((a, b) => a._minutes.compareTo(b._minutes));

  bool _isDuplicate(
    String jam,
    String tipe,
    String media, {
    String? excludeId,
  }) {
    return _jadwal.any(
      (s) =>
          s.jam == jam &&
          s.tipe == tipe &&
          s.media == media &&
          s.id != excludeId,
    );
  }

  void _addSchedule(ScheduleItem item) {
    setState(() {
      _jadwal.add(item);
      _sort();
    });
    _persist();
  }

  void _updateSchedule(int index, ScheduleItem item) {
    setState(() {
      _jadwal[index] = item;
      _sort();
    });
    _persist();
  }

  void _removeSchedule(ScheduleItem item) {
    setState(() => _jadwal.removeWhere((e) => e.id == item.id));
    _persist();
  }

  Widget _jadwalCard(ScheduleItem item, int index) {
    final status = item.aktif;
    final hariAktif = item.hari;
    final jam = item.jam;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  jam,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _updateSchedule(index, item.copyWith(aktif: !item.aktif)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: status
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    status ? 'Aktif' : 'Mati',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              InkWell(
                onTap: () {
                  _removeSchedule(item);
                },
                child: Icon(
                  Icons.close,
                  size: 20.sp,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _kvRow('Media', item.media.isEmpty ? '-' : item.media),
          _kvRow('Tipe', item.tipe),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            children: List.generate(_dayLabels.length, (i) {
              final active = hariAktif[i];
              return _hariCircle(
                _dayLabels[i],
                active ? const Color(0xFF35591A) : const Color(0xFFD32F2F),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openModal({ScheduleItem? existing, int? index}) {
    final editing = existing != null && index != null;
    final TextEditingController jamController = TextEditingController(
      text: existing?.jam ?? '',
    );
    String? tipe = existing?.tipe;
    String? media = existing?.media;
    final List<bool> hariAktif = List<bool>.from(
      existing?.hari ?? List<bool>.filled(7, true),
    );
    bool status = existing?.aktif ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 12.w,
              right: 12.w,
              top: 24.h,
            ),
            child: Center(
              child: Container(
                width: 380.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF35591A),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editing ? 'Ubah Jadwal' : 'Tambah Jadwal',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF35591A),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD32F2F),
                            ),
                            padding: EdgeInsets.all(4.w),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    _modalDropdown<String>(
                      label: 'Pilih Tipe',
                      value: tipe,
                      items: const ['Penyiraman', 'Pendinginan', 'Cahaya'],
                      onChanged: (v) => setModalState(() {
                        tipe = v;
                        if (tipe == 'Penyiraman' && media == 'Matahari')
                          media = null;
                        if (tipe == 'Cahaya' && media == 'Air') media = null;
                      }),
                    ),
                    SizedBox(height: 12.h),
                    _modalDropdown<String>(
                      label: 'Media',
                      value: media,
                      items: _mediaFor(tipe),
                      onChanged: (v) => setModalState(() => media = v),
                    ),
                    SizedBox(height: 14.h),
                    Text('Waktu', style: _modalLabelStyle()),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: 110.w,
                      child: TextField(
                        controller: jamController,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                          LengthLimitingTextInputFormatter(5),
                          _TimeTextInputFormatter(),
                        ],
                        decoration: _timeInputDecoration(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('Hari', style: _modalLabelStyle()),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: List.generate(7, (i) {
                        final active = hariAktif[i];
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => hariAktif[i] = !hariAktif[i]),
                          child: _hariCircle(
                            _dayLabels[i],
                            active
                                ? const Color(0xFF35591A)
                                : const Color(0xFFD32F2F),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Text('Status Penjadwalan', style: _modalLabelStyle()),
                        const Spacer(),
                        Switch(
                          value: status,
                          activeColor: const Color(0xFF35591A),
                          onChanged: (v) => setModalState(() => status = v),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF35591A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () {
                          final raw = jamController.text.trim();
                          if (raw.isEmpty || !_validTime(raw)) {
                            _showSnack('Format waktu HH:MM');
                            return;
                          }
                          final jam = _normalizeTime(raw);
                          if (tipe == null) {
                            _showSnack('Pilih tipe');
                            return;
                          }
                          if (media == null) {
                            _showSnack('Pilih media');
                            return;
                          }
                          if (!hariAktif.contains(true)) {
                            _showSnack('Minimal satu hari aktif');
                            return;
                          }
                          if (_isDuplicate(
                            jam,
                            tipe!,
                            media!,
                            excludeId: existing?.id,
                          )) {
                            _showSnack('Jadwal duplikat');
                            return;
                          }
                          final item = ScheduleItem(
                            id:
                                existing?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            jam: jam,
                            tipe: tipe!,
                            media: media!,
                            hari: hariAktif,
                            aktif: status,
                          );
                          if (editing) {
                            _updateSchedule(index, item);
                          } else {
                            _addSchedule(item);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(
                          editing ? 'Perbarui' : 'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle _modalLabelStyle() => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF35591A),
  );

  InputDecoration _timeInputDecoration() => InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF2F2F2),
    hintText: '08:00',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(color: Color(0xFF35591A), width: 1.4),
    ),
  );

  Widget _modalDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _modalLabelStyle()),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF35591A),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              dropdownColor: const Color(0xFF35591A),
              isExpanded: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(
                        e.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              hint: Text(label, style: const TextStyle(color: Colors.white70)),
            ),
          ),
        ),
      ],
    );
  }

  bool _validTime(String value) {
    final reg = RegExp(
      r'^([0-1]?\d|2[0-3]):?[0-5]\d$',
    ); // allow H:MM / HH:MM / HHMM
    return reg.hasMatch(value.trim());
  }

  String _normalizeTime(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 3) {
      final h = digits.padLeft(2, '0');
      return '$h:00';
    }
    final hh = digits.substring(0, 2);
    final mm = digits.substring(2).padRight(2, '0').substring(0, 2);
    final hNum = int.parse(hh);
    final mNum = int.parse(mm);
    final safeH = hNum.clamp(0, 23).toString().padLeft(2, '0');
    final safeM = mNum.clamp(0, 59).toString().padLeft(2, '0');
    return '$safeH:$safeM';
  }

  List<String> _mediaFor(String? tipe) {
    if (tipe == null) return const ['Air', 'Matahari'];
    switch (tipe) {
      case 'Penyiraman':
        return const ['Air'];
      case 'Cahaya':
        return const ['Matahari'];
      case 'Pendinginan':
        return const ['Matahari']; // asumsi sementara
      default:
        return const ['Air', 'Matahari'];
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _kvRow(String k, String v) => Padding(
    padding: EdgeInsets.only(bottom: 2.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$k : ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
        ),
      ],
    ),
  );

  // ...existing code...

  Widget _hariCircle(String label, Color color) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  late bool _aktif;
  late TextEditingController _airController;
  late TextEditingController _pendinginanController;
  late TextEditingController _pupukController;

  @override
  void initState() {
    super.initState();
    _aktif = widget.aktif;
    _loadPersisted();
    _airController = TextEditingController(
      text: widget.lamaSiramAir > 0 ? widget.lamaSiramAir.toString() : '',
    );
    _pendinginanController = TextEditingController(
      text: widget.lamaPendinginan > 0 ? widget.lamaPendinginan.toString() : '',
    );
    _pupukController = TextEditingController(
      text: widget.lamaSiramPupuk > 0 ? widget.lamaSiramPupuk.toString() : '',
    );
  }

  @override
  void dispose() {
    _airController.dispose();
    _pendinginanController.dispose();
    _pupukController.dispose();
    super.dispose();
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
            'Setting Jadwal',
            style: TextStyle(
              color: Color(0xFF35591A),
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF35591A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Text(
              widget.zona,
              style: TextStyle(
                color: Color(0xFF222222),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF35591A),
                borderRadius: BorderRadius.circular(8.r),
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
                          'Status Penjadwalan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
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
                            activeThumbColor: Color(0xFF7ED957),
                            inactiveThumbColor: Color(0xFFD9D9D9),
                            inactiveTrackColor: Color(0xFFBDBDBD),
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
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Konfigurasi Dasar',
              style: TextStyle(
                color: Color(0xFF222222),
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            _inputRow('Lama Siram Air', _airController),
            SizedBox(height: 8.h),
            _inputRow('Lama Pendinginan', _pendinginanController),
            SizedBox(height: 8.h),
            _inputRow('Lama Siram Pupuk', _pupukController),
            SizedBox(height: 18.h),
            Text(
              'Jadwal Otomatis',
              style: TextStyle(
                color: Color(0xFF35591A),
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            if (_jadwal.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  'Belum ada jadwal',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
                  ),
                ),
              )
            else
              ..._jadwal.asMap().entries.map(
                (e) => GestureDetector(
                  onTap: () => _openModal(existing: e.value, index: e.key),
                  child: _jadwalCard(e.value, e.key),
                ),
              ),
            SizedBox(height: 10.h),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7ED957),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  minimumSize: Size(220.w, 40.h),
                  elevation: 0,
                ),
                onPressed: () {
                  _openModal();
                },
                icon: Icon(Icons.add_circle, color: Colors.white, size: 22.sp),
                label: Text(
                  'Tambah Jadwal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: Color(0xFF222222), fontSize: 14.sp),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 1,
          child: Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 0,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Menit',
          style: TextStyle(color: Color(0xFF888888), fontSize: 14.sp),
        ),
      ],
    );
  }
}

// Formatter otomatis menambahkan ':' setelah dua digit pertama jika belum ada
// dan membatasi input ke format HH:MM valid.
class _TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (text.length == 2 && !text.contains(':')) {
      text = '$text:';
    }
    if (text.length > 5) {
      text = text.substring(0, 5);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
