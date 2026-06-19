import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get aero => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.aeroSkyDeep,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.chronicareAccent,
      secondary: AppColors.cdlAccent,
      surface: Color(0x33FFFFFF),
      background: AppColors.aeroSkyDeep,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
  );
}
