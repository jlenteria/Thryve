# Thryve — intentional progress, made simple

Thryve is a local-first personal growth app for turning a meaningful dream into
small actions. It supports personal and financial goals, milestones, daily
discipline, a visual Wall, weekly reflection, reminders, and appearance/profile
settings.

## Architecture

**MVVM with Provider** — app state lives in `AppViewModel`, while each screen
owns only short-lived form state. User data is persisted as version-compatible
JSON in SharedPreferences, so the app works offline and existing local data is
preserved across upgrades.

| ViewModel | Responsibility |
|-----------|----------------|
| `OnboardingViewModel` | Step index, PageController, name/dream/anchor controllers, focus time |
| `MainShellViewModel` | Bottom-nav tab index |
| `AppViewModel` | Profile, goals, milestones, discipline, Wall, reviews, persistence |
| `WeeklyReviewViewModel` | Vibe rating and reflection form state |

Screens are pure `StatelessWidget` + `Consumer` / `ChangeNotifierProvider`.

```
lib/
├── main.dart
├── theme/app_theme.dart
├── models/models.dart
├── view_models/
│   ├── onboarding_view_model.dart
│   ├── main_shell_view_model.dart
│   ├── home_view_model.dart
│   └── weekly_review_view_model.dart
├── widgets/
│   ├── bottom_nav.dart
│   └── common_widgets.dart
└── screens/
    ├── onboarding/onboarding_flow.dart
    ├── main_shell.dart
    ├── home/home_dashboard.dart
    ├── goals/ (Goals hub, detail, achievement)
    ├── wall/my_wall_screen.dart
    └── review/weekly_review_screen.dart
```

## Run

```bash
cd thryve
flutter pub get
flutter run
```

Requires Flutter 3.16+ and `provider: ^6.1.2`.

## Screens

- Onboarding (3 steps)
- Home Dashboard
- Goals hub / Goal Detail / Goal Achieved
- My Wall
- Weekly Review
- Bottom navigation

Design system: Emerald Clarity (`#006D41`, Inter, soft cards).

## Product flow

- **Home** answers “what matters today?” with the active goal, milestone
  progress, daily practices, and the featured Wall reminder.
- **Goals** separates active work from completed history. Personal goals use
  milestones or an explicit completion action; financial goals can track money.
- **My Wall** is the source of truth for the dashboard reminder. Pin one item
  to feature it, and open an item to edit its image, reflection, category, or
  next action.
- **Weekly Review** turns the week into a lightweight check-in: vibe, wins,
  takeaway, and save.
