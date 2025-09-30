import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pakebun_app/common/routes/app_router.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow skipping Firebase initialization for debugging crash isolation:
  const bool skipFirebase = bool.fromEnvironment('SKIP_FIREBASE');

  // Tangkap error sinkron Flutter
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
  // Tangkap error asynchronous di zone
  await runZonedGuarded<Future<void>>(
    () async {
      if (!skipFirebase) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } catch (e, st) {
          debugPrint('Firebase init error: $e\n$st');
        }
      } else {
        debugPrint('Skipping Firebase init (SKIP_FIREBASE=true)');
      }
      runApp(const PakebunApp());
    },
    (error, stack) {
      debugPrint('Zoned error: $error\n$stack');
    },
  );
}

class PakebunApp extends StatelessWidget {
  const PakebunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // sesuaikan dengan ukuran figma
      minTextAdapt: true, // biar font bisa auto scale
      splitScreenMode: true, // support untuk tablet / split screen
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Pakebun App',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: AppTheme.themeData,
        );
      },
    );
  }
}
