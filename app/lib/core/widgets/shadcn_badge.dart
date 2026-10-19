import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum ShadcnBadgeVariant {
  defaultVariant,
  secondary,
  outline,
  destructive,
  success,
  warning,
  info,
}

/// A minimalist, crisp Shadcn status badge with 1px hairline border
/// and soft tinted backgrounds.
class ShadcnBadge extends StatelessWidget {
  const ShadcnBadge({
    super.key,
    required this.label,
    this.variant = ShadcnBadgeVariant.defaultVariant,
    this.icon,
    this.customBg,
    this.customFg,
    this.customBorder,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    this.fontSize = 11.5,
  });

  final String label;
  final ShadcnBadgeVariant variant;
  final IconData? icon;
  final Color? customBg;
  final Color? customFg;
  final Color? customBorder;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case ShadcnBadgeVariant.defaultVariant:
        bg = AppColors.zinc900;
        fg = Colors.white;
        border = AppColors.zinc900;
        break;
      case ShadcnBadgeVariant.secondary:
        bg = AppColors.zinc100;
        fg = AppColors.zinc900;
        border = AppColors.zinc200;
        break;
      case ShadcnBadgeVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.zinc900;
        border = AppColors.zinc300;
        break;
      case ShadcnBadgeVariant.destructive:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        border = const Color(0xFFFECACA);
        break;
      case ShadcnBadgeVariant.success:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        border = const Color(0xFFA7F3D0);
        break;
      case ShadcnBadgeVariant.warning:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        border = const Color(0xFFFDE68A);
        break;
      case ShadcnBadgeVariant.info:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        border = const Color(0xFFBFDBFE);
        break;
    }

    if (customBg != null) bg = customBg!;
    if (customFg != null) fg = customFg!;
    if (customBorder != null) border = customBorder!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1.1,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
