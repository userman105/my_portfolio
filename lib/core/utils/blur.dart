import 'package:flutter/widgets.dart';

import 'resposive.dart';

/// Gaussian blur is the single most expensive effect in this app (14 panels).
/// Phones can't afford sigma 40, and on a small screen the difference between
/// sigma 12 and sigma 40 is barely visible.
class AeroBlur {
  AeroBlur._();

  static const double mobileMax = 12;

  static double of(BuildContext context, double sigma) =>
      Responsive.isMobile(context) && sigma > mobileMax ? mobileMax : sigma;
}
