import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/utils/blur.dart';

class ProjectTransitionDivider extends StatelessWidget {
  final Color fromAccent;
  final Color toAccent;
  final String nextProjectTitle;

  const ProjectTransitionDivider({
    super.key,
    required this.fromAccent,
    required this.toAccent,
    required this.nextProjectTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 30), sigmaY: AeroBlur.of(context, 30)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  fromAccent.withOpacity(0.10),
                  Colors.white.withOpacity(0.08),
                  toAccent.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.55), width: 1),
                left: BorderSide(color: Colors.white.withOpacity(0.20), width: 0.5),
                right: BorderSide(color: Colors.white.withOpacity(0.20), width: 0.5),
                bottom: BorderSide(color: Colors.white.withOpacity(0.10), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // From accent dot
                _glowDot(fromAccent),
                const SizedBox(width: 12),
                // Gradient line
                Expanded(
                  child: Container(
                    height: 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fromAccent.withOpacity(0.6),
                          Colors.white.withOpacity(0.3),
                          toAccent.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'UP NEXT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  nextProjectTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: toAccent.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: toAccent.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          toAccent.withOpacity(0.6),
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _glowDot(toAccent),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _glowDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.7), blurRadius: 8),
        ],
      ),
    );
  }
}
