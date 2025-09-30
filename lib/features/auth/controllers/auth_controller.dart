import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton controller sederhana untuk autentikasi Firebase + Google.
/// Extend di masa depan (email/password, logout, dsb).
class AuthController {
  AuthController._();
  static final AuthController instance = AuthController._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: const ['email', 'profile']);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Login dengan Google. Return UserCredential atau null kalau gagal/batal.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Untuk web bisa langsung gunakan signInWithPopup
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final cred = await _auth.signInWithPopup(googleProvider);
        await _cacheUser(cred.user);
        return cred;
      }
      final googleUser = await _google.signIn();
      if (googleUser == null) return null; // user batal
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await _cacheUser(cred.user);
      return cred;
    } catch (e, st) {
      debugPrint('Google sign-in error: $e\n$st');
      return null;
    }
  }

  Future<void> _cacheUser(User? user) async {
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.displayName ?? '');
      await prefs.setString('user_email', user.email ?? '');
      if (user.photoURL != null) {
        await prefs.setString('user_photo_url', user.photoURL!);
      }
    } catch (e) {
      debugPrint('Cache user failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _google.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_photo_url');
      // Biarkan onboarding flag tetap.
    } catch (_) {}
  }
}
