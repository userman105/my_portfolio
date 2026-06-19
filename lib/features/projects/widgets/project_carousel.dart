import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../data/models/project.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

class ProjectCarousel extends StatefulWidget {
  final List<ProjectScreenshot> screenshots;
  final Color accentColor;
  final double height;

  const ProjectCarousel({
    super.key,
    required this.screenshots,
    required this.accentColor,
    this.height = 780,
  });

  @override
  State<ProjectCarousel> createState() => _ProjectCarouselState();
}

class _ProjectCarouselState extends State<ProjectCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Center(
            child: AspectRatio(
              aspectRatio: 9 / 19.5,
              child: Stack(
                children: [
                  // Screenshot pages
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemCount: widget.screenshots.length,
                      itemBuilder: (_, i) => _FullScreenShot(
                        screenshot: widget.screenshots[i],
                        accentColor: widget.accentColor,
                      ),
                    ),
                  ),

                  // Phone bezel ring
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dynamic Island pill
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Aero glass edge glow overlay (top + bottom)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Top Aero shine
                            Positioned(
                              top: 0, left: 0, right: 0,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Bottom fade for caption legibility
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0x99000033),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Caption overlaid on image bottom
                  Positioned(
                    bottom: 16, left: 20,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        widget.screenshots[_current].caption,
                        key: ValueKey(_current),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          shadows: [],
                        ),
                      ),
                    ),
                  ),

                  // Aero glass nav arrows
                  if (widget.screenshots.length > 1) ...[
                    Positioned(
                      left: 10, top: 0, bottom: 0,
                      child: Center(
                        child: _AeroNavBtn(
                          icon: Icons.chevron_left_rounded,
                          accentColor: widget.accentColor,
                          onTap: _current > 0
                              ? () => _controller.previousPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10, top: 0, bottom: 0,
                      child: Center(
                        child: _AeroNavBtn(
                          icon: Icons.chevron_right_rounded,
                          accentColor: widget.accentColor,
                          onTap: _current < widget.screenshots.length - 1
                              ? () => _controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Page indicator
        if (widget.screenshots.length > 1)
          SmoothPageIndicator(
            controller: _controller,
            count: widget.screenshots.length,
            effect: WormEffect(
              dotHeight: 5,
              dotWidth: 5,
              activeDotColor: widget.accentColor,
              dotColor: Colors.white.withOpacity(0.25),
              spacing: 7,
            ),
          ),
      ],
    );
  }
}

class _FullScreenShot extends StatelessWidget {
  final ProjectScreenshot screenshot;
  final Color accentColor;

  const _FullScreenShot({required this.screenshot, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      screenshot.assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _Placeholder(
        caption: screenshot.caption,
        accentColor: accentColor,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String caption;
  final Color accentColor;
  const _Placeholder({required this.caption, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1251A3).withOpacity(0.7),
            const Color(0xFF062B6E).withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined,
              color: accentColor.withOpacity(0.5), size: 52),
          const SizedBox(height: 14),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add image to assets/images/',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AeroNavBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentColor;

  const _AeroNavBtn({required this.icon, required this.accentColor, this.onTap});

  @override
  State<_AeroNavBtn> createState() => _AeroNavBtnState();
}

class _AeroNavBtnState extends State<_AeroNavBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          opacity: active ? 1.0 : 0.2,
          duration: const Duration(milliseconds: 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(_hovered ? 0.45 : 0.28),
                      Colors.white.withOpacity(_hovered ? 0.25 : 0.12),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(_hovered ? 0.85 : 0.5),
                    width: 0.5,
                  ),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}