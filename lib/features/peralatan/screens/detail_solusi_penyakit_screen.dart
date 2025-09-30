import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';

class DetailSolusiPenyakitScreen extends StatelessWidget {
  const DetailSolusiPenyakitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
        centerTitle: true,
        title: Text(
          'Layu Bakteri',
          style: AppTheme.heading2.copyWith(
            color: const Color(0xFF466D1D),
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            SizedBox(height: 12.h),
            Text(
              'Deskripsi',
              style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6.h),
            Text(
              'Pengolahan tanah tomat dimulai dengan membersihkan lahan dari gulma dan tanaman liar, lalu dilakukan pembajakan untuk menghancurkan bongkahan tanah agar menjadi halus dan gembur. Setelah itu, dibuat bedengan yang berfungsi mempermudah perawatan tanaman serta melindungi tomat dari risiko genangan air ketika hujan turun.',
              style: AppTheme.bodyMedium,
            ),
            SizedBox(height: 18.h),
            Text(
              'Solusi',
              style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),
            _SolusiItem(
              image: 'assets/image/layu_bakteri1.png',
              title: 'Bersihkan Gulma dan Tanaman Sakit',
              desc:
                  '• Singkirkan Gulma Serta Tanaman Tomat Yang Mati Atau Terinfeksi Agar Tidak Menjadi Sumber Penyebaran Penyakit.',
            ),
            SizedBox(height: 12.h),
            _SolusiItem(
              image: 'assets/image/layu_bakteri2.png',
              title: 'Pengolahan tanah & pembuatan bedengan',
              desc:
                  '• Setelah Lahan Bersih, Lakukan Pembajakan Untuk Menggemburkan Tanah.\n• Bentuk Bedengan Agar Perawatan Lebih Mudah Dan Mencegah Genangan Air Saat Hujan.',
            ),
            SizedBox(height: 12.h),
            _SolusiItem(
              image: 'assets/image/layu_bakteri3.png',
              title: 'Gunakan Bibit Sehat',
              desc:
                  '• Pilih Bibit Tomat Yang Terbebas Dari Penyakit Untuk Mengurangi Risiko Serangan Layu Bakteri.',
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemSelected: (i) {},
      ),
    );
  }
}

class _SolusiItem extends StatelessWidget {
  final String image;
  final String title;
  final String desc;

  const _SolusiItem({
    required this.image,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(desc, style: AppTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
