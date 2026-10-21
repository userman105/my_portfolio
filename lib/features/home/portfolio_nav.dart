import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/blur.dart';

class PortfolioNav extends StatelessWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final GlobalKey chronicareKey;
  final GlobalKey cdlKey;

  const PortfolioNav({
    super.key,
    required this.scrollController,
    required this.chronicareKey,
    required this.cdlKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 40), sigmaY: AeroBlur.of(context, 40)),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x44FFFFFF), Color(0x22FFFFFF), Color(0x18FFFFFF)],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.7), width: 1),
              bottom: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
            child: Row(
              children: [
                // ── Desktop: inline links | Mobile: hamburger ─
                if (isMobile)
                  _HamburgerButton(
                    onChronniCare: () => _scrollTo(chronicareKey),
                    onCdl: () => _scrollTo(cdlKey),
                  )
                else ...[
                  _NavLink(
                    label: 'ChroniCare',
                    accentColor: AppColors.chronicareAccent,
                    onTap: () => _scrollTo(chronicareKey),
                  ),
                  const SizedBox(width: 28),
                  _NavLink(
                    label: 'CDL A to Z',
                    accentColor: AppColors.cdlAccent,
                    onTap: () => _scrollTo(cdlKey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NameLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.name,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        shadows: const [Shadow(color: Color(0x88000044), offset: Offset(0, 1), blurRadius: 6)],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;
  const _NavLink({required this.label, required this.onTap, this.accentColor});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: AppTextStyles.navLink.copyWith(
            color: _hovered
                ? (widget.accentColor ?? Colors.white)
                : Colors.white.withOpacity(0.8),
            shadows: _hovered
                ? [Shadow(color: (widget.accentColor ?? Colors.white).withOpacity(0.6), blurRadius: 12)]
                : [const Shadow(color: Color(0x66000044), offset: Offset(0, 1), blurRadius: 4)],
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  final VoidCallback onChronniCare;
  final VoidCallback onCdl;
  const _HamburgerButton({required this.onChronniCare, required this.onCdl});

  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MobileNavSheet(
        onChronniCare: () {
          Navigator.pop(context);
          onChronniCare();
        },
        onCdl: () {
          Navigator.pop(context);
          onCdl();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDrawer(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 20), sigmaY: AeroBlur.of(context, 20)),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x40FFFFFF), Color(0x20FFFFFF)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
            ),
            child: Icon(Icons.menu_rounded, color: Colors.white.withOpacity(0.85), size: 18),
          ),
        ),
      ),
    );
  }
}

class _MobileNavSheet extends StatelessWidget {
  final VoidCallback onChronniCare;
  final VoidCallback onCdl;
  const _MobileNavSheet({required this.onChronniCare, required this.onCdl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 40), sigmaY: AeroBlur.of(context, 40)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x55FFFFFF), Color(0x33FFFFFF)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.65), width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36, height: 3,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _SheetLink(
                label: 'ChroniCare',
                accent: AppColors.chronicareAccent,
                onTap: onChronniCare,
              ),
              const SizedBox(height: 4),
              _SheetLink(
                label: 'CDL A to Z',
                accent: AppColors.cdlAccent,
                onTap: onCdl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? accent;
  const _SheetLink({required this.label, required this.onTap, this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.06),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: accent ?? Colors.white.withOpacity(0.85),
            shadows: accent != null
                ? [Shadow(color: accent!.withOpacity(0.5), blurRadius: 10)]
                : null,
          ),
        ),
      ),
    );
  }
}
