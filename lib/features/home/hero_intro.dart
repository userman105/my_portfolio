
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/resposive.dart';
import '../../shared/glass_panel.dart';

class HeroIntroSection extends StatelessWidget {
  const HeroIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final isMobile = Responsive.isMobile(context);
    final heroSize = Responsive.heroFontSize(context);

    return SizedBox(
      height: h * 0.82,
      child: Stack(
        children: [
          // Bachelor's degree background.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isMobile
                ? h * 0.38
                : h * 0.48,
            child: IgnorePointer(
              child: Opacity(
                opacity: isMobile ? 0.055 : 0.075,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 0.78,
                    child: Image.asset(
                      'assets/images/certificates/BachelorsDegree.png',
                      width: w,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Soft fade to blend the degree into the hero.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isMobile
                ? h * 0.40
                : h * 0.50,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Hero content.
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.hPad(context),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      child: Text(
                        AppStrings.title.toUpperCase(),
                        style: AppTextStyles.sectionLabel,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(
                      begin: -0.15,
                      end: 0,
                      curve: Curves.easeOut,
                    ),

                    SizedBox(
                      height: isMobile ? 18 : 26,
                    ),

                    // Name
                    Text(
                      AppStrings.name,
                      style: AppTextStyles.displayHero.copyWith(
                        fontSize: heroSize,
                        fontWeight: FontWeight.w200,
                        shadows: const [
                          Shadow(
                            color: Color(0xAAFFFFFF),
                            blurRadius: 30,
                          ),
                          Shadow(
                            color: Color(0x99000044),
                            offset: Offset(0, 2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay: 200.ms,
                      duration: 800.ms,
                    )
                        .slideX(
                      begin: -0.08,
                      end: 0,
                    ),

                    SizedBox(
                      height: isMobile ? 14 : 20,
                    ),

                    // Tagline
                    Text(
                      AppStrings.tagline,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isMobile ? 15 : 18,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay: 400.ms,
                      duration: 600.ms,
                    ),

                    SizedBox(
                      height: isMobile ? 8 : 12,
                    ),

                    // Bio
                    Text(
                      AppStrings.bio,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: isMobile ? 13 : 14,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay: 500.ms,
                      duration: 600.ms,
                    ),

                    SizedBox(
                      height: isMobile ? 40 : 56,
                    ),

                    _AeroScrollIndicator()
                        .animate()
                        .fadeIn(
                      delay: 1000.ms,
                      duration: 800.ms,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AeroScrollIndicator extends StatefulWidget {
  @override
  State<_AeroScrollIndicator> createState() =>
      _AeroScrollIndicatorState();
}

class _AeroScrollIndicatorState
    extends State<_AeroScrollIndicator>
    with SingleTickerProviderStateMixin {

  late AnimationController _c;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounce = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(
      CurvedAnimation(
        parent: _c,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(
            0,
            _bounce.value,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCROLL',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.35),
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.4),
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

