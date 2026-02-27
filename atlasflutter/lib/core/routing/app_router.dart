import 'package:go_router/go_router.dart';
import '../auth_state.dart';
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
import '../../features/client/screens/client_mes_demandes_screen.dart';
import '../../features/client/screens/client_messages_screen.dart';
import '../../features/client/screens/client_chat_screen.dart';
import '../../features/artisan/screens/artisan_public_profile_screen.dart';
import '../../features/artisan/screens/artisan_home_screen.dart';
import '../../features/artisan/screens/artisan_offers_screen.dart';
import '../../features/artisan/screens/artisan_request_detail_screen.dart';
import '../../features/artisan/screens/artisan_profile_screen.dart';
import '../../data/repositories/artisan_job_repository.dart';

// ── Protected routes that require login ───────────────────────────────────────
const _protectedRoutes = [
  '/client/dashboard', '/client/profile', '/client/info', '/client/agenda',
  '/client/mes-demandes', '/client/messages', '/client/chat',
  '/client/service-categories', '/client/service-types',
  '/client/nouvelle-demande',
  '/artisan/dashboard', '/artisan/offers', '/artisan/profile',
  '/artisan/available-requests', '/artisan/request', '/artisan/messages',
  '/artisan/agenda',
];

bool _isProtected(String location) =>
    _protectedRoutes.any((r) => location.startsWith(r));

// ── Router ────────────────────────────────────────────────────────────────────

final appRouter = GoRouter(
  initialLocation:    '/splash',
  refreshListenable:  AuthState.instance,
  redirect: (context, state) {
    final loggedIn  = AuthState.instance.isLoggedIn;
    final location  = state.uri.toString();

    // Redirect unauthenticated users away from protected routes
    if (!loggedIn && _isProtected(location)) return '/login';

    // Redirect authenticated users away from auth screens
    if (loggedIn && (location == '/login' || location == '/splash')) {
      return AuthState.instance.isArtisan ? '/artisan/dashboard' : '/client/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/splash',
      builder: (_, __) => const SplashScreen()),

    GoRoute(path: '/login',
      builder: (_, __) => const LoginScreen()),

    GoRoute(path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen()),

    GoRoute(path: '/choose-profile',
      builder: (_, __) => const ChooseProfileScreen()),

    // ── Registration flow ─────────────────────────────────────────────────
    GoRoute(path: '/register/basic',
      builder: (_, state) =>
          BasicInfoScreen(data: (state.extra as Map<String, dynamic>?) ?? {})),

    GoRoute(path: '/register/choose-verif',
      builder: (_, state) =>
          ChooseVerifScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/otp',
      builder: (_, state) =>
          OtpScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/client-details',
      builder: (_, state) =>
          ClientDetailsScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/artisan-pro',
      builder: (_, state) =>
          ArtisanProScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/artisan-portfolio',
      builder: (_, state) =>
          ArtisanPortfolioScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/password',
      builder: (_, state) =>
          PasswordScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/tier',
      builder: (_, state) =>
          TierScreen(data: state.extra! as Map<String, dynamic>)),

    GoRoute(path: '/register/otp-verify',
      builder: (_, state) =>
          OtpVerifyScreen(data: state.extra! as Map<String, dynamic>)),

    // ── Client dashboard ──────────────────────────────────────────────────
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
        return ClientServiceTypeScreen(
          categoryId:   extra['categoryId'] as int? ?? 0,
          categoryName: extra['category']   as String? ??
                        state.uri.queryParameters['category'] ?? '',
        );
      }),

    GoRoute(path: '/client/nouvelle-demande',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ClientRequestDetailsScreen(
          categoryId:   extra['categoryId']   as int?    ?? 0,
          categoryName: extra['category']     as String? ?? '',
          serviceTypeId: extra['serviceTypeId'] as int?  ?? 0,
          serviceTypeName: extra['serviceType'] as String? ?? '',
        );
      }),

    GoRoute(path: '/client/mes-demandes',
      builder: (_, __) => const ClientMesDemandesScreen()),

    GoRoute(path: '/client/messages',
      builder: (_, __) => const ClientMessagesScreen()),

    GoRoute(path: '/client/chat/:id',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ClientChatScreen(
          conversationId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          otherName:      extra['name'] as String? ?? 'Artisan',
          otherRole:      extra['role'] as String? ?? '',
          otherAvatar:    extra['avatar'] as String?,
          otherProfileId: extra['profileId'] as int?,
        );
      }),

    GoRoute(path: '/artisans/profile/:id',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ArtisanPublicProfileScreen(
          artisanId:   int.tryParse(state.pathParameters['id'] ?? ''),
          artisanName: extra['name'] as String? ?? 'Artisan',
          artisanRole: extra['role'] as String? ?? 'Artisan indépendant',
        );
      }),

    // ── Artisan dashboard ─────────────────────────────────────────────────
    GoRoute(path: '/artisan/dashboard',
      builder: (_, __) => const ArtisanHomeScreen()),

    GoRoute(path: '/artisan/offers',
      builder: (_, __) => const ArtisanOffersScreen()),

    GoRoute(path: '/artisan/profile',
      builder: (_, __) => const ArtisanProfileScreen()),

    GoRoute(path: '/artisan/available-requests',
      builder: (_, __) => const ArtisanOffersScreen()),  // reuse offers tab for now

    GoRoute(path: '/artisan/request/:id',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ArtisanRequestDetailScreen(
          requestId:   int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          initialData: extra['request'] as AvailableRequest?,
        );
      }),
  ],
);
