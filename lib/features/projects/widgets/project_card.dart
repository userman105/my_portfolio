import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/project.dart';
import '../../../core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/resposive.dart';
import '../../../shared/glass_panel.dart';
import '../../../shared/aero_button.dart';
import 'tech_chip.dart';
import 'project_carousel.dart';
import '../../case_study/case_study_page.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final String sectionLabel;

  const ProjectCard({super.key, required this.project, this.sectionLabel = 'PROJECT'});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.hPad(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x44FFFFFF), Color(0x22FFFFFF)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: project.accentColor.withOpacity(0.5), width: 0.5),
                      ),
                      child: Text(sectionLabel,
                          style: AppTextStyles.sectionLabel.copyWith(color: project.accentColor)),
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 24 : 40),

                Responsive.isTwoColumn(context)
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: GlassPanel(
                        padding: const EdgeInsets.all(8),
                        glowColor: project.accentColor,
                        child: ProjectCarousel(
                          screenshots: project.screenshots,
                          accentColor: project.accentColor,
                          height: 780,
                        ),
                      ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.06, end: 0),
                    ),
                    const SizedBox(width: 48),
                    Expanded(flex: 5, child: _buildInfo(context)),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassPanel(
                      padding: const EdgeInsets.all(8),
                      glowColor: project.accentColor,
                      child: ProjectCarousel(
                        screenshots: project.screenshots,
                        accentColor: project.accentColor,
                        height: 640,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildInfo(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: AppTextStyles.displayMedium.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: isMobile ? 42 : 40,
            shadows: const [
              Shadow(color: Color(0xAAFFFFFF), blurRadius: 20),
              Shadow(color: Color(0x88000044), offset: Offset(0, 2), blurRadius: 8),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 700.ms),

        const SizedBox(height: 6),

        Text(
          project.subtitle,
          style: AppTextStyles.displaySmall.copyWith(
            color: project.accentColor.withOpacity(0.85),
            fontWeight: FontWeight.w300,
            fontSize: isMobile ? 14 : 18,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 14 : 18),

        Text(project.description,
            style: AppTextStyles.bodyLarge.copyWith(fontSize: isMobile ? 14 : 16))
            .animate().fadeIn(delay: 300.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 18 : 24),

        Text('TECH STACK',
            style: AppTextStyles.sectionLabel
                .copyWith(color: Colors.white.withOpacity(0.4), fontSize: 9)),
        const SizedBox(height: 10),
        TechChipRow(chips: project.techStack)
            .animate().fadeIn(delay: 350.ms, duration: 600.ms),

        SizedBox(height: isMobile ? 18 : 24),

        GlassPanel(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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

        SizedBox(height: isMobile ? 18 : 24),

        Wrap(
          spacing: 8, runSpacing: 8,
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
              onTap: project.githubUrl?.isNotEmpty == true
                  ? () => _openUrl(project.githubUrl!)
                  : null,
            ),
            AeroButton(
              label: AppStrings.downloadApk,
              icon: Icons.android_rounded,
              accentColor: project.accentColor,
              onTap: project.apkUrl?.isNotEmpty == true
                  ? () =>_openUrl(project.apkUrl!) : null,
            ),
            AeroButton(
              label: AppStrings.watchDemo,
              icon: Icons.play_circle_outline_rounded,
              accentColor: project.accentColor,
              onTap: project.demoUrl?.isNotEmpty == true ? () {} : null,
            ),
          ],
        ).animate().fadeIn(delay: 450.ms, duration: 600.ms),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}