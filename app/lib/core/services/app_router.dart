import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/student/student_dashboard.dart';
import '../../features/faculty/faculty_dashboard.dart';
import '../../features/hod/hod_dashboard.dart';
import '../../features/admin/admin_dashboard.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = AuthService.currentUser;
      final isLoginPage = state.matchedLocation == '/login';

      if (user == null) {
        return isLoginPage ? null : '/login';
      }

      if (isLoginPage) {
        final role = await AuthService.getUserRole(user.id);
        return _roleRoute(role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/student', builder: (_, __) => const StudentDashboard()),
      GoRoute(path: '/faculty', builder: (_, __) => const FacultyDashboard()),
      GoRoute(path: '/hod', builder: (_, __) => const HodDashboard()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );

  static String _roleRoute(String? role) {
    switch (role) {
      case UserRole.student:
        return '/student';
      case UserRole.faculty:
        return '/faculty';
      case UserRole.hod:
        return '/hod';
      case UserRole.admin:
        return '/admin';
      default:
        return '/login';
    }
  }
}
