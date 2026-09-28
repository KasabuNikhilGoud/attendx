class AppConstants {
  // Replace with your Supabase project values
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static const String appName = 'AttendX';
  static const String appVersion = '1.0.0';
}

// User roles — must match the role column in profiles table
class UserRole {
  static const String student = 'student';
  static const String faculty = 'faculty';
  static const String hod = 'hod';
  static const String admin = 'admin';
}
