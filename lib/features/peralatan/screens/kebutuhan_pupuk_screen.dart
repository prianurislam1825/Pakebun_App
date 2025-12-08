import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';

/// Screen tunggal yang menampilkan form (11.png) dan setelah hitung menampilkan hasil (12.png)
class KebutuhanPupukScreen extends StatefulWidget {
  final String namaTanaman;
  final String latinTanaman;
  final String gambarBackground;
  const KebutuhanPupukScreen({
    super.key,
    required this.namaTanaman,
    required this.latinTanaman,
    required this.gambarBackground,
  });

  @override
  State<KebutuhanPupukScreen> createState() => _KebutuhanPupukScreenState();
}

class _KebutuhanPupukScreenState extends State<KebutuhanPupukScreen> {
  final _luasController = TextEditingController(text: '');
  final _populasiController = TextEditingController(text: '');
  bool _showResult = false;
  late FocusNode _luasFocus;
  late FocusNode _popFocus;

  // Hasil perhitungan (placeholder). Dalam implementasi nyata ini bisa datang dari service / rumus agronomi.
  late List<_RekomPupuk> _hasil;

  @override
  void initState() {
    super.initState();
    _luasFocus = FocusNode();
    _popFocus = FocusNode();
    _hasil = [];
  }

  @override
  void dispose() {
    _luasController.dispose();
    _populasiController.dispose();
    _luasFocus.dispose();
    _popFocus.dispose();
    super.dispose();
  }

  void _hitung() {
    final luas =
        double.tryParse(_luasController.text.replaceAll(',', '.')) ?? 0;
    final populasi = int.tryParse(_populasiController.text) ?? 0;
    if (luas <= 0 || populasi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi luas & populasi yang valid')),
      );
      return;
    }
    // Rumus sederhana placeholder: kebutuhan NPK per tanaman (g) = 5 + (luas/1000)
    // Bisa disesuaikan kemudian.
    final base = 5 + (luas / 1000);
    final totalDosis = base * populasi; // gram total
    // Estimasi kandungan nutrisi (persen). Dummy.
    final n = totalDosis * 0.15;
    final p = totalDosis * 0.10;
    final k = totalDosis * 0.12;
    // Perkiraan biaya: Rp 50.000 per kg
    final biaya = (totalDosis / 1000) * 50000;
    _hasil = [
      _RekomPupuk(
        nama: 'NPK Mahkota',
        dosisGram: totalDosis,
        n: n,
        p: p,
        k: k,
        biaya: biaya,
      ),
    ];
    setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(
              path: widget.gambarBackground,
              onBack: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                '${widget.namaTanaman} (${widget.latinTanaman})',
                style: AppTheme.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Luas Lahan'),
                  _NumberField(
                    controller: _luasController,
                    hint: '0',
                    focusNode: _luasFocus,
                  ),
                  SizedBox(height: 14.h),
                  _label('Populasi Tanaman'),
                  _NumberField(
                    controller: _populasiController,
                    hint: '0',
                    focusNode: _popFocus,
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: SizedBox(
                      width: 140.w,
                      height: 40.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF35591A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        onPressed: _hitung,
                        child: Text(
                          _showResult ? 'Hitung Ulang' : 'Hitung',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showResult) ...[
                    SizedBox(height: 28.h),
                    _ResultTable(items: _hasil),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
        onItemSelected: _noopNav,
      ),
    );
  }

  static void _noopNav(int i) {}

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    ),
  );
}

class _HeaderImage extends StatelessWidget {
  final String path;
  final VoidCallback onBack;
  const _HeaderImage({required this.path, required this.onBack});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.r),
            bottomRight: Radius.circular(40.r),
          ),
          child: Image.asset(
            path,
            width: double.infinity,
            height: 220.h,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 32.h,
          left: 16.w,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  const _NumberField({
    required this.controller,
    required this.hint,
    required this.focusNode,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF35591A),
        borderRadius: BorderRadius.circular(6.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 13.sp),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _ResultTable extends StatelessWidget {
  final List<_RekomPupuk> items;
  const _ResultTable({required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF35591A),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(),
          SizedBox(height: 6.h),
          ...items.map(_row),
          SizedBox(height: 10.h),
          Divider(
            color: Colors.white.withOpacity(.4),
            height: 20.h,
            thickness: .7,
          ),
          ...items.map(_costRow),
        ],
      ),
    );
  }

  Widget _headerRow() => Row(
    children: [
      _cell('Pupuk', flex: 3, bold: true),
      _cell('Dosis', bold: true),
      _cell('N', bold: true),
      _cell('P', bold: true),
      _cell('K', bold: true),
    ],
  );

  Widget _row(_RekomPupuk r) => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: Row(
      children: [
        _cell(r.nama, flex: 3),
        _cell(r.dosisGram.toStringAsFixed(2)),
        _cell(r.n.toStringAsFixed(2)),
        _cell(r.p.toStringAsFixed(2)),
        _cell(r.k.toStringAsFixed(2)),
      ],
    ),
  );

  Widget _costRow(_RekomPupuk r) => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: Row(
      children: [
        _cell('Perkiraan Biaya', flex: 3, bold: true),
        Expanded(
          flex: 4,
          child: Text(
            'Rp ${r.biaya.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _cell(String text, {int flex = 1, bool bold = false}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 11.sp,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class _RekomPupuk {
  final String nama;
  final double dosisGram; // total gram
  final double n;
  final double p;
  final double k;
  final double biaya; // Rupiah
  _RekomPupuk({
    required this.nama,
    required this.dosisGram,
    required this.n,
    required this.p,
    required this.k,
    required this.biaya,
  });
}
