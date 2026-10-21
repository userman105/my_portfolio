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
import '../../shared/aero_background.dart';
import '../../shared/aero_button.dart';
import '../projects/widgets/tech_chip.dart';
import '../projects/widgets/project_carousel.dart';
import '../../core/utils/blur.dart';

class CaseStudyPage extends StatelessWidget {
  final Project project;
  const CaseStudyPage({super.key, required this.project});
  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.hPad(context);

    return Scaffold(
      backgroundColor: AppColors.aeroSkyDeep,
      body: AeroBackground(
        accentColor: project.accentColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: AeroBlur.of(context, 40), sigmaY: AeroBlur.of(context, 40)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x44FFFFFF), Color(0x22FFFFFF)],
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.7), width: 1),
                        bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white.withOpacity(0.85), size: 16),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                isMobile ? project.title : '${project.title} — Case Study',
                style: AppTextStyles.navLink.copyWith(color: Colors.white.withOpacity(0.9)),
              ),
            ),

            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CASE STUDY', style: AppTextStyles.sectionLabel),
                            const SizedBox(height: 10),
                            Text(
                              project.title,
                              style: AppTextStyles.displayLarge.copyWith(
                                fontWeight: FontWeight.w200,
                                fontSize: isMobile ? 32 : 48,
                                shadows: const [
                                  Shadow(color: Color(0xAAFFFFFF), blurRadius: 24),
                                  Shadow(color: Color(0x88000044), offset: Offset(0, 2), blurRadius: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              project.subtitle,
                              style: AppTextStyles.displaySmall.copyWith(
                                color: project.accentColor.withOpacity(0.85),
                                fontWeight: FontWeight.w300,
                                fontSize: isMobile ? 15 : 20,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(project.description, style: AppTextStyles.bodyLarge),
                          ],
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.08, end: 0),

                        const SizedBox(height: 40),

                        // Full-width screenshot carousel
                        GlassPanel(
                          padding: const EdgeInsets.all(12),
                          glowColor: project.accentColor,
                          child: ProjectCarousel(
                            screenshots: project.screenshots,
                            accentColor: project.accentColor,
                            height: Responsive.caseCarouselHeight(context),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Problem / Solution
                        LayoutBuilder(builder: (ctx, constraints) {
                          final wide = constraints.maxWidth > 560;
                          final problem = _CaseBlock(
                            icon: Icons.help_outline_rounded,
                            title: AppStrings.problemTitle,
                            content: project.caseStudy.problem,
                            accentColor: project.accentColor,
                          );
                          final solution = _CaseBlock(
                            icon: Icons.lightbulb_outline_rounded,
                            title: AppStrings.solutionTitle,
                            content: project.caseStudy.solution,
                            accentColor: project.accentColor,
                          );
                          return wide
                              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(child: problem),
                                  const SizedBox(width: 16),
                                  Expanded(child: solution),
                                ])
                              : Column(children: [problem, const SizedBox(height: 16), solution]);
                        }),

                        const SizedBox(height: 16),
                        _CaseBlock(
                          icon: Icons.account_tree_outlined,
                          title: AppStrings.architectureTitle,
                          content: project.caseStudy.architecture,
                          accentColor: project.accentColor,
                        ),
                        const SizedBox(height: 16),

                        // Challenges
                        GlassPanel(
                          glowColor: project.accentColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _BlockHeader(icon: Icons.construction_outlined,
                                  title: AppStrings.challengesTitle, accentColor: project.accentColor),
                              const SizedBox(height: 16),
                              ...project.caseStudy.challenges.asMap().entries.map((e) =>
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(
                                      width: 22, height: 22,
                                      margin: const EdgeInsets.only(right: 12, top: 1),
                                      decoration: BoxDecoration(
                                        color: project.accentColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: project.accentColor.withOpacity(0.5), width: 0.5),
                                      ),
                                      child: Center(child: Text('${e.key + 1}',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: project.accentColor))),
                                    ),
                                    Expanded(child: Text(e.value, style: AppTextStyles.bodyMedium)),
                                  ]),
                                )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GlassPanel(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _BlockHeader(icon: Icons.memory_outlined,
                                title: AppStrings.techUsedTitle, accentColor: project.accentColor),
                            const SizedBox(height: 16),
                            TechChipRow(chips: project.techStack),
                          ]),
                        ),
                        const SizedBox(height: 16),

                        _CaseBlock(
                          icon: Icons.school_outlined,
                          title: AppStrings.lessonsTitle,
                          content: project.caseStudy.lessonsLearned,
                          accentColor: project.accentColor,
                        ),

                        const SizedBox(height: 36),

                        Wrap(
                          spacing: 10, runSpacing: 10,
                          children: [
                            if (project.githubUrl?.isNotEmpty == true)
                              AeroButton(
                                label: 'View on GitHub',
                                icon: Icons.code_rounded,
                                accentColor: project.accentColor,
                                primary: true,
                                onTap: () => _openUrl(project.githubUrl!),
                              ),
                            if (project.apkUrl?.isNotEmpty == true)
                              AeroButton(label: 'Download APK', icon: Icons.android_rounded,
                                  accentColor: project.accentColor, onTap: ()=>_openUrl(project.apkUrl!)),
                            if (project.demoUrl?.isNotEmpty == true)
                              AeroButton(label: 'Watch Demo', icon: Icons.play_circle_outline_rounded,
                                  accentColor: project.accentColor, onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;
  const _CaseBlock({required this.icon, required this.title, required this.content, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _BlockHeader(icon: icon, title: title, accentColor: accentColor),
        const SizedBox(height: 12),
        Text(content, style: AppTextStyles.bodyMedium),
      ]),
    );
  }
}

class _BlockHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  const _BlockHeader({required this.icon, required this.title, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: accentColor.withOpacity(0.85), size: 17),
      const SizedBox(width: 10),
      Text(title, style: AppTextStyles.caseStudyHeading),
    ]);
  }
}
