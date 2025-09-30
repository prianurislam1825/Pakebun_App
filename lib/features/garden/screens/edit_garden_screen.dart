import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/features/garden/screens/pilih_tanaman_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditGardenScreen extends StatefulWidget {
  final String namaKebun;
  final String alamat;
  final String pemilik;
  final String telepon;
  final File? fotoKebun;
  final String? id;

  const EditGardenScreen({
    super.key,
    required this.namaKebun,
    required this.alamat,
    required this.pemilik,
    required this.telepon,
    this.fotoKebun,
    this.id,
  });

  @override
  State<EditGardenScreen> createState() => _EditGardenScreenState();
}

class _EditGardenScreenState extends State<EditGardenScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaKebunController;
  late TextEditingController _alamatController;
  late TextEditingController _pemilikController;
  late TextEditingController _teleponController;
  File? _fotoKebun;
  bool _isHidup = true;
  List<Map<String, String>> _zones = [
    {'zoneName': 'Zona 1', 'plantName': '', 'plantImage': ''},
  ];

  @override
  void initState() {
    super.initState();
    _namaKebunController = TextEditingController(text: widget.namaKebun);
    _alamatController = TextEditingController(text: widget.alamat);
    _pemilikController = TextEditingController(text: widget.pemilik);
    _teleponController = TextEditingController(text: widget.telepon);
    _fotoKebun = widget.fotoKebun;
    // Load zones yang sudah tersimpan (jika ada) berdasarkan id / nama
    _loadExistingZones();
  }

  Future<void> _loadExistingZones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('gardens');
    if (raw == null) return;
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        Map? found;
        if (widget.id != null) {
          found = list.whereType<Map>().firstWhere(
            (e) => e['id'] == widget.id,
            orElse: () => {},
          );
        }
        found ??= list.whereType<Map>().firstWhere(
          (e) => e['name'] == widget.namaKebun || e['nama'] == widget.namaKebun,
          orElse: () => {},
        );
        if (found.isNotEmpty && found['zones'] is List) {
          final loaded = (found['zones'] as List)
              .whereType<Map>()
              .map(
                (z) => {
                  'zoneName': (z['zoneName'] ?? 'Zona').toString(),
                  'plantName': (z['plantName'] ?? '').toString(),
                  'plantImage': (z['plantImage'] ?? '').toString(),
                },
              )
              .toList();
          if (loaded.isNotEmpty) {
            setState(() => _zones = loaded.cast<Map<String, String>>());
          }
        }
      }
    } catch (_) {}
  }

  String _plantImageFor(String plantName) {
    const map = {
      'Semangka': 'assets/image/semangka.png',
      'Jagung': 'assets/image/jagung.png',
      'Tomat': 'assets/image/tomat.png',
      'Terong': 'assets/image/terong.png',
      'Melon': 'assets/image/melon.png',
      'Kentang': 'assets/image/kentang.png',
      'Cabai': 'assets/image/cabai.png',
      'Timun': 'assets/image/timun.png',
      'Kangkung': 'assets/image/kangkung.png',
      'Sawi': 'assets/image/sawi.png',
      'Strawberry': 'assets/image/strawberry.png',
    };
    return map[plantName] ?? 'assets/image/cabai.png';
  }

  @override
  void dispose() {
    _namaKebunController.dispose();
    _alamatController.dispose();
    _pemilikController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web: use file_picker
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        // On web, you get bytes, not a File
        setState(() {
          _fotoKebun = null; // For web, you may want to store bytes separately
        });
        // You can store result.files.single.bytes in a variable for upload
        // For now, just show file name in the UI
      }
    } else {
      // Mobile/desktop: use image_picker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _fotoKebun = File(pickedFile.path);
        });
      }
    }
  }

  // 1. Pastikan _smallTextField didefinisikan sebelum build agar dikenali
  Widget _smallTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 36.h,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTheme.bodyMedium.copyWith(fontSize: 13.sp),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: const Color(0xFFBDBDBD),
            fontSize: 13.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35591A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icon/kembali_putih.svg',
            width: 20.w,
            height: 20.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Kebun',
          style: AppTheme.heading3.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 48.h,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status di paling atas
                Row(
                  children: [
                    Text(
                      'Status',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _isHidup ? 'Hidup' : 'Mati',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Switch(
                      value: _isHidup,
                      onChanged: (value) {
                        setState(() {
                          _isHidup = value;
                        });
                      },
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _smallTextField(_namaKebunController, 'Nama Kebun'),
                SizedBox(height: 8.h),
                _smallTextField(_alamatController, 'Alamat'),
                SizedBox(height: 8.h),
                _smallTextField(_pemilikController, 'Nama Pekebun'),
                SizedBox(height: 8.h),
                _smallTextField(
                  _teleponController,
                  'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 8.h),
                // Field gambar: hanya tampilkan nama file
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36.h,
                        child: TextFormField(
                          enabled: false,
                          style: AppTheme.bodyMedium.copyWith(fontSize: 13.sp),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Foto Kebun',
                            hintStyle: AppTheme.bodyMedium.copyWith(
                              color: const Color(0xFFBDBDBD),
                              fontSize: 13.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 12.w,
                            ),
                          ),
                          controller: TextEditingController(
                            text: kIsWeb
                                ? '' // Optionally show file name if you store it
                                : _fotoKebun != null
                                ? _fotoKebun!.path
                                      .split(Platform.pathSeparator)
                                      .last
                                : '',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD9D9D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        minimumSize: Size(0, 36.h),
                      ),
                      onPressed: _pickImage,
                      child: Text(
                        _fotoKebun == null ? 'Tambah Foto' : 'Ubah Foto',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Zona (contoh satu zona, bisa diubah jadi list jika multi zona)
                Column(
                  children: [
                    ..._zones.asMap().entries.map((entry) {
                      int i = entry.key;
                      var zone = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    zone['zoneName'] ?? 'Zona',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.of(context)
                                          .push<String>(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PilihTanamanScreen(),
                                            ),
                                          );
                                      if (result != null) {
                                        setState(() {
                                          _zones[i]['plantName'] = result;
                                          _zones[i]['plantImage'] =
                                              _plantImageFor(result);
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD9D9D9),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            zone['plantName']?.isNotEmpty ==
                                                    true
                                                ? zone['plantName']!
                                                : 'Pilih Tanaman',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          SizedBox(width: 2.w),
                                          Transform.rotate(
                                            angle: 1.5708,
                                            child: SvgPicture.asset(
                                              'assets/icon/kembali_putih.svg',
                                              width: 12.w,
                                              height: 12.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),
                            // Icon hapus elips merah
                            if (_zones.length > 1)
                              Container(
                                width: 28.w,
                                height: 28.w,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _zones.removeAt(i);
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  splashRadius: 18.w,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          minimumSize: Size(0, 36.h),
                        ),
                        onPressed: () {
                          setState(() {
                            _zones.add({
                              'zoneName': 'Zona ${_zones.length + 1}',
                              'plantName': '',
                              'plantImage': '',
                            });
                          });
                        },
                        child: Text(
                          'Tambah Zona',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryGreen,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 10.h,
                      ),
                      minimumSize: Size(0, 40.h),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      // Update data kebun di SharedPreferences berdasarkan nama lama (simple key)
                      final prefs = await SharedPreferences.getInstance();
                      final raw = prefs.getString('gardens');
                      List list = [];
                      if (raw != null) {
                        try {
                          list = jsonDecode(raw);
                        } catch (_) {}
                      }
                      // Cari index garden berdasarkan nama awal (widget.namaKebun)
                      int idx = -1;
                      if (widget.id != null) {
                        idx = list.indexWhere((g) => g['id'] == widget.id);
                      }
                      if (idx < 0) {
                        idx = list.indexWhere(
                          (g) =>
                              (g['name'] == widget.namaKebun) ||
                              (g['nama'] == widget.namaKebun),
                        );
                      }
                      Map<String, dynamic>? old;
                      if (idx >= 0) {
                        final candidate = list[idx];
                        if (candidate is Map<String, dynamic>) {
                          old = candidate;
                        } else if (candidate is Map) {
                          old = candidate.map((k, v) => MapEntry('$k', v));
                        }
                      }
                      final updated = {
                        'id': old?['id'] ?? widget.id,
                        'name': _namaKebunController.text,
                        'address': _alamatController.text,
                        'owner': _pemilikController.text,
                        'phone': _teleponController.text,
                        'image': _fotoKebun?.path ?? (old?['image'] ?? ''),
                        'status': _isHidup ? 'hidup' : 'mati',
                        'zones': _zones,
                      };
                      if (idx >= 0) {
                        list[idx] = updated;
                      } else {
                        list.add(updated); // fallback kalau tidak ketemu
                      }
                      await prefs.setString('gardens', jsonEncode(list));
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Simpan',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
