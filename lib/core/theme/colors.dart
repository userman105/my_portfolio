import 'package:flutter/material.dart';

class AppColors {
  // ── True Aero Base ─────────────────────────────────────────────
  // Vista/7 desktop was a rich royal blue gradient, NOT black
  static const Color aeroSkyDeep   = Color(0xFF062B6E); // deep Aero blue
  static const Color aeroSkyMid    = Color(0xFF1A5FB4); // mid Vista blue
  static const Color aeroSkyLight  = Color(0xFF3B82C4); // lighter Vista blue
  static const Color aeroSkyHaze   = Color(0xFF6BAED6); // the washed-out haze

  // ── Glass surfaces (the real Aero look) ────────────────────────
  // Aero glass = milky blue-white with strong blur, NOT dark panels
  static const Color glassPrimary       = Color(0x26FFFFFF); // main panel fill
  static const Color glassStrong        = Color(0x40FFFFFF); // hovered / active
  static const Color glassBorder        = Color(0x80FFFFFF); // bright top edge highlight
  static const Color glassBorderSide    = Color(0x33FFFFFF); // side/bottom border
  static const Color glassInnerShadow   = Color(0x1A000066); // inner blue tint
  static const Color glassReflection    = Color(0x59FFFFFF); // top-edge shine strip
  static const Color glassButtonFill    = Color(0x4DFFFFFF); // button glass fill
  static const Color glassButtonBorder  = Color(0xB3FFFFFF); // button bright rim

  // ── Aero accent colors ─────────────────────────────────────────
  // Vista taskbar glow / hover glow — electric blue-white
  static const Color aeroGlowBlue   = Color(0xFF74C0FC); // hover glow blue
  static const Color aeroGlowWhite  = Color(0xCCFFFFFF); // text/icon white glow
  static const Color aeroActiveBlue = Color(0xFF4DA6FF); // active element blue
  static const Color chronicareAccent = Color(0xFF74C0FC);
  static const Color chronicareGlow   = Color(0x6674C0FC);

  static const Color cdlAccent = Color(0xFF34D399);
  static const Color cdlGlow   = Color(0x6634D399);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textMuted     = Color(0x99FFFFFF);
  static const Color textShadow    = Color(0x66000033);

  static const Color skyTop    = Color(0xFF062B6E);
  static const Color skyMid    = Color(0xFF1251A3);
  static const Color skyBottom = Color(0xFF2470B8);

  static const Color chipFlutter = Color(0xFF0553B1);
  static const Color chipFastAPI = Color(0xFF059669);
  static const Color chipNode    = Color(0xFF166534);
  static const Color chipMongo   = Color(0xFF14532D);
  static const Color chipPrisma  = Color(0xFF1E3A5F);
  static const Color chipBloc    = Color(0xFF4C1D95);
  static const Color chipDio     = Color(0xFF881337);
  static const Color chipPDF     = Color(0xFF7F1D1D);
  static const Color chipFirebase= Color(0xFF92400E);
  static const Color tetrisAccent = Color(0xFFDFC283);
  static const Color tetrisFrom = Color(0xFFACAF6D);
  static const Color tetrisTo = Color(0xFF8E8B5E);
  static Color get cyanAccent => Colors.cyanAccent;
  static Color get chronicareFrom => Colors.green;
  static Color get chronicareTo => Colors.greenAccent;
  static Color get emeraldAccent => Colors.green;
  static Color get cdlFrom => Colors.lightBlueAccent;
  static Color get cdlTo => Colors.blue;
}
