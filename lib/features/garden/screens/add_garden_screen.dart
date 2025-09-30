import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:pakebun_app/features/garden/screens/pilih_tanaman_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pakebun_app/common/utils/id_generator.dart';

class AddGardenScreen extends StatefulWidget {
  const AddGardenScreen({super.key});

  @override
  State<AddGardenScreen> createState() => _AddGardenScreenState();
}

class _AddGardenScreenState extends State<AddGardenScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaKebunController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _namaPekebunController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  File? _fotoKebun;
  // Untuk web
  Uint8List? _fotoKebunBytes;
  final List<String?> _selectedTanamanList = [null];

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _fotoKebunBytes = result.files.single.bytes;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _fotoKebun = File(pickedFile.path);
        });
      }
    }
  }

  void _addZona() {
    setState(() {
      _selectedTanamanList.add(null);
    });
  }

  Future<void> _pilihTanaman(int index) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => PilihTanamanScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedTanamanList[index] = result;
      });
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if ((kIsWeb && _fotoKebunBytes == null) ||
        (!kIsWeb && _fotoKebun == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto kebun wajib diisi!')));
      return;
    }
    if (_selectedTanamanList.any((tanaman) => tanaman == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua zona wajib pilih tanaman!')),
      );
      return;
    }
    // Ambil gardens lama dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final gardensString = prefs.getString('gardens');
    List<dynamic> gardens = [];
    if (gardensString != null) {
      gardens = jsonDecode(gardensString);
    }
    // Tentukan representasi gambar: path (mobile) atau base64 (web)
    String imageValue = '';
    if (kIsWeb) {
      if (_fotoKebunBytes != null) {
        imageValue = 'data:image;base64,' + base64Encode(_fotoKebunBytes!);
      }
    } else {
      if (_fotoKebun != null) imageValue = _fotoKebun!.path;
    }

    final newGarden = {
      'id': generateId(),
      'name': _namaKebunController.text,
      'address': _alamatController.text,
      'owner': _namaPekebunController.text,
      'phone': _teleponController.text,
      'image': imageValue,
      'status': 'Aktif',
      'zones': List.generate(_selectedTanamanList.length, (i) {
        final plantName = _selectedTanamanList[i]!;
        return {
          'zoneName': 'Zona ${i + 1}',
          'plantName': plantName,
          'plantImage': _plantImageFor(plantName),
        };
      }),
    };
    gardens.add(newGarden);
    await prefs.setString('gardens', jsonEncode(gardens));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _plantImageFor(String plantName) {
    // Simple mapping; fallback to cabai image if not found.
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
          'Tambah Kebun',
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
                _smallTextField(_namaKebunController, 'Nama Kebun'),
                SizedBox(height: 8.h),
                _smallTextField(_alamatController, 'Alamat'),
                SizedBox(height: 8.h),
                _smallTextField(_namaPekebunController, 'Nama Pekebun'),
                SizedBox(height: 8.h),
                _smallTextField(
                  _teleponController,
                  'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (kIsWeb) {
                            if (_fotoKebunBytes == null) {
                              return _smallTextField(
                                null,
                                'Foto Kebun',
                                enabled: false,
                              );
                            } else {
                              return Container(
                                height: 40.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.memory(
                                    _fotoKebunBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          } else {
                            if (_fotoKebun == null) {
                              return _smallTextField(
                                null,
                                'Foto Kebun',
                                enabled: false,
                              );
                            } else {
                              return Container(
                                height: 40.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.file(
                                    _fotoKebun!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          }
                        },
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
                        (kIsWeb
                                ? (_fotoKebunBytes == null)
                                : (_fotoKebun == null))
                            ? 'Tambah Foto'
                            : 'Ganti Foto',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ...List.generate(
                  _selectedTanamanList.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
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
                                'Zona ${i + 1}',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () => _pilihTanaman(i),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedTanamanList[i] ??
                                            'Pilih Tanaman',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      // Ikon panah turun (sesuai 21.png) menggantikan panah yang sebelumnya mengarah ke atas
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16.sp,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    onPressed: _addZona,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tambah Zona',
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.all(2.w),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      minimumSize: Size(0, 36.h),
                    ),
                    onPressed: _simpan,
                    child: Text(
                      'Simpan',
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemSelected: (i) {},
      ),
    );
  }

  Widget _smallTextField(
    TextEditingController? controller,
    String hint, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 36.h,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
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
        validator: (v) =>
            enabled && (v == null || v.isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }
}

//
