import 'env_loader.dart';

/// Which world this build talks to.
///
/// AttendX ships ONE codebase that runs against three isolated Supabase
/// projects (see docs/environments.md):
///   - test       → `attendx-test`     (fake users + dummy data, freely breakable)
///   - staging    → `attendx-staging`  (complete app, DB schema only, no users)
///   - production → `attendx-prod`     (real users, real data)
///
enum AppEnv { test, staging, production, demo }

/// Resolves and exposes the current environment.
///
/// Resolution order:
///   1. Compile-time override: `--dart-define=APP_ENV=test`
///      (or `--dart-define-from-file=.env.test`) — used by CI and flavor runs.
///   2. `APP_ENV` line of the bundled `.env` asset (local dev default).
///   3. Falls back to [AppEnv.test] so any accidental build always shows the
///      TEST badge instead of silently impersonating production.
class AppEnvConfig {
  AppEnvConfig._();

  static AppEnv get current => _resolve();

  /// True only for real production builds (no badge is shown then).
  static bool get isProduction => current == AppEnv.production;

  /// Badge label shown on the splash for non-production connections.
  /// `SupabaseService.isReady == false` (offline demo) is handled by the
  /// caller, which overrides this with a DEMO label.
  static String? get badgeLabel => switch (current) {
        AppEnv.test => 'TEST DATABASE',
        AppEnv.staging => 'STAGING',
        AppEnv.production => null,
        AppEnv.demo => null,
      };

  static AppEnv _resolve() {
    final define = String.fromEnvironment('APP_ENV').trim().toLowerCase();
    final raw = define.isNotEmpty
        ? define
        : EnvLoader.get('APP_ENV').trim().toLowerCase();
    switch (raw) {
      case 'production':
      case 'prod':
        return AppEnv.production;
      case 'staging':
      case 'main':
        return AppEnv.staging;
      case 'test':
      case 'dev':
      default:
        return AppEnv.test;
    }
  }
}
