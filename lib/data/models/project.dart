import 'package:flutter/material.dart';

class TechChipData {
  final String label;
  final Color color;
  final Color textColor;

  const TechChipData({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });
}

class ProjectScreenshot {
  final String assetPath;
  final String caption;

  const ProjectScreenshot({
    required this.assetPath,
    required this.caption,
  });
}

class CaseStudyData {
  final String problem;
  final String solution;
  final String architecture;
  final List<String> challenges;
  final String lessonsLearned;

  const CaseStudyData({
    required this.problem,
    required this.solution,
    required this.architecture,
    required this.challenges,
    required this.lessonsLearned,
  });
}

/// A companion data-analytics piece attached to a project (e.g. an
/// interactive dashboard that complements an app).
class InsightsData {
  final String eyebrow;
  final String title;
  final String blurb;
  final List<String> connections;
  final List<ProjectScreenshot> screenshots;
  final String dashboardUrl;
  final String repoUrl;
  final String note;

  const InsightsData({
    required this.eyebrow,
    required this.title,
    required this.blurb,
    required this.connections,
    required this.screenshots,
    required this.dashboardUrl,
    required this.repoUrl,
    required this.note,
  });
}

class Project {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<TechChipData> techStack;
  final List<String> keyFeatures;
  final List<ProjectScreenshot> screenshots;
  final String? githubUrl;
  final String? apkUrl;
  final String? demoUrl;
  final Color accentColor;
  final Color gradientFrom;
  final Color gradientTo;
  final CaseStudyData caseStudy;
  final bool isFeatured;
  final bool isBackend;
  final InsightsData? insights;

  const Project({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.techStack,
    required this.keyFeatures,
    required this.screenshots,
    this.githubUrl,
    this.apkUrl,
    this.demoUrl,
    required this.accentColor,
    required this.gradientFrom,
    required this.gradientTo,
    required this.caseStudy,
    this.isFeatured = false,
    this.isBackend = false,
    this.insights,
  });
}
