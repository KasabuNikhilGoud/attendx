import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_loader.dart';

/// Central Supabase client initializer.
///
/// Phase 1: The app boots into [ensureInitialized] before runApp.
///
/// Credential resolution order:
///   1. --dart-define (compile-time override, useful for CI/production)
///   2. Bundled `.env` asset (loaded via [EnvLoader])
///   3. Neither present → offline demo mode (showcase build still works)
///
/// To run connected:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
/// or just fill `.env` and run `flutter run`.
class SupabaseService {
  SupabaseService._();

  static bool _ready = false;

  /// True when a real Supabase backend is connected.
  static bool get isReady => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  /// Initializes Supabase. Returns true on success, false on demo fallback.
  static Future<bool> ensureInitialized() async {
    try {
      await EnvLoader.load();

      // --dart-define wins when provided; otherwise read the .env asset.
      var url = String.fromEnvironment('SUPABASE_URL');
      var anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      if (url.isEmpty) url = EnvLoader.get('SUPABASE_URL');
      if (anonKey.isEmpty) anonKey = EnvLoader.get('SUPABASE_ANON_KEY');

      // Guard against empty/placeholder values → stay in demo mode.
      if (url.isEmpty ||
          anonKey.isEmpty ||
          url.contains('YOUR_PROJECT-ref') ||
          anonKey.contains('YOUR_ANON_KEY')) {
        _ready = false;
        return false;
      }

      await Supabase.initialize(url: url, anonKey: anonKey);
      _ready = true;
      return true;
    } catch (_) {
      // Any failure (bad config, network) → offline demo mode.
      _ready = false;
      return false;
    }
  }

  static GoTrueClient get auth => client.auth;

  /// The signed-in Supabase user, or null.
  static User? get currentUser => _ready ? auth.currentUser : null;
}
