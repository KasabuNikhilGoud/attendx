import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/student/student_dashboard.dart';
import '../../features/faculty/faculty_dashboard.dart';
import '../../features/hod/hod_dashboard.dart';
import '../../features/admin/admin_dashboard.dart';

class AppRouter {
  /// Routes accessible without a session.
  static const Set<String> _guestRoutes = {
    '/splash',
    '/onboarding',
    '/login',
    '/signup',
  };

  /// Builds a fluid Apple-style slide & fade page transition.
  static Page<dynamic> _buildApplePage(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        final fade = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(slide),
          child: FadeTransition(
            opacity: animation.drive(fade),
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isGuestRoute = _guestRoutes.contains(path);

      if (!AuthService.isLoggedIn) {
        return isGuestRoute ? null : '/splash';
      }

      if (isGuestRoute) {
        return AuthService.routeForRole(AuthService.demoRole);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const SignUpScreen()),
      ),
      GoRoute(
        path: '/student',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const StudentDashboard()),
      ),
      GoRoute(
        path: '/faculty',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const FacultyDashboard()),
      ),
      GoRoute(
        path: '/hod',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const HodDashboard()),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) =>
            _buildApplePage(context, state, const AdminDashboard()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
