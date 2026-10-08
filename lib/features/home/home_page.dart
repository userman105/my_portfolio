import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import '../../core/constants/assets.dart';
import '../../core/constants/links.dart';
import '../../core/theme/colors.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../shared/aero_background.dart';
import '../../shared/project_divider.dart';
import '../projects/project_section.dart';
import '../projects/widgets/project_card.dart';
import 'hero_intro.dart';
import 'portfolio_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _chronicareKey = GlobalKey();
  final GlobalKey _cdlKey = GlobalKey();

  final _projects = PortfolioRepository.getProjects();

  bool _autoScrolled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  Future<void> _startAutoScroll() async {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted ||
        _autoScrolled ||
        !_scrollController.hasClients ||
        _scrollController.offset > 10) {
      return;
    }

    _autoScrolled = true;

    await _scrollController.animateTo(
      MediaQuery.of(context).size.height * 0.75,
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chronicare = _projects[0];
    final cdlaz = _projects[1];

    return Scaffold(
      backgroundColor: AppColors.aeroSkyDeep,
      extendBodyBehindAppBar: true,
      appBar: PortfolioNav(
        scrollController: _scrollController,
        chronicareKey: _chronicareKey,
        cdlKey: _cdlKey,
      ),
      body: AeroBackground(
        accentColor: AppColors.chronicareAccent,
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            _autoScrolled = true;
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56),

                const HeroIntroSection(),

                KeyedSubtree(
                  key: _chronicareKey,
                  child: FeaturedProjectSection(
                    project: chronicare,
                  ),
                ),

                ProjectTransitionDivider(
                  fromAccent: chronicare.accentColor,
                  toAccent: cdlaz.accentColor,
                  nextProjectTitle: cdlaz.title,
                ),

                KeyedSubtree(
                  key: _cdlKey,
                  child: ProjectCard(
                    project: cdlaz,
                    sectionLabel: 'CDL A to Z',
                  ),
                ),

                const _CertificatesSection(),

                _AeroFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _AeroFooter extends StatelessWidget {
  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30,
          sigmaY: 30,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 40,
            horizontal: 32,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x22FFFFFF),
                Color(0x33FFFFFF),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha : 0.55),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterIcon(
                    image: AppAssets.github,
                    tooltip: 'GitHub',
                    onTap: () => _openLink(AppLinks.github),
                  ),

                  const SizedBox(width: 14),

                  _FooterIcon(
                    image: AppAssets.linkedin,
                    tooltip: 'LinkedIn',
                    onTap: () => _openLink(AppLinks.linkedin),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                '© 2026 · Built with Flutter Web',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha : 0.55),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterIcon extends StatefulWidget {
  final String image;
  final String tooltip;
  final VoidCallback onTap;

  const _FooterIcon({
    required this.image,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_FooterIcon> createState() => _FooterIconState();
}


class _FooterIconState extends State<_FooterIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 16,
                sigmaY: 16,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha : 0.55),
                      Colors.white.withValues(alpha : 0.55),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha : 0.55),
                    width: 0.5,
                  ),
                  boxShadow: _hovered
                      ? [
                    const BoxShadow(
                      color: Color(0x2274C0FC),
                      blurRadius: 14,
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Image.asset(
                    widget.image,
                    width: 30,
                    height: 30,
                    opacity: AlwaysStoppedAnimation(
                      _hovered ? 1.0 : 0.65,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _CertificatesSection extends StatefulWidget {
  const _CertificatesSection();

  @override
  State<_CertificatesSection> createState() =>
      _CertificatesSectionState();
}


class _CertificatesSectionState extends State<_CertificatesSection> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<String> _certificates = const [
    'assets/images/certificates/BachelorsDegree.png',
    'assets/images/certificates/DEPI.png',
    'assets/images/certificates/DEPIenglish.png',

  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previous() {
    if (_currentPage <= 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_currentPage >= _certificates.length - 1) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 56 : 80,
      ),
      child: Column(
        children: [
          Text(
            'CERTIFICATIONS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: Colors.white.withValues(alpha : 0.55),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Professional Credentials',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Certifications, training, and academic achievements.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha : 0.55),
            ),
          ),

          const SizedBox(height: 36),

          LayoutBuilder(
            builder: (context, constraints) {
              final cardHeight = isMobile
                  ? size.height * 0.55
                  : size.height * 0.72;

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    height: cardHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _certificates.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _CertificateCard(
                          imagePath: _certificates[index],
                        );
                      },
                    ),
                  ),

                  Positioned(
                    left: isMobile ? 8 : 18,
                    child: _CarouselButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      enabled: _currentPage > 0,
                      onTap: _previous,
                    ),
                  ),

                  Positioned(
                    right: isMobile ? 8 : 18,
                    child: _CarouselButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      enabled: _currentPage <
                          _certificates.length - 1,
                      onTap: _next,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _certificates.length,
                  (index) {
                final selected = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(
                      selected ? 0.8 : 0.25,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${_currentPage + 1} / ${_certificates.length}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Colors.white.withValues(alpha : 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatefulWidget {
  final String imagePath;

  const _CertificateCard({
    required this.imagePath,
  });

  @override
  State<_CertificateCard> createState() => _CertificateCardState();
}


class _CertificateCardState extends State<_CertificateCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        scale: hovered ? 1.005 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 25,
                sigmaY: 25,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(
                        hovered ? 0.20 : 0.14,
                      ),
                      Colors.white.withOpacity(
                        hovered ? 0.10 : 0.06,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      hovered ? 0.42 : 0.24,
                    ),
                    width: 0.7,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class _CarouselButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CarouselButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_CarouselButton> createState() => _CarouselButtonState();
}


class _CarouselButtonState extends State<_CarouselButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(
              widget.enabled
                  ? (hovered ? 0.22 : 0.10)
                  : 0.04,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                widget.enabled ? 0.30 : 0.10,
              ),
              width: 0.7,
            ),
            boxShadow: hovered && widget.enabled
                ? [
              BoxShadow(
                color: Colors.white.withOpacity(0.10),
                blurRadius: 18,
              ),
            ]
                : [],
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: Colors.white.withOpacity(
              widget.enabled ? 0.8 : 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

