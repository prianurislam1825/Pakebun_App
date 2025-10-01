import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pakebun_app/features/garden/screens/add_garden_screen.dart';
import 'package:pakebun_app/features/garden/screens/edit_garden_screen.dart';
import 'package:pakebun_app/features/garden/screens/garden_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pakebun_app/common/utils/id_generator.dart';

// Layar daftar kebun: menampilkan card sesuai desain 23.png
class GardenListScreen extends StatefulWidget {
  const GardenListScreen({super.key});

  @override
  State<GardenListScreen> createState() => _GardenListScreenState();
}

class _GardenListScreenState extends State<GardenListScreen> {
  static const _prefsKey = 'gardens';
  bool _loading = true;
  List<Map<String, dynamic>> _gardens = [];

  @override
  void initState() {
    super.initState();
    _loadGardens();
  }

  Future<void> _loadGardens() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _gardens = decoded
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .cast<Map<String, dynamic>>()
              .toList();
          bool mutated = false;
          for (var g in _gardens) {
            if (!g.containsKey('id')) {
              g['id'] = generateId();
              mutated = true;
            }
          }
          if (mutated) {
            await prefs.setString(_prefsKey, jsonEncode(_gardens));
          }
        }
      } catch (_) {
        _gardens = [];
      }
    } else {
      _gardens = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openAdd() async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddGardenScreen()));
    if (added == true) {
      _loadGardens();
    }
  }

  void _deleteGarden(int index) async {
    final targetId = _gardens[index]['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Kebun'),
        content: const Text('Yakin ingin menghapus kebun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        if (targetId != null) {
          _gardens.removeWhere((g) => g['id'] == targetId);
        } else {
          _gardens.removeAt(index);
        }
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_gardens));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35591A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/vector/logo_putih.svg',
          width: 110.w,
          height: 36.h,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _gardens.isEmpty
                  ? _EmptyState(onAdd: _openAdd)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      itemBuilder: (c, i) => _GardenCard(
                        data: _gardens[i],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GardenDetailScreen(
                                garden: _gardens[i],
                              ),
                            ),
                          );
                        },
                        onEdit: () async {
                          final g = _gardens[i];
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditGardenScreen(
                                id: g['id']?.toString(),
                                namaKebun: (g['name'] ?? g['nama'] ?? '').toString(),
                                alamat: (g['address'] ?? g['alamat'] ?? '').toString(),
                                pemilik: (g['owner'] ?? g['pemilik'] ?? '').toString(),
                                telepon: (g['phone'] ?? g['telepon'] ?? '').toString(),
                                fotoKebun: null,
                              ),
                            ),
                          );
                          _loadGardens();
                        },
                        onDelete: () => _deleteGarden(i),
                      ),
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemCount: _gardens.length,
                    ),
            ),
            if (!_loading && _gardens.isNotEmpty) ...[
              SizedBox(height: 4.h),
              _AddButton(onTap: _openAdd),
              SizedBox(height: 16.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 150.w, maxWidth: 220.w),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tambah Kebun',
                  style: TextStyle(
                    color: const Color(0xFF35591A),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF35591A),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add, color: Colors.white, size: 14.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grass, size: 64.sp, color: Colors.white24),
          SizedBox(height: 12.h),
          Text(
            'Belum ada kebun',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Tambah kebun pertama kamu',
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          _AddButton(onTap: onAdd),
        ],
      ),
    );
  }
}

class _GardenCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _GardenCard({
    required this.data,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static Widget placeholder() => Builder(
    builder: (context) => Container(
      width: 100.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.photo, color: const Color(0xFF35591A), size: 28.sp),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? data['nama'] ?? 'Kebun').toString();
    final address = (data['address'] ?? data['alamat'] ?? '-').toString();
    final owner = (data['owner'] ?? data['pemilik'] ?? '').toString();
    final phone = (data['phone'] ?? data['telepon'] ?? '').toString();
    final imagePath = (data['image'] ?? '').toString();
    Widget imageWidget;
    if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('data:image')) {
        // web base64
        try {
          final base64Data = imagePath.split(',').last;
          final bytes = base64Decode(base64Data);
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.memory(
              bytes,
              width: 100.w,
              height: 80.w,
              fit: BoxFit.cover,
            ),
          );
        } catch (_) {
          imageWidget = _GardenCard.placeholder();
        }
      } else if (File(imagePath).existsSync()) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Image.file(
            File(imagePath),
            width: 100.w,
            height: 80.w,
            fit: BoxFit.cover,
          ),
        );
      } else {
        imageWidget = _GardenCard.placeholder();
      }
    } else {
      imageWidget = _GardenCard.placeholder();
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
        // Center so image berada di tengah tinggi card dibanding kolom icon
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageWidget,
              SizedBox(width: 10.w),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF35591A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (address.isNotEmpty)
                        Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF35591A),
                          ),
                        ),
                      if (owner.isNotEmpty) SizedBox(height: 4.h),
                      if (owner.isNotEmpty)
                        Text(
                          owner,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF35591A),
                          ),
                        ),
                      if (phone.isNotEmpty) SizedBox(height: 2.h),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF35591A),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIcon(
                    color: const Color(0xFF1B6D1B),
                    icon: Icons.edit,
                    onTap: onEdit,
                  ),
                  SizedBox(height: 8.h),
                  _ActionIcon(
                    color: const Color(0xFFD20000),
                    icon: Icons.delete,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionIcon({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 16.sp, color: Colors.white),
      ),
    );
  }
}
