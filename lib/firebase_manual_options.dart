import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Manual FirebaseOptions extracted from android/app/google-services.json so we
/// can proceed without running flutterfire CLI yet. For now only Android is
/// defined. If you add other platforms later, generate firebase_options.dart
/// via `flutterfire configure` and remove this file.
class ManualFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web FirebaseOptions not configured. Run flutterfire configure.',
      );
    }
    // For iOS/MacOS/Windows/Linux you also need platform-specific options.
    // Currently we target only Android.
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuW1FTmvCCySc9epA1Zho3kJAaOm5sE9E',
    appId: '1:570870921203:android:f17aad026efd50944b0486',
    messagingSenderId: '570870921203',
    projectId: 'pakebun-app',
    storageBucket: 'pakebun-app.firebasestorage.app',
  );
}
