import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Smooth animated count-up for percentages or numbers with Apple ease-out cubic curve.
class AnimatedMetricCounter extends StatelessWidget {
  const AnimatedMetricCounter({
    super.key,
    required this.value,
    this.suffix = '%',
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 950),
    this.curve = Curves.easeOutCubic,
    this.decimals = 1,
  });

  final double value;
  final String suffix;
  final String prefix;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      color: AppColors.darkText,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, current, child) {
        final formatted = decimals == 0
            ? current.toInt().toString()
            : current.toStringAsFixed(decimals);
        return Text(
          '$prefix$formatted$suffix',
          style: style ?? defaultStyle,
        );
      },
    );
  }
}

/// A staggered fade-and-slide entrance wrapper for Apple-style fluidity.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 480),
    this.offsetY = 18.0,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    final totalDelay = delay * index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + totalDelay,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        // Compute clamped progress after delay
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1.0 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
