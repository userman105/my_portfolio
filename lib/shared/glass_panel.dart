import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../core/utils/blur.dart';

/// True Windows Vista / 7 Aero Glass panel.
///
/// The real look has:
///  • Strong backdrop blur (40–60px) — blurs the blue sky behind it
///  • Milky white-blue fill (~15–25% white opacity) — NOT dark
///  • Bright white top-edge highlight (the "shine strip") — signature Aero detail
///  • Subtle inner blue shadow at the bottom
///  • Colored outer glow matching the accent
///  • Rounded corners (Vista used ~8–12px)
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? glowColor;
  final bool showShine;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 40,
    this.width,
    this.height,
    this.onTap,
    this.glowColor,
    this.showShine = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(10);

    Widget panel = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, blur), sigmaY: AeroBlur.of(context, blur)),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // Milky blue-white fill — the core of Aero glass
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x33FFFFFF), // brighter top-left catch
                Color(0x1AFFFFFF), // mid fill
                Color(0x14FFFFFF), // slightly less opaque bottom-right
                Color(0x0F4A90D9), // blue tint at bottom
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: radius,
            border: Border.all(
              color: AppColors.glassBorderSide,
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              // Top shine strip — the most iconic Aero detail
              if (showShine)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: radius.topLeft,
                      topRight: radius.topRight,
                    ),
                    child: Container(
                      height: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0xCCFFFFFF),
                            Color(0xFFFFFFFF),
                            Color(0xCCFFFFFF),
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              // Inner bottom blue shadow (reflected color)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0x0A1251A3),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: radius.bottomLeft,
                      bottomRight: radius.bottomRight,
                    ),
                  ),
                ),
              ),
              // Actual content
              Padding(
                padding: padding ?? const EdgeInsets.all(24),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    // Outer glow + drop shadow
    panel = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // Aero drop shadow — blue-tinted, soft
          BoxShadow(
            color: const Color(0x33000044),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          // Accent color glow (subtle)
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: -6,
            ),
        ],
      ),
      child: panel,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: panel);
    }
    return panel;
  }
}

class GlassDivider extends StatelessWidget {
  final Color? color;
  const GlassDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color ?? AppColors.glassBorder.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
