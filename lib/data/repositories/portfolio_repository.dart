import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../core/constants/assets.dart';
import '../../core/constants/links.dart';
import '../../core/theme/colors.dart';

class PortfolioRepository {
  static List<Project> getProjects() => [_chronicare, _cdlAtoZ];

  static final Project _chronicare = Project(
    id: 'chronicare',
    title: 'ChroniCare',
    subtitle: 'Health Tracking & OCR Lab Analysis',
    githubUrl: AppLinks.chronicareGithub,
    description:
        'A comprehensive health management platform '
            'that lets patients track chronic conditions, '
            'scan lab test results with OCR, and generate '
            'detailed PDF health reports — even without internet access.',
    isFeatured: true,
    accentColor: AppColors.cyanAccent,
    gradientFrom: AppColors.chronicareFrom,
    gradientTo: AppColors.chronicareTo,
    techStack: [
      TechChipData(label: 'Flutter', color: const Color(0xFF0553B1)),
      TechChipData(label: 'FastAPI', color: const Color(0xFF059669)),
      TechChipData(label: 'Node.js', color: const Color(0xFF339933)),
      TechChipData(label: 'Express', color: const Color(0xFF404040)),
      TechChipData(label: 'Prisma', color: const Color(0xFF1A202C)),
      TechChipData(label: 'PostgreSQL', color: const Color(0xFF47A248)),
      TechChipData(label: 'BLoC', color: const Color(0xFF8B5CF6)),
      TechChipData(label: 'Dio', color: const Color(0xFFE11D48)),
      TechChipData(label: 'PDF Gen', color: const Color(0xFFDC2626)),
      TechChipData(label: 'OCR', color: const Color(0xFF0E7490)),
    ],
    keyFeatures: [
      'Offline mode with background sync',
      'OCR lab test scanning',
      'PDF health report generation',
      'JWT authentication',
      'Health metric tracking & charts',
      'Multi-lab result history',
      'Secure data encryption',
      'Dark mode support',
    ],
    screenshots: [
      ProjectScreenshot(
        assetPath: AppAssets.chronicareLogin,
        caption: 'Login Screen',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.chronicareDashboard,
        caption: 'Health Dashboard',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.chronicareOcr,
        caption: 'OCR Lab Scan',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.chronicareReport,
        caption: 'PDF Report',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.chronicareProfile,
        caption: 'Patient Profile',
      ),
    ],
    apkUrl: AppLinks.chronicareApk,
    demoUrl: AppLinks.chronicareDemo,
    caseStudy: const CaseStudyData(
      problem:
          'Patients with chronic conditions struggle to keep track of lab results across multiple visits and providers. Paper records get lost, digital portals are fragmented, and most apps require constant internet access — a real barrier in areas with poor connectivity.',
      solution:
          'ChroniCare unifies health tracking, lab result scanning, and report generation in one cross-platform app. A FastAPI OCR microservice extracts structured data from photographed lab reports, while an Express/Node backend handles authentication and persistent storage. A local-first architecture ensures the app works fully offline.',
      architecture:
          'Flutter frontend communicates with an Express/Node API via Dio. BLoC manages all state transitions. A separate FastAPI microservice handles OCR processing using Tesseract. Prisma ORM connects to the database. Offline data is persisted locally and synced via a background queue when connectivity resumes.',
      challenges: [
        'Implementing reliable offline-first sync without data conflicts when the device reconnects.',
        'Parsing unstructured OCR text from lab reports with varying formats across different labs.',
        'Generating pixel-perfect PDF reports that render consistently across Android, iOS, and web.',
        'Securing health data in transit and at rest while maintaining fast load times.',
      ],
      lessonsLearned:
          'Building offline-first from day one is far easier than retrofitting it. Defining a clear sync conflict resolution strategy early saved significant debugging time. The OCR service taught me the value of microservices — isolating it meant I could iterate on the ML pipeline without touching the main API.',
    ),
  );

  static final Project _cdlAtoZ = Project(
    id: 'cdlaz',
    title: 'CDL A to Z',
    subtitle: 'Commercial Driver License Study App',
    githubUrl: AppLinks.cdlGithub,
    description:
        'A comprehensive CDL exam preparation app with practice tests, study guides, and progress tracking — helping aspiring commercial drivers pass their license exams on the first try.',
    isFeatured: false,
    accentColor: AppColors.emeraldAccent,
    gradientFrom: AppColors.cdlFrom,
    gradientTo: AppColors.cdlTo,
    techStack: [
      TechChipData(label: 'Flutter', color: const Color(0xFF0553B1)),
      TechChipData(label: 'BLoC', color: const Color(0xFF8B5CF6)),
      TechChipData(label: 'Dio', color: const Color(0xFFE11D48)),
      TechChipData(label: 'Node.js', color: const Color(0xFF339933)),
      TechChipData(label: 'MongoDB', color: const Color(0xFF47A248)),
      TechChipData(label: 'Firebase', color: const Color(0xFFFF6F00)),
    ],
    keyFeatures: [
      'Full CDL test question bank',
      'Practice mode & timed exams',
      'Progress tracking & analytics',
      'Offline question access',
      'Detailed answer explanations',
      'State-specific test variants',
      'Bookmarks & weak-area review',
      'Dark mode',
    ],
    screenshots: [
      ProjectScreenshot(
        assetPath: AppAssets.cdlHome,
        caption: 'Home Screen',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.cdlQuiz,
        caption: 'Practice Quiz',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.cdlStudy,
        caption: 'Study Guide',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.cdlProgress,
        caption: 'Progress Dashboard',
      ),
      ProjectScreenshot(
        assetPath: AppAssets.cdlSettings,
        caption: 'Settings',
      ),
    ],
    apkUrl: AppLinks.cdlApk,
    demoUrl: AppLinks.cdlDemo,
    caseStudy: const CaseStudyData(
      problem:
          'CDL exam prep resources are scattered, expensive, or outdated. Most apps lack offline support, forcing drivers — who are often on the road — to be internet-dependent when studying between routes.',
      solution:
          'CDL A to Z bundles a complete question bank, study guides, and smart progress tracking into a single offline-capable app. A Node/MongoDB backend serves content updates, while the Flutter frontend caches questions locally for road-ready studying.',
      architecture:
          'Flutter with BLoC for state management. Questions and study material are fetched from a Node.js REST API backed by MongoDB, then cached locally. Firebase handles push notifications for daily study reminders. Offline-first architecture ensures full functionality without connectivity.',
      challenges: [
        'Sourcing accurate, up-to-date CDL questions across different state DMV variants.',
        'Designing a progress algorithm that identifies weak areas and prioritizes them in review sessions.',
        'Caching large question banks efficiently without bloating local storage.',
      ],
      lessonsLearned:
          'Content quality matters as much as code quality for study apps. I spent significant time verifying question accuracy against official DMV materials. The adaptive review feature was the most impactful addition — users who used it passed at a meaningfully higher rate.',
    ),
  );
}
