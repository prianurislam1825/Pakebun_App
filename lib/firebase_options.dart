// GENERATED-LIKE FILE (manual since flutterfire CLI login not available yet)
// Once you can run `flutterfire configure`, replace this file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured. Run flutterfire configure.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Platform not configured.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuW1FTmvCCySc9epA1Zho3kJAaOm5sE9E',
    appId: '1:570870921203:android:f17aad026efd50944b0486',
    messagingSenderId: '570870921203',
    projectId: 'pakebun-app',
    storageBucket: 'pakebun-app.firebasestorage.app',
  );
}
