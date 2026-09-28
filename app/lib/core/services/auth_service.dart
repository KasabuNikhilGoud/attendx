import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

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

  static User? get currentUser => _demoMode ? null : _supabase.auth.currentUser;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    if (_demoUsers.containsKey(email.toLowerCase())) {
      final user = _demoUsers[email.toLowerCase()]!;
      if (user['password'] == password) {
        _demoMode = true;
        _demoProfile = {
          'id': 'demo_${user['role']}',
          'email': email.toLowerCase(),
          'full_name': user['full_name'],
          'role': user['role'],
        };
        return {'success': true, 'role': user['role']};
      }
    }

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) return {'success': false, 'message': 'Login failed'};
      final role = await getUserRole(res.user!.id);
      return {'success': true, 'role': role};
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  static Future<void> logout() async {
    _demoMode = false;
    _demoProfile = null;
    await _supabase.auth.signOut();
  }

  static Future<String?> getUserRole(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    return data['role'] as String?;
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    if (_demoMode) return _demoProfile;
    final user = currentUser;
    if (user == null) return null;
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
  }

  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
