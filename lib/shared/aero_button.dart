import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

/// True Aero glass button — milky white glass with bright rim,
/// top shine strip, and a colored glow on hover. Exactly like
/// Vista/7 taskbar buttons and dialog actions.
class AeroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool primary;

  const AeroButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.onTap,
    this.primary = false,
  });

  @override
  State<AeroButton> createState() => _AeroButtonState();
}

class _AeroButtonState extends State<AeroButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              // Aero drop shadow
              BoxShadow(
                color: const Color(0x44000044),
                blurRadius: _pressed ? 4 : 10,
                offset: Offset(0, _pressed ? 1 : 3),
              ),
              // Accent glow on hover (primary only)
              if (widget.primary && _hovered && !disabled)
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: -3,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: disabled
                        ? [
                            const Color(0x1AFFFFFF),
                            const Color(0x0DFFFFFF),
                          ]
                        : widget.primary
                            ? (_hovered
                                ? [
                                    widget.accentColor.withOpacity(0.45),
                                    widget.accentColor.withOpacity(0.25),
                                    widget.accentColor.withOpacity(0.35),
                                  ]
                                : [
                                    widget.accentColor.withOpacity(0.30),
                                    widget.accentColor.withOpacity(0.15),
                                    widget.accentColor.withOpacity(0.22),
                                  ])
                            : (_hovered
                                ? [
                                    const Color(0x55FFFFFF),
                                    const Color(0x33FFFFFF),
                                    const Color(0x44FFFFFF),
                                  ]
                                : [
                                    const Color(0x40FFFFFF),
                                    const Color(0x22FFFFFF),
                                    const Color(0x30FFFFFF),
                                  ]),
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: disabled
                        ? const Color(0x33FFFFFF)
                        : (_hovered
                            ? const Color(0xAAFFFFFF)
                            : const Color(0x66FFFFFF)),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Top shine strip
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(disabled ? 0.2 : (_hovered ? 0.9 : 0.6)),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          size: 15,
                          color: disabled
                              ? Colors.white.withOpacity(0.25)
                              : (widget.primary
                                  ? (_hovered ? Colors.white : widget.accentColor)
                                  : Colors.white.withOpacity(0.75)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: disabled
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(_hovered ? 1.0 : 0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            shadows: [],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
