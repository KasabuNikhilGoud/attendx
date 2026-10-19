import 'package:flutter/services.dart' show rootBundle;

/// Minimal .env loader (replaces flutter_dotenv).
///
/// flutter_dotenv fails to resolve on machines where the Windows username
/// contains spaces (a %20 path-encoding bug in its old languageVersion).
/// This loader reads the bundled `.env` asset directly via rootBundle and
/// parses `KEY=VALUE` lines — no external package, no path issues.
class EnvLoader {
  EnvLoader._();

  static final Map<String, String> _vars = <String, String>{};
  static bool _loaded = false;

  /// Loads and parses the bundled `.env` asset exactly once.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('.env');
      for (final line in raw.split('\n')) {
        final trimmed = line.trim();
        // Skip blanks and comments.
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eq = trimmed.indexOf('=');
        if (eq <= 0) continue;
        final key = trimmed.substring(0, eq).trim();
        var value = trimmed.substring(eq + 1).trim();
        // Strip optional surrounding quotes.
        if (value.length >= 2 &&
            ((value.startsWith('"') && value.endsWith('"')) ||
                (value.startsWith("'") && value.endsWith("'")))) {
          value = value.substring(1, value.length - 1);
        }
        _vars[key] = value;
      }
    } catch (_) {
      // Missing .env → leave map empty; caller falls back to demo mode.
    }
    _loaded = true;
  }

  /// Returns the value for [key], or an empty string when absent.
  static String get(String key) => _vars[key] ?? '';
}
