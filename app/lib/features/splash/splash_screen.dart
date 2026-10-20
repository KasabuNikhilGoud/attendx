import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_env.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shadcn_badge.dart';

/// Snappy, Apple-style brand splash on cold start.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Snappy display duration (1.4s) instead of sluggish 4.0s.
  static const Duration displayDuration = Duration(milliseconds: 1400);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final String? _envLabel;
  Timer? _timer;

  /// Which non-production world this build is touching, for the badge:
  /// TEST DATABASE / STAGING / DEMO MODE. Hidden on production.
  String? _resolveEnvLabel() {
    if (!SupabaseService.isReady) return 'DEMO MODE';
    return AppEnvConfig.badgeLabel;
  }

  @override
  void initState() {
    super.initState();
    _envLabel = _resolveEnvLabel();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.springBouncy),
    );
    _controller.forward();

    _timer = Timer(SplashScreen.displayDuration, () {
      if (mounted && context.mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withValues(alpha: 0.28),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'AttendX',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const ShadcnBadge(
                      label: 'ERP Attendance System',
                      variant: ShadcnBadgeVariant.secondary,
                      fontSize: 11.5,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    if (_envLabel != null) ...[
                      const SizedBox(height: 6),
                      ShadcnBadge(
                        label: _envLabel!,
                        variant: switch (_envLabel) {
                          'STAGING' => ShadcnBadgeVariant.info,
                          'DEMO MODE' => ShadcnBadgeVariant.outline,
                          _ => ShadcnBadgeVariant.warning,
                        },
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 56),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: SplashScreen.displayDuration,
                curve: Curves.easeInOutCubic,
                builder: (context, value, _) => Container(
                  width: 90 * value,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
