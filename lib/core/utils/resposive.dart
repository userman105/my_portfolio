import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 960;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960;

  static bool isTwoColumn(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960;

  static double hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return 20;
    if (w < 960) return 28;
    return 32;
  }

  static double heroFontSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 400) return 36;
    if (w < 600) return 44;
    if (w < 960) return 58;
    return 76;
  }

  static double carouselHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return 260;
    if (w < 960) return 380;
    return 540;
  }

  static double caseCarouselHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return 280;
    if (w < 960) return 400;
    return 520;
  }
}
