import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/resposive.dart';
import '../../../data/models/project.dart';
import '../../../shared/aero_button.dart';
import '../../../shared/glass_panel.dart';

/// Companion-analytics block for a project: a preview of the interactive
/// dashboard (tap to open the live version), how it connects to the app,
/// and links out. Used on the ChroniCare case study page.
class InsightsPanel extends StatefulWidget {
  final InsightsData data;
  final Color accentColor;

  const InsightsPanel({
    super.key,
    required this.data,
    required this.accentColor,
  });

  @override
  State<InsightsPanel> createState() => _InsightsPanelState();
}

class _InsightsPanelState extends State<InsightsPanel> {
  int _index = 0;

  Future<void> _open(String url) async {
    // Relative paths (the dashboard ships inside this site) resolve against
    // the current origin; absolute URLs pass through unchanged.
    final Uri uri = Uri.base.resolve(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _shortLabel(ProjectScreenshot s) => s.caption.split(':').first;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final accent = widget.accentColor;
    final isMobile = Responsive.isMobile(context);
    final shots = d.screenshots;
    final current = shots.isEmpty ? null : shots[_index.clamp(0, shots.length - 1)];

    return GlassPanel(
      glowColor: accent,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.eyebrow,
              style: AppTextStyles.sectionLabel.copyWith(color: accent)),
          const SizedBox(height: 8),
          Text(
            d.title,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.w200,
              fontSize: isMobile ? 24 : 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(d.blurb, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 20),

          if (current != null) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _open(d.dashboardUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: isMobile ? 230 : 400,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Image.asset(
                            current.assetPath,
                            key: ValueKey<int>(_index),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x00041640), Color(0xDD041640)],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(current.caption,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: Colors.white)),
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.open_in_new_rounded,
                                    size: 16, color: accent),
                                const SizedBox(width: 4),
                                Text('Open live',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: accent)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < shots.length; i++)
                  _PagePill(
                    label: _shortLabel(shots[i]),
                    selected: i == _index,
                    accent: accent,
                    onTap: () => setState(() => _index = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'HOW THE TWO PROJECTS CONNECT',
            style: AppTextStyles.sectionLabel
                .copyWith(color: Colors.white.withOpacity(0.4), fontSize: 9),
          ),
          const SizedBox(height: 12),
          ...d.connections.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 10),
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: accent.withOpacity(0.7), blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Text(c, style: AppTextStyles.featureItem)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AeroButton(
                label: 'Open interactive dashboard',
                icon: Icons.insights_rounded,
                accentColor: accent,
                primary: true,
                onTap: () => _open(d.dashboardUrl),
              ),
              if (d.repoUrl.isNotEmpty)
                AeroButton(
                  label: 'Analysis repo',
                  icon: Icons.code_rounded,
                  accentColor: accent,
                  onTap: () => _open(d.repoUrl),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            d.note,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white.withOpacity(0.55)),
          ),
        ],
      ),
    );
  }
}

class _PagePill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _PagePill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.25)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent : Colors.white.withOpacity(0.3),
              width: selected ? 1 : 0.5,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? Colors.white : Colors.white.withOpacity(0.75),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
