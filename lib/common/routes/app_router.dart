import 'package:go_router/go_router.dart';

// import screen
import 'package:pakebun_app/features/onboarding/screens/splash_screen.dart';
import 'package:pakebun_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:pakebun_app/features/auth/screens/login_screen.dart';

import 'package:pakebun_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:pakebun_app/features/garden/screens/garden_list_screen.dart';
import 'package:pakebun_app/features/profile/screens/profile_screen.dart';
import 'package:pakebun_app/features/auth/screens/reset_sandi_screen.dart';
import 'package:pakebun_app/features/auth/screens/register_screen.dart';

// Monitoring screens
import 'package:pakebun_app/features/monitoring/screens/monitoring_dashboard_screen.dart';
import 'package:pakebun_app/features/monitoring/screens/soil_monitoring_screen.dart';
import 'package:pakebun_app/features/monitoring/screens/weather_monitoring_screen.dart';
import 'package:pakebun_app/features/monitoring/screens/power_monitoring_screen.dart';
import 'package:pakebun_app/features/monitoring/screens/equipment_control_screen.dart';

final GoRouter appRouter = GoRouter(
  // Kembalikan ke splash; splash sekarang akan auto redirect (auth / onboarding logic).
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/reset-sandi',
      builder: (context, state) => const ResetSandiScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/garden',
      builder: (context, state) => const GardenListScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    // Monitoring routes
    GoRoute(
      path: '/monitoring',
      builder: (context, state) => const MonitoringDashboardScreen(),
    ),
    GoRoute(
      path: '/monitoring/soil',
      builder: (context, state) => const SoilMonitoringScreen(),
    ),
    GoRoute(
      path: '/monitoring/weather',
      builder: (context, state) => const WeatherMonitoringScreen(),
    ),
    GoRoute(
      path: '/monitoring/power',
      builder: (context, state) => const PowerMonitoringScreen(),
    ),
    GoRoute(
      path: '/monitoring/equipment',
      builder: (context, state) => const EquipmentControlScreen(),
    ),
  ],
);
