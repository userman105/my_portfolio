# Portfolio — Flutter Web

Aero Glass design. Single-page scrollable portfolio for ChroniCare and CDL A to Z, plus ChroniCare Insights, an interactive diabetes-risk dashboard that accompanies the ChroniCare case study.

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
web/chronicare/diabetes-insights/   ← static interactive dashboard (see below)
tools/           ← build_insights_data.py (regenerates the dashboard data)
```

## ChroniCare Insights (interactive dashboard)

A companion to the ChroniCare case study. ChroniCare tracks one patient's readings; **ChroniCare Insights** zooms out to
253,680 CDC BRFSS 2015 survey respondents and shows which of the same indicators (blood pressure, cholesterol, BMI,
activity, general health) are linked to diabetes. It is built from the analysis in
[Project-Project-3-Healthcare-Predictive-Analytics-Project](https://github.com/userman105/Project-Project-3-Healthcare-Predictive-Analytics-Project).

- **Live page:** `/chronicare/diabetes-insights/` (opened from the ChroniCare case study and the featured project's **Insights** button).
- **Source:** `web/chronicare/diabetes-insights/` (`index.html`, `app.js`, `style.css`, `data.js`). Plain JavaScript and SVG, no
  dependencies and no build step. `flutter build web` copies `web/` into `build/web/` unchanged.
- **Interactivity:** filter by age, sex, education, income and BMI (chips, or click a bar / slice); four pages (Overview, Risk
  factors, Physical & mental health, Demographics); every KPI, chart, heatmap and insight sentence recomputes from the filtered data.
- **Data:** `data.js` packs the survey into ~117k unique respondent combinations with counts (~0.9 MB). Regenerate it with
  `python tools/build_insights_data.py path/to/diabetes_012_health_indicators_BRFSS2015.csv`.
- **Flutter integration:** `InsightsData` (`lib/data/models/project.dart`) is attached to the ChroniCare project in
  `portfolio_repository.dart`; `InsightsPanel` (`lib/features/projects/widgets/insights_panel.dart`) renders it on the case study page.
  Any other project can get the same block by setting its `insights:` field.
- **Preview images:** `assets/images/chronicare/insights/*.webp` are screenshots of the dashboard (PNG originals in
  `web/chronicare/diabetes-insights/preview/`). Retake them if the dashboard changes.

Survey answers are self-reported, so the charts show associations, not diagnoses.
