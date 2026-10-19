import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'apple_pressable.dart';

class FrostedNavItem {
  const FrostedNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

/// An Apple-style frosted glass bottom navigation bar with a smooth sliding
/// pill indicator, haptic feedback, and subtle tactile scaling.
class FrostedNavBar extends StatelessWidget {
  const FrostedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.blur = 24.0,
  });

  final List<FrostedNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            color: Colors.white.withValues(alpha: 0.85),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: Center(
                          heightFactor: 1,
                          child: _buildItem(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = items[index];
    final isActive = currentIndex == index;

    return ApplePressable(
      onTap: () {
        if (!isActive) {
          HapticFeedback.selectionClick();
          onTap(index);
        }
      },
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: AppCurves.spring,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryRed.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? (item.activeIcon ?? item.icon) : item.icon,
              size: 20,
              color: isActive ? AppColors.primaryRed : AppColors.zinc500,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: AppCurves.spring,
              alignment: Alignment.centerLeft,
              child: isActive
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
