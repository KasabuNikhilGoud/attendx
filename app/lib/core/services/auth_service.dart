import '../constants/app_constants.dart';

/// Hardcoded demo authentication for the offline showcase build.
///
/// The app runs without any backend/database: all users, roles and data are
/// mock/hardcoded so the full UI can be reviewed end-to-end.
class AuthService {
  static bool _demoMode = false;
  static Map<String, dynamic>? _demoProfile;

  static bool get isDemoMode => _demoMode;

  static final Map<String, Map<String, dynamic>> _demoUsers = {
    'admin@attendx.com': {
      'role': 'admin',
      'full_name': 'Admin User',
      'password': 'admin123',
    },
    'hod@attendx.com': {
      'role': 'hod',
      'full_name': 'Dr. HOD Patel',
      'password': 'hod123',
    },
    'faculty@attendx.com': {
      'role': 'faculty',
      'full_name': 'Prof. Sharma',
      'password': 'faculty123',
    },
    'student@attendx.com': {
      'role': 'student',
      'full_name': 'Rahul Student',
      'password': 'student123',
    },
  };

  /// True when a demo (mock data) session is active.
  static bool get isLoggedIn => _demoMode;

  /// Role of the active demo user, or null when not logged in.
  static String? get demoRole => _demoProfile?['role'] as String?;

  /// Signs in against the hardcoded demo accounts.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final user = _demoUsers[email.toLowerCase()];
    if (user != null && user['password'] == password) {
      _demoMode = true;
      _demoProfile = {
        'id': 'demo_${user['role']}',
        'email': email.toLowerCase(),
        'full_name': user['full_name'],
        'role': user['role'],
      };
      return {'success': true, 'role': user['role']};
    }
    return {
      'success': false,
      'message': 'Invalid credentials. Use one of the demo accounts.',
    };
  }

  static Future<void> logout() async {
    _demoMode = false;
    _demoProfile = null;
  }

  /// Creates an in-memory demo account and signs in.
  static Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final key = email.toLowerCase();
    if (_demoUsers.containsKey(key)) {
      return {
        'success': false,
        'message': 'An account with this email already exists.',
      };
    }
    _demoUsers[key] = {
      'role': role,
      'full_name': fullName,
      'password': password,
    };
    _demoMode = true;
    _demoProfile = {
      'id': 'demo_$role',
      'email': key,
      'full_name': fullName,
      'role': role,
    };
    return {'success': true, 'role': role};
  }

  /// Route for a role's home dashboard.
  static String routeForRole(String? role) {
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

  /// Returns the active demo profile, or null when logged out.
  static Future<Map<String, dynamic>?> getProfile() async {
    return _demoProfile;
  }
}
