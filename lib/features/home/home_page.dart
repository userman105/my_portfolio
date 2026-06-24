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
import 'dart:async';

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
                    child: FeaturedProjectSection(project: chronicare),
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
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22FFFFFF), Color(0x33FFFFFF)],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.55), width: 1),
            ),
          ),
          child: Column(
            children: [Row(
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
                  color: Colors.white.withOpacity(0.4),
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
                      Colors.white.withOpacity(
                        _hovered ? 0.45 : 0.25,
                      ),
                      Colors.white.withOpacity(
                        _hovered ? 0.25 : 0.10,
                      ),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      _hovered ? 0.8 : 0.4,
                    ),
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

class _CertificatesSection extends StatelessWidget {
  const _CertificatesSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 64,
      ),
      child: Column(
        children: [
          Text(
            'CERTIFICATIONS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: Colors.white.withOpacity(0.55),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Digital Egypt Pioneers Initiative (DEPI)',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 40),

          isMobile
              ? Column(
            children: const [
              _CertificateCard(
                imagePath:
                'assets/images/certificates/DEPI.png',
              ),
              SizedBox(height: 24),
              _CertificateCard(
                imagePath:
                'assets/images/certificates/DEPIenglish.png',
              ),
            ],
          )
              : Row(
            children: const [
              Expanded(
                child: _CertificateCard(
                  imagePath:
                  'assets/images/certificates/DEPI.png',
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _CertificateCard(
                  imagePath:
                  'assets/images/certificates/DEPIenglish.png',
                ),
              ),
            ],
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
        scale: hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}