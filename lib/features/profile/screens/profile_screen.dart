import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:pakebun_app/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pakebun_app/features/auth/controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  String _name = '';
  String _email = '';
  String? _photoPath;
  User? _firebaseUser;
  String? _cachedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    String storedName = prefs.getString('user_name') ?? '';
    String storedEmail = prefs.getString('user_email') ?? '';
    _cachedPhotoUrl = prefs.getString('user_photo_url');

    // Prefer Firebase user info if available
    final displayName = user?.displayName;
    final email = user?.email;

    _photoPath = prefs.getString('user_photo');
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      _imageFile = File(_photoPath!);
    }

    setState(() {
      _firebaseUser = user;
      _name = (displayName != null && displayName.isNotEmpty)
          ? displayName
          : storedName;
      _email = (email != null && email.isNotEmpty) ? email : storedEmail;
    });
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        // Untuk web, simpan nama file saja (atau bytes jika ingin upload ke server)
        setState(() {
          _imageFile =
              null; // Atur sesuai kebutuhan, misal simpan bytes di variabel lain
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _photoPath = pickedFile.path;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo', pickedFile.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35591A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 32.h),
                SvgPicture.asset(
                  'assets/vector/logo_putih.svg',
                  width: 120.w,
                  height: 48.h,
                ),
                SizedBox(height: 32.h),
                // Foto profil bundar dengan upload
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48.w,
                    backgroundColor: Colors.white,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_firebaseUser?.photoURL != null
                                  ? NetworkImage(_firebaseUser!.photoURL!)
                                  : (_cachedPhotoUrl != null &&
                                            _cachedPhotoUrl!.isNotEmpty
                                        ? NetworkImage(_cachedPhotoUrl!)
                                        : null))
                              as ImageProvider?,
                    child:
                        (_imageFile == null &&
                            _firebaseUser?.photoURL == null &&
                            (_cachedPhotoUrl == null ||
                                _cachedPhotoUrl!.isEmpty))
                        ? Icon(
                            Icons.person,
                            size: 48.w,
                            color: AppTheme.textSecondary,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  _name,
                  style: AppTheme.heading3.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  _email,
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () {
                    if (!mounted) return;
                    context.go('/reset-sandi');
                  },
                  child: Text(
                    'Reset Sandi',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: 160.w,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB3261E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    onPressed: () async {
                      // Sign out from Firebase (and Google) + optional local clear
                      await AuthController.instance.signOut();
                      final prefs = await SharedPreferences.getInstance();
                      // Keep onboarding flag, but you may clear user-specific stored creds
                      await prefs.remove('user_email');
                      await prefs.remove('user_password');
                      if (!mounted) return;
                      context.go('/login');
                    },
                    child: Text(
                      'Keluar',
                      style: AppTheme.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Versi Aplikasi 001',
                  style: AppTheme.caption.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onItemSelected: (i) {
          if (i != 2) {
            if (!mounted) return;
            if (i == 0) Future.microtask(() => context.go('/dashboard'));
            if (i == 1) Future.microtask(() => context.go('/garden'));
            if (i == 2) Future.microtask(() => context.go('/profile'));
          }
        },
      ),
    );
  }
}
