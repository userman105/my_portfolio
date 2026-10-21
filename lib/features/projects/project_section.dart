import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/project.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/resposive.dart';
import '../../shared/glass_panel.dart';
import '../../shared/aero_button.dart';
import 'widgets/tech_chip.dart';
import 'widgets/project_carousel.dart';
import '../case_study/case_study_page.dart';
import '../../core/utils/blur.dart';

class FeaturedProjectSection extends StatelessWidget {
  final Project project;
  const FeaturedProjectSection({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.hPad(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionPill(label: AppStrings.featuredProject, accentColor: project.accentColor),
                SizedBox(height: isMobile ? 24 : 40),
                Responsive.isTwoColumn(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _InfoPanel(project: project)),
                          const SizedBox(width: 48),
                          Expanded(flex: 5, child: _VisualPanel(project: project)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _VisualPanel(project: project), // screenshot FIRST on mobile
                          const SizedBox(height: 32),
                          _InfoPanel(project: project),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  final String label;
  final Color accentColor;
  const _SectionPill({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 20), sigmaY: AeroBlur.of(context, 20)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x44FFFFFF), Color(0x22FFFFFF)],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: accentColor.withOpacity(0.5), width: 0.5),
          ),
          child: Text(label,
              style: AppTextStyles.sectionLabel.copyWith(color: accentColor)),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0);
  }
}

class _InfoPanel extends StatelessWidget {
  final Project project;
  const _InfoPanel({required this.project});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: AppTextStyles.displayLarge.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: isMobile ? 36 : 48,
            shadows: const [
              Shadow(color: Color(0xAAFFFFFF), blurRadius: 24),
              Shadow(color: Color(0x88000044), offset: Offset(0, 2), blurRadius: 8),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 700.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 6),

        Text(
          project.subtitle,
          style: AppTextStyles.displaySmall.copyWith(
            color: project.accentColor.withOpacity(0.85),
            fontWeight: FontWeight.w300,
            fontSize: isMobile ? 15 : 20,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 14 : 20),

        Text(project.description,
                style: AppTextStyles.bodyLarge.copyWith(fontSize: isMobile ? 14 : 16))
            .animate().fadeIn(delay: 300.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 20 : 28),

        Text('TECH STACK',
            style: AppTextStyles.sectionLabel
                .copyWith(color: Colors.white.withOpacity(0.4), fontSize: 9)),
        const SizedBox(height: 10),
        TechChipRow(chips: project.techStack)
            .animate().fadeIn(delay: 350.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 20 : 28),

        GlassPanel(
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          glowColor: project.accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KEY FEATURES',
                  style: AppTextStyles.sectionLabel
                      .copyWith(color: Colors.white.withOpacity(0.4), fontSize: 9)),
              const SizedBox(height: 12),
              ...project.keyFeatures.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 10),
                          child: Container(
                            width: 3, height: 3,
                            decoration: BoxDecoration(
                              color: project.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: project.accentColor.withOpacity(0.7), blurRadius: 5)],
                            ),
                          ),
                        ),
                        Expanded(child: Text(f, style: AppTextStyles.featureItem)),
                      ],
                    ),
                  )),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 20 : 28),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AeroButton(
              label: AppStrings.readCaseStudy,
              icon: Icons.article_outlined,
              accentColor: project.accentColor,
              primary: true,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CaseStudyPage(project: project))),
            ),
            AeroButton(
              label: AppStrings.viewOnGitHub,
              icon: Icons.code_rounded,
              accentColor: project.accentColor,
              onTap: () {
                debugPrint(project.title);
                debugPrint(project.githubUrl);

                if (project.githubUrl != null &&
                    project.githubUrl!.isNotEmpty) {
                  _openUrl(project.githubUrl!);
                }
              },
            ),
            AeroButton(
              label: AppStrings.downloadApk,
              icon: Icons.android_rounded,
              accentColor: project.accentColor,
              onTap: project.apkUrl?.isNotEmpty == true ? () {
                if (project.apkUrl != null &&
                    project.apkUrl!.isNotEmpty) {
                  _openUrl(project.apkUrl!);
                }
              } : null,
            ),
            // AeroButton(
            //   label: AppStrings.watchDemo,
            //   icon: Icons.play_circle_outline_rounded,
            //   accentColor: project.accentColor,
            //   onTap: project.demoUrl?.isNotEmpty == true ? () {} : null,
            // ),
          ],
        ).animate().fadeIn(delay: 450.ms, duration: 600.ms),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
  
}

class _VisualPanel extends StatelessWidget {
  final Project project;
  const _VisualPanel({required this.project});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      glowColor: project.accentColor,
      child: ProjectCarousel(
        screenshots: project.screenshots,
        accentColor: project.accentColor,
        height: Responsive.carouselHeight(context),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 700.ms).slideX(begin: 0.06, end: 0);
  }
}
