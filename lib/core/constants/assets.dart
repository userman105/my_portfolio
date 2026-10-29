class AppAssets {
  // ChroniCare screenshots — add your actual image files to assets/images/chronicare/
  static const String chronicareLogin = 'assets/images/chronicare/login.webp';
  static const String chronicareDashboard = 'assets/images/chronicare/dashboard.webp';
  static const String chronicareOcr = 'assets/images/chronicare/ocr.webp';
  static const String chronicareReport = 'assets/images/chronicare/report.webp';
  static const String chronicareProfile = 'assets/images/chronicare/profile.webp';

  // CDL A to Z screenshots — add your actual image files to assets/images/cdlaz/
  static const String cdlHome = 'assets/images/cdlaz/home.webp';
  static const String cdlQuiz = 'assets/images/cdlaz/quiz.webp';
  static const String cdlStudy = 'assets/images/cdlaz/study.webp';
  static const String cdlProgress = 'assets/images/cdlaz/progress.webp';
  static const String cdlSettings = 'assets/images/cdlaz/settings.webp';
  static const String cdlPlaystore = 'assets/images/cdlaz/playstore.webp';

  static const  String tetrisFirst= 'assets/images/tetris/tetris.webp';
  static const  String tetrisSecond = 'assets/images/tetris/tetris2.webp';

  static const String github = 'assets/images/icons/github.webp';
  static const String linkedin = 'assets/images/icons/linkedin.webp';

  static const String degree = 'assets/images/certificates/bachelorsdegree.webp';

  /// Needed for the first screen. Loaded while the HTML loader is still showing.
  static const List<String> critical = [
    degree,
    github,
    linkedin,
    chronicareLogin,
    chronicareDashboard,
  ];

  /// Everything else is fetched quietly after the first frame, one at a time,
  /// so it never competes with the first paint or with scrolling.
  static const List<String> deferred = [
    chronicareOcr,
    chronicareReport,
    chronicareProfile,
    cdlHome,
    cdlQuiz,
    cdlStudy,
    cdlProgress,
    cdlSettings,
    tetrisFirst,
    tetrisSecond,
    'assets/images/certificates/depi.webp',
    'assets/images/certificates/depienglish.webp',
  ];
}
