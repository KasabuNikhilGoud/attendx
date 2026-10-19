import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AttendX design tokens — clean, simple, Apple-like.
/// Palette: red (accent) · black/near-black (text) · grays (secondary) · white (surfaces).
class AppColors {
  // ---- Accent: red ----
  static const primary = Color(0xFFE53935);
  static const primaryRed = Color(0xFFE53935);
  static const primaryOrange = Color(0xFFFF6B35);
  static const redDanger = Color(0xFFD32F2F);
  static const redAbsent = Color(0xFFEF5350);
  static const warning = Color(0xFFFF9F0A);
  static const gold = Color(0xFFFFD60A);
  static const goldDark = Color(0xFFDAA520);

  // ---- Status ----
  static const greenSuccess = Color(0xFF34C759);
  static const greenPresent = Color(0xFF34C759);
  static const blueInfo = Color(0xFF007AFF);

  // ---- Neutrals: Shadcn Zinc palette ----
  static const zinc950 = Color(0xFF09090B);
  static const zinc900 = Color(0xFF18181B);
  static const zinc800 = Color(0xFF27272A);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc600 = Color(0xFF52525B);
  static const zinc500 = Color(0xFF71717A);
  static const zinc400 = Color(0xFFA1A1AA);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc50 = Color(0xFFFAFAFA);

  // ---- Neutrals: black / grays / white ----
  static const black = Color(0xFF09090B);
  static const darkText = Color(0xFF09090B);
  static const textPrimary = Color(0xFF09090B);
  static const textSecondary = Color(0xFF71717A);
  static const neutralGray = Color(0xFFA1A1AA);
  static const grayLight = Color(0xFFD4D4D8);
  static const border = Color(0xFFE4E4E7);
  static const divider = Color(0xFFF4F4F5);
  static const surface = Color(0xFFF8FAFC);
  static const nearWhite = Color(0xFFFAFAFA);
  static const background = Color(0xFFFFFFFF);

  // Legacy aliases kept for existing screens.
  static const tableBorder = Color(0xFFE4E4E7);
  static const rowSeparator = Color(0xFFF4F4F5);
  static const lightGreen = Color(0xFFECFDF5);
  static const presentPill = Color(0xFFECFDF5);
  static const absentPill = Color(0xFFFEF2F2);
}

/// Apple-like motion curves
class AppCurves {
  static const Curve spring = Cubic(0.25, 1.0, 0.5, 1.0);
  static const Curve springBouncy = Cubic(0.34, 1.45, 0.64, 1.0);
  static const Curve easeOutApple = Cubic(0.16, 1.0, 0.3, 1.0);
}


class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: AppColors.background,
        splashFactory: InkSparkle.splashFactory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
          surface: AppColors.background,
          error: AppColors.redDanger,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.textPrimary,
          toolbarHeight: 64,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryRed,
            textStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          hintStyle: GoogleFonts.inter(
            color: AppColors.grayLight,
            fontSize: 13,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkText,
          contentTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
}

class AppShadows {
  /// Soft Apple-like card shadow.
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get navBar => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];

  static List<BoxShadow> get statCard => card;

  static List<BoxShadow> get featureCard => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get table => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppBorderRadius {
  static const BorderRadius xs = BorderRadius.all(Radius.circular(6));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(14));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(24));
  static const BorderRadius glass = BorderRadius.all(Radius.circular(28));
  static const BorderRadius button = BorderRadius.all(Radius.circular(14));
  static const BorderRadius fullPill = BorderRadius.all(Radius.circular(100));
}

class AppGradients {
  static const LinearGradient navActive = LinearGradient(
    colors: [AppColors.primaryRed, AppColors.primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient navInactive = LinearGradient(
    colors: [
      Colors.grey.withValues(alpha: 0.08),
      Colors.grey.withValues(alpha: 0.04),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Red → near-black. Used for headline accents.
  static const LinearGradient attendanceHeader = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFF1C1C1E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient sectionAccent(Color color) => LinearGradient(
        colors: [color, color.withValues(alpha: 0.3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient sectionBg(Color color) => LinearGradient(
        colors: [color.withValues(alpha: 0.25), Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient featureCard(Color start, Color end) => LinearGradient(
        colors: [start, end],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static const LinearGradient goldBadge = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFC107), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bottomFooter = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFF1C1C1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> featureCardColors = [
    Color(0xFFFDEBEA),
    Color(0xFFE8F8EC),
    Color(0xFFF2F2F7),
    Color(0xFFFFF4E5),
    Color(0xFFF9F9FB),
  ];
}

class AppTypography {
  static const double size7 = 7.5;
  static const double size9 = 9;
  static const double size10 = 10;
  static const double size11 = 11;
  static const double size12 = 12;
  static const double size13 = 13;
  static const double size14 = 14;
  static const double size15 = 15;
  static const double size16 = 16;
  static const double size17 = 17;
  static const double size18 = 18;
  static const double size20 = 20;
  static const double size22 = 22;
  static const double size24 = 24;
  static const double size26 = 26;
  static const double size28 = 28;
  static const double size34 = 34;
  static const double size42 = 42;
  static const double size48 = 48;
  static const double size56 = 56;
  static const double size85 = 85;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 28;
  static const double form = 32;
}
