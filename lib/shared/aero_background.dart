import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// True Windows Vista / 7 Aero background:
/// Rich royal-blue sky gradient with soft cloud-like radial highlights
/// and subtle animated light rays — exactly like the Vista "Aurora" wallpaper feel.
class AeroBackground extends StatefulWidget {
  final Color accentColor;
  final Widget child;

  const AeroBackground({
    super.key,
    required this.accentColor,
    required this.child,
  });

  @override
  State<AeroBackground> createState() => _AeroBackgroundState();
}

class _AeroBackgroundState extends State<AeroBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _AeroSkyPainter(
          progress: _controller.value,
          accentColor: widget.accentColor,
        ),
        child: widget.child,
      ),
    );
  }
}

class _AeroSkyPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _AeroSkyPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    // ── 1. Rich Vista blue sky gradient (top-to-bottom) ──────────
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF062B6E), // deep Aero blue top
          Color(0xFF1251A3), // mid Vista blue
          Color(0xFF2470B8), // lighter bottom
          Color(0xFF3A8AC4), // horizon haze
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // ── 2. Soft cloud-like aurora blobs (slow drift) ──────────────
    _drawAuroraBlob(
      canvas, size,
      Offset(
        size.width * (0.25 + math.sin(progress * math.pi * 2) * 0.08),
        size.height * (0.3  + math.cos(progress * math.pi * 2) * 0.05),
      ),
      const Color(0x255BA3D9),
      size.width * 0.55,
    );

    _drawAuroraBlob(
      canvas, size,
      Offset(
        size.width * (0.75 + math.cos(progress * math.pi * 2) * 0.07),
        size.height * (0.5  + math.sin(progress * math.pi * 2) * 0.06),
      ),
      const Color(0x1E4A90D9),
      size.width * 0.50,
    );

    _drawAuroraBlob(
      canvas, size,
      Offset(
        size.width * 0.5,
        size.height * (0.15 + math.sin(progress * math.pi * 2 + 1.2) * 0.04),
      ),
      const Color(0x1AFFFFFF),
      size.width * 0.40,
    );

    // ── 3. Accent color tint blob (project-specific) ──────────────
    _drawAuroraBlob(
      canvas, size,
      Offset(size.width * 0.85, size.height * 0.2),
      accentColor.withOpacity(0.06),
      size.width * 0.35,
    );

    // ── 4. Subtle Aero light rays from top-center ─────────────────
    _drawLightRays(canvas, size);

    // ── 5. Bottom reflection — characteristic Vista sheen ─────────
    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0x0AFFFFFF),
          const Color(0x15FFFFFF),
        ],
        stops: const [0.7, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      reflectionPaint,
    );
  }

  void _drawAuroraBlob(Canvas canvas, Size size, Offset center, Color color, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawLightRays(Canvas canvas, Size size) {
    final rayPaint = Paint()
      ..color = const Color(0x07FFFFFF)
      ..style = PaintingStyle.fill;

    final origin = Offset(size.width * 0.5, -size.height * 0.1);
    const rayCount = 8;
    const spreadAngle = math.pi * 0.7;

    for (int i = 0; i < rayCount; i++) {
      final angle = -math.pi / 2 - spreadAngle / 2 + (spreadAngle / (rayCount - 1)) * i;
      final rayLength = size.height * 1.6;
      final rayWidth = rayLength * 0.04;

      final path = Path();
      path.moveTo(origin.dx, origin.dy);
      path.lineTo(
        origin.dx + math.cos(angle - 0.02) * rayLength,
        origin.dy + math.sin(angle - 0.02) * rayLength,
      );
      path.lineTo(
        origin.dx + math.cos(angle + 0.02) * rayLength,
        origin.dy + math.sin(angle + 0.02) * rayLength,
      );
      path.close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(_AeroSkyPainter old) =>
      old.progress != progress || old.accentColor != accentColor;
}
