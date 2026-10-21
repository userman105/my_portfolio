import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/blur.dart';

class TechChip extends StatefulWidget {
  final TechChipData data;
  const TechChip({super.key, required this.data});

  @override
  State<TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<TechChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.data.color.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: -3,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 10), sigmaY: AeroBlur.of(context, 10)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.data.color.withOpacity(_hovered ? 0.40 : 0.25),
                    widget.data.color.withOpacity(_hovered ? 0.22 : 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(_hovered ? 0.55 : 0.30),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Top shine
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.data.label,
                    style: AppTextStyles.chipLabel.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      shadows: [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TechChipRow extends StatelessWidget {
  final List<TechChipData> chips;
  const TechChipRow({super.key, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) => TechChip(data: c)).toList(),
    );
  }
}
