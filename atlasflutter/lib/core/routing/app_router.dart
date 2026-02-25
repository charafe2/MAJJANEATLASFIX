import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/choose_profile_screen.dart';
import '../../features/auth/screens/basic_info_screen.dart';
import '../../features/auth/screens/choose_verif_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/client_details_screen.dart';
import '../../features/auth/screens/artisan_pro_screen.dart';
import '../../features/auth/screens/artisan_portfolio_screen.dart';
import '../../features/auth/screens/password_screen.dart';
import '../../features/auth/screens/tier_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/client/screens/client_profile_screen.dart';
import '../../features/client/screens/client_info_screen.dart';
import '../../features/client/screens/client_home_screen.dart';
import '../../features/client/screens/client_agenda_screen.dart';
import '../../features/client/screens/client_service_category_screen.dart';
import '../../features/client/screens/client_service_type_screen.dart';
import '../../features/client/screens/client_request_details_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETE REGISTRATION FLOWS
// ─────────────────────────────────────────────────────────────────────────────
//
// CLIENT:
//   choose-profile → basic-info → choose-verif → otp → client-details
//   → password → otp-verify → /client/dashboard
//
// ARTISAN:
//   choose-profile → basic-info → choose-verif → otp → artisan-pro
//   → artisan-portfolio → password → tier → /artisan/dashboard
//
// All state is passed via GoRouter `extra` as Map<String, dynamic>.
// Keys accumulate at each step.
// ─────────────────────────────────────────────────────────────────────────────

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',
      builder: (_, __) => const SplashScreen()),
  GoRoute(path: '/Home',
      builder: (_, __) => const ClientHomeScreen()),
    GoRoute(path: '/login',
      builder: (_, __) => const LoginScreen()),

    GoRoute(path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen()),

    GoRoute(path: '/choose-profile',
      builder: (_, __) => const ChooseProfileScreen()),

    // ── Step 1: Basic info (name, birthdate, email, phone) ────────────────
    GoRoute(path: '/register/basic',
      builder: (_, state) =>
          BasicInfoScreen(data: (state.extra as Map<String, dynamic>?) ?? {})),

    // ── Step 2: Choose verification method (its own screen) ───────────────
    GoRoute(path: '/register/choose-verif',
      builder: (_, state) =>
          ChooseVerifScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Step 3: OTP entry (before full details — just validate the method) ─
    GoRoute(path: '/register/otp',
      builder: (_, state) =>
          OtpScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Step 4a: Client details (city + address) ──────────────────────────
    GoRoute(path: '/register/client-details',
      builder: (_, state) =>
          ClientDetailsScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Step 4b: Artisan professional info ────────────────────────────────
    GoRoute(path: '/register/artisan-pro',
      builder: (_, state) =>
          ArtisanProScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Step 4c: Artisan portfolio + bio ──────────────────────────────────
    GoRoute(path: '/register/artisan-portfolio',
      builder: (_, state) =>
          ArtisanPortfolioScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Step 5: Set password + call register API ──────────────────────────
    GoRoute(path: '/register/password',
      builder: (_, state) =>
          PasswordScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Step 6 (artisan only): Tier selection ─────────────────────────────
    GoRoute(path: '/register/tier',
      builder: (_, state) =>
          TierScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Final OTP verify (post-register, has real user_id) ────────────────
    GoRoute(path: '/register/otp-verify',
      builder: (_, state) =>
          OtpVerifyScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Client dashboard + sub-screens ───────────────────────────────────
    GoRoute(path: '/client/dashboard',
      builder: (_, __) => const ClientHomeScreen()),
    GoRoute(path: '/client/profile',
      builder: (_, __) => const ClientProfileScreen()),
    GoRoute(path: '/client/info',
      builder: (_, __) => const ClientInfoScreen()),
    GoRoute(path: '/client/agenda',
      builder: (_, __) => const ClientAgendaScreen()),

    GoRoute(path: '/client/service-categories',
      builder: (_, __) => const ClientServiceCategoryScreen()),

    GoRoute(path: '/client/service-types',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final category = extra['category'] as String? ??
            state.uri.queryParameters['category'] ?? '';
        return ClientServiceTypeScreen(categoryName: category);
      }),

    GoRoute(path: '/client/nouvelle-demande',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ClientRequestDetailsScreen(
          category: extra['category'] as String? ?? '',
          services: (extra['services'] as List?)?.cast<String>() ?? [],
        );
      }),

    // ── Artisan dashboard (placeholder) ───────────────────────────────────
    GoRoute(path: '/artisan/dashboard',
      builder: (_, __) => const _ArtisanDashboard()),
  ],
);

class _ArtisanDashboard extends StatelessWidget {
  const _ArtisanDashboard();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dashboard Artisan')),
    body: const Center(child: Text('Dashboard Artisan',
        style: TextStyle(fontSize: 22))),
  );
}