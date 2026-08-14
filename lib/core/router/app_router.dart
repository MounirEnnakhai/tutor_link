import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/user_management_screen.dart';
import '../../presentation/screens/admin/verification_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/onboarding/student_onboarding_screen.dart';
import '../../presentation/screens/onboarding/tutor_onboarding_screen.dart';
import '../../presentation/screens/student/favorites_screen.dart';
import '../../presentation/screens/student/home_screen.dart';
import '../../presentation/screens/student/map_screen.dart';
import '../../presentation/screens/student/search_screen.dart';
import '../../presentation/screens/student/student_profile_screen.dart';
import '../../presentation/screens/student/tutor_profile_screen.dart';
import '../../presentation/screens/student/write_review_screen.dart';
import '../../presentation/screens/student/create_request_screen.dart';
import '../../presentation/screens/student/my_requests_screen.dart';
import '../../presentation/screens/tutor/create_offer_screen.dart';
import '../../presentation/screens/tutor/manage_offers_screen.dart';
import '../../presentation/screens/tutor/tutor_dashboard_screen.dart';
import '../../presentation/screens/tutor/tutor_profile_edit_screen.dart';
import '../../presentation/screens/tutor/offer_detail_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Onboarding
  static const String studentOnboarding = '/onboarding/student';
  static const String tutorOnboarding = '/onboarding/tutor';

  // Student
  static const String studentHome = '/student/home';
  static const String search = '/student/search';
  static const String map = '/student/map';
  static const String favorites = '/student/favorites';
  static const String studentProfile = '/student/profile';
  static const String tutorProfile = '/tutor/:tutorId';
  static const String writeReview = '/review/write/:tutorId';
  static const String offerDetail = '/offer/:offerId';
  static const String createRequest = '/student/create-request';
  static const String myRequests = '/student/my-requests';

  // Tutor
  static const String tutorDashboard = '/tutor-dashboard';
  static const String tutorProfileEdit = '/tutor/profile/edit';
  static const String manageOffers = '/tutor/offers';
  static const String createOffer = '/tutor/offers/create';

  // Admin
  static const String adminDashboard = '/admin';
  static const String userManagement = '/admin/users';
  static const String verification = '/admin/verification';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.valueOrNull;
      final isAuthenticated = user != null;
      final loc = state.matchedLocation;

      if (isLoading) return null;

      // Always allow splash
      if (loc == AppRoutes.splash) return null;

      // Not logged in → go to login
      final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.register;
      if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
      if (isAuthenticated && isAuthRoute) {
        return _homeForUser(user);
      }

      // Logged in but profile not complete → onboarding
      final isOnboarding = loc == AppRoutes.studentOnboarding ||
          loc == AppRoutes.tutorOnboarding;

      if (isAuthenticated && !user.isProfileComplete && !isOnboarding) {
        if (user.isAdmin) return null; // admins skip onboarding
        return user.isStudent
            ? AppRoutes.studentOnboarding
            : AppRoutes.tutorOnboarding;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const RegisterScreen(),
        ),
      ),

      // ─── Onboarding ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentOnboarding,
        name: 'studentOnboarding',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const StudentOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tutorOnboarding,
        name: 'tutorOnboarding',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const TutorOnboardingScreen(),
        ),
      ),

      // ─── Student Routes ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentHome,
        name: 'studentHome',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) {
          final subject = state.uri.queryParameters['subject'];
          return SearchScreen(initialSubject: subject);
        },
      ),
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        name: 'studentProfile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        path: '/tutor/:tutorId',
        name: 'tutorProfile',
        builder: (context, state) {
          final tutorId = state.pathParameters['tutorId']!;
          return TutorProfileScreen(tutorId: tutorId);
        },
      ),
      GoRoute(
        path: '/review/write/:tutorId',
        name: 'writeReview',
        builder: (context, state) {
          final tutorId = state.pathParameters['tutorId']!;
          return WriteReviewScreen(tutorId: tutorId);
        },
      ),
      GoRoute(
        path: '/offer/:offerId',
        name: 'offerDetail',
        builder: (context, state) {
          final offerId = state.pathParameters['offerId']!;
          return OfferDetailScreen(offerId: offerId);
        },
      ),
      GoRoute(
        path: AppRoutes.createRequest,
        name: 'createRequest',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const CreateRequestScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.myRequests,
        name: 'myRequests',
        builder: (context, state) => const MyRequestsScreen(),
      ),

      // ─── Tutor Routes ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.tutorDashboard,
        name: 'tutorDashboard',
        builder: (context, state) => const TutorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.tutorProfileEdit,
        name: 'tutorProfileEdit',
        builder: (context, state) => const TutorProfileEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageOffers,
        name: 'manageOffers',
        builder: (context, state) => const ManageOffersScreen(),
      ),
      GoRoute(
        path: AppRoutes.createOffer,
        name: 'createOffer',
        builder: (context, state) {
          final offerId = state.uri.queryParameters['offerId'];
          return CreateOfferScreen(editOfferId: offerId);
        },
      ),

      // ─── Admin Routes ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.userManagement,
        name: 'userManagement',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.verification,
        name: 'verification',
        builder: (context, state) => const VerificationScreen(),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

String _homeForUser(UserEntity user) {
  if (!user.isProfileComplete && !user.isAdmin) {
    return user.isStudent
        ? AppRoutes.studentOnboarding
        : AppRoutes.tutorOnboarding;
  }
  switch (user.role) {
    case UserRole.student: return AppRoutes.studentHome;
    case UserRole.tutor: return AppRoutes.tutorDashboard;
    case UserRole.admin: return AppRoutes.adminDashboard;
  }
}

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = const Offset(1.0, 0.0);
      const end = Offset.zero;
      final curve = CurveTween(curve: Curves.easeInOut);
      final tween = Tween(begin: begin, end: end).chain(curve);
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.studentHome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}