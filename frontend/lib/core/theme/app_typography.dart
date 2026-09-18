import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Brand Logo Font
  static TextStyle brandLogo({double fontSize = 24, Color color = AppColors.espresso}) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 3.5,
      color: color,
    );
  }

  // Major Headings Display (Hero, Section Titles)
  static TextStyle displayLarge({Color color = AppColors.espresso}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle displayMedium({Color color = AppColors.espresso}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle headingLarge({Color color = AppColors.espresso}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: color,
    );
  }

  static TextStyle headingMedium({Color color = AppColors.espresso}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle headingSmall({Color color = AppColors.espresso}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Body UI Text
  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle bodySmall({Color color = AppColors.textMuted}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color,
    );
  }

  // Price Typography
  static TextStyle priceLarge({Color color = AppColors.espresso}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle priceMedium({Color color = AppColors.espresso}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle priceStrikeThrough({Color color = AppColors.textMuted}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.lineThrough,
      color: color,
    );
  }

  // Button Typography
  static TextStyle buttonText({Color color = Colors.white}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color,
    );
  }
}
