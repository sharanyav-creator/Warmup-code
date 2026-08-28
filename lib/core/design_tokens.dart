import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's single design system, lifted from the Figma onboarding and
/// main-app frames. Shared by onboarding and the Home/Progress/Goals/Profile
/// tabs so every screen draws from one source of truth.
class OnboardingColors {
  OnboardingColors._();

  static const Color maroonBackground = Color(0xFF580229);
  static const Color orange = Color(0xFFF47E38);
  static const Color orangeSkipBackground = Color(0x33F47E38); // 20% opacity
  static const Color creamBackground = Color(0xFFF5F1EC);
  static const Color creamSubtext = Color(0xFF474747);
  static const Color burgundy = Color(0xFFB22452);
  static const Color burgundySoftBackground = Color(0x33B22452); // 20% opacity
  static const Color eyebrowGray = Color(0xFF808080);

  // Main-app tab tokens
  static const Color navInactive = Color(0xFFA6B7C7);
  static const Color progressActiveLabel = Color(0xFF3D001C);
  static const Color avgPaceGreen = Color(0xFFCCD337);
  static const Color tryFrameworkOrange = Color(0xFFFF5A36);
  static const Color weekBlockFilled = Color(0xFF580229);
  static const Color weekBlockEmpty = Color(0xFFECECEC);
  static const Color textDark1f = Color(0xFF1F1F1F);
  static const Color textGray444 = Color(0xFF444444);

  // Calendar day-quality buckets
  static const Color calendarNoPractice = Color(0xFFEDE7DF);
  static const Color calendarPracticed = Color(0xFFF47E38);
  static const Color calendarSolid = Color(0xFFE8967A);
  static const Color calendarStrong = Color(0xFFB5301F);
}

class OnboardingText {
  OnboardingText._();

  static TextStyle headline({required Color color, double fontSize = 32}) =>
      GoogleFonts.sora(fontSize: fontSize, fontWeight: FontWeight.w600, color: color, height: 1.2);

  static TextStyle body({required Color color}) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: color, height: 1.4);

  static TextStyle buttonLabel({required Color color}) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: color);

  static TextStyle eyebrow() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: OnboardingColors.eyebrowGray,
        letterSpacing: 0.5,
      );

  static TextStyle statLabel({required Color color}) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color);
}
