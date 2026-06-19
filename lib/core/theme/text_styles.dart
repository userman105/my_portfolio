import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// True Aero typography:
// Segoe UI was the Vista/7 system font — clean, slightly rounded, very readable on glass.
// We use Inter as the closest Google Fonts equivalent (same DNA).
// Text on glass gets a subtle blue-black drop shadow for legibility — exactly like Vista.

class AppTextStyles {
  static Shadow get _aeroShadow => const Shadow(
    color: Color(0x99000033),
    offset: Offset(0, 1),
    blurRadius: 4,
  );

  static Shadow get _aeroShadowStrong => const Shadow(
    color: Color(0xCC000044),
    offset: Offset(0, 2),
    blurRadius: 8,
  );

  static TextStyle get displayHero => GoogleFonts.inter(
    fontSize: 64,
    fontWeight: FontWeight.w300, // Vista used Light weight for big headings
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.05,
    shadows: [_aeroShadowStrong, _aeroShadowStrong],
  );

  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: -1,
    height: 1.1,
    shadows: [_aeroShadowStrong],
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    shadows: [_aeroShadow],
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    shadows: [_aeroShadow],
  );

  static TextStyle get sectionLabel => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.aeroGlowBlue,
    letterSpacing: 3.5,
    shadows: [_aeroShadow],
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
    shadows: [_aeroShadow],
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.65,
    shadows: [_aeroShadow],
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.textMuted,
    shadows: [_aeroShadow],
  );

  static TextStyle get chipLabel => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static TextStyle get featureItem => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
    shadows: [_aeroShadow],
  );

  static TextStyle get caseStudyHeading => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    shadows: [_aeroShadow],
  );

  static TextStyle get navLink => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    shadows: [_aeroShadow],
  );
}
