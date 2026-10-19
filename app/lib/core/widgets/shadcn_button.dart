import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'apple_pressable.dart';

enum ShadcnButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  brand,
}

enum ShadcnButtonSize {
  sm,
  md,
  lg,
}

/// A modern Shadcn button styled for Flutter with Apple spring physics,
/// clean borders, and haptics.
class ShadcnButton extends StatelessWidget {
  const ShadcnButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ShadcnButtonVariant.primary,
    this.size = ShadcnButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case ShadcnButtonVariant.primary:
        bg = AppColors.zinc900;
        fg = Colors.white;
        border = AppColors.zinc900;
        break;
      case ShadcnButtonVariant.brand:
        bg = AppColors.primaryRed;
        fg = Colors.white;
        border = AppColors.primaryRed;
        break;
      case ShadcnButtonVariant.secondary:
        bg = AppColors.zinc100;
        fg = AppColors.zinc900;
        border = AppColors.zinc200;
        break;
      case ShadcnButtonVariant.outline:
        bg = Colors.white;
        fg = AppColors.zinc900;
        border = AppColors.zinc300;
        break;
      case ShadcnButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.zinc900;
        border = Colors.transparent;
        break;
      case ShadcnButtonVariant.destructive:
        bg = AppColors.redDanger;
        fg = Colors.white;
        border = AppColors.redDanger;
        break;
    }

    double height;
    EdgeInsets padding;
    double fontSize;
    double iconSize;

    switch (size) {
      case ShadcnButtonSize.sm:
        height = 36;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        fontSize = 12.5;
        iconSize = 15;
        break;
      case ShadcnButtonSize.md:
        height = 46;
        padding = const EdgeInsets.symmetric(horizontal: 18);
        fontSize = 14;
        iconSize = 18;
        break;
      case ShadcnButtonSize.lg:
        height = 54;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        fontSize = 15.5;
        iconSize = 20;
        break;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onPressed == null ? border.withValues(alpha: 0.5) : border,
          width: 1,
        ),
        boxShadow: variant == ShadcnButtonVariant.ghost || onPressed == null
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: content,
    );

    return ApplePressable(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: fullWidth ? SizedBox(width: double.infinity, child: container) : container,
    );
  }
}
