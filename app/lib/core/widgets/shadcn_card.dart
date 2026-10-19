import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'apple_pressable.dart';

/// A minimalist, sleek Shadcn card component for Flutter with 1px hairline border,
/// soft Apple elevation, and optional tactile spring press feedback.
class ShadcnCard extends StatelessWidget {
  const ShadcnCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.trailing,
    this.footer,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.onTap,
    this.borderWidth = 1.0,
    this.boxShadow,
  });

  final Widget child;
  final String? title;
  final String? description;
  final Widget? trailing;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? AppColors.border;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: effectiveBorder, width: borderWidth),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || trailing != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                                letterSpacing: -0.2,
                              ),
                            ),
                          if (description != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              description!,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              child,
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.sm),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      return ApplePressable(
        onTap: onTap,
        borderRadius: borderRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
