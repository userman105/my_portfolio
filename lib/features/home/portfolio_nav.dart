import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/blur.dart';

/// One tab in the nav bar.
class NavItem {
  final String label; // desktop
  final String shortLabel; // mobile (tabs share the full width)
  final GlobalKey sectionKey;
  final Color accent;

  const NavItem({
    required this.label,
    required this.shortLabel,
    required this.sectionKey,
    required this.accent,
  });
}

/// Glass nav bar with a pill that slides to whichever project is on screen.
///
/// HomePage owns the state: it updates [activeIndex] while scrolling
/// (scroll-spy) and on tap, and performs the scroll in [onSelect].
class PortfolioNav extends StatelessWidget implements PreferredSizeWidget {
  final List<NavItem> items;
  final ValueListenable<int> activeIndex; // -1 = none (hero is showing)
  final ValueChanged<int> onSelect;

  const PortfolioNav({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AeroBlur.of(context, 40),
          sigmaY: AeroBlur.of(context, 40),
        ),
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
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 32,
              vertical: 9,
            ),
            child: LayoutBuilder(builder: (context, c) {
              final tabW = isMobile
                  ? c.maxWidth / items.length
                  : math.min(132.0, c.maxWidth / items.length);

              return Align(
                alignment: isMobile ? Alignment.center : Alignment.centerLeft,
                child: SizedBox(
                  width: tabW * items.length,
                  height: 38,
                  child: ValueListenableBuilder<int>(
                    valueListenable: activeIndex,
                    builder: (_, active, __) {
                      final hasActive = active >= 0 && active < items.length;
                      return Stack(
                        children: [
                          // The sliding pill.
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            left: (hasActive ? active : 0) * tabW,
                            top: 0,
                            bottom: 0,
                            width: tabW,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: hasActive ? 1 : 0,
                              child: _Indicator(
                                accent: hasActive
                                    ? items[active].accent
                                    : Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < items.length; i++)
                                SizedBox(
                                  width: tabW,
                                  child: _NavTab(
                                    label: isMobile
                                        ? items[i].shortLabel
                                        : items[i].label,
                                    accent: items[i].accent,
                                    active: i == active,
                                    compact: isMobile,
                                    onTap: () => onSelect(i),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color accent;
  const _Indicator({required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withOpacity(0.38),
            accent.withOpacity(0.14),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 0.6),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.35),
            blurRadius: 14,
            spreadRadius: -3,
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  final String label;
  final Color accent;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.accent,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final lit = widget.active || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.navLink.copyWith(
              fontSize: widget.compact ? 12 : null,
              color: widget.active
                  ? Colors.white
                  : _hovered
                      ? widget.accent
                      : Colors.white.withOpacity(0.78),
              fontWeight: widget.active ? FontWeight.w600 : null,
              shadows: lit
                  ? [Shadow(color: widget.accent.withOpacity(0.6), blurRadius: 10)]
                  : const [Shadow(color: Color(0x66000044), offset: Offset(0, 1), blurRadius: 4)],
            ),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
