# Portfolio — Flutter Web

Aero Glass design. Single-page scrollable portfolio for ChroniCare and CDL A to Z.

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Add your screenshots
Place images in:
```
assets/images/chronicare/
  login.png
  dashboard.png
  ocr.png
  report.png
  profile.png

assets/images/cdlaz/
  home.png
  quiz.png
  study.png
  progress.png
  settings.png
```

To add more screenshots, simply add entries to `lib/core/constants/assets.dart`
and add `ProjectScreenshot(assetPath: ..., caption: ...)` entries to the project
in `lib/data/repositories/portfolio_repository.dart`. The carousel handles any number automatically.

### 3. Fill in your real info
- `lib/core/constants/strings.dart` — name, bio, tagline
- `lib/core/constants/links.dart` — GitHub, LinkedIn, email, demo URLs
- `lib/data/repositories/portfolio_repository.dart` — project descriptions, case studies

### 4. Run locally
```bash
flutter run -d chrome --web-renderer html
```

### 5. Build for production
```bash
flutter build web --release --web-renderer html
```

Output is in `build/web/`.

## Deploy to Cloudflare Pages

### Option A: Git (auto-deploy on push)
1. Push repo to GitHub
2. Go to Cloudflare Pages → Create application → Connect to Git
3. Select your repo
4. Build settings:
   - **Build command:** `flutter build web --release --web-renderer html`
   - **Build output directory:** `build/web`
   - **Environment variable:** `FLUTTER_VERSION` = `3.22.0` (or latest stable)
5. Deploy

### Option B: Manual drag and drop
1. Build locally: `flutter build web --release --web-renderer html`
2. Go to Cloudflare Pages → Upload assets
3. Drag the `build/web/` folder

The `web/_redirects` file is already configured for SPA routing.

## Structure
```
lib/
  core/
    constants/   ← strings, links, asset paths
    theme/       ← colors, text styles, app theme
    utils/       ← responsive helpers
  data/
    models/      ← Project, CaseStudy, TechChip models
    repositories/ ← PortfolioRepository (your data lives here)
  features/
    home/        ← HomePage, Nav, HeroIntro
    projects/    ← FeaturedProjectSection, ProjectCard, Carousel, TechChip
    case_study/  ← CaseStudyPage (full detail page per project)
  shared/        ← GlassPanel, AeroBackground, AeroButton, dividers
```
