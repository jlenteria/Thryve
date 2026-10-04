# Thryve — intentional progress, made simple

Thryve is a local-first personal growth app for turning a meaningful dream into
small daily actions. It supports personal (milestone) and financial goals, daily
practices with a real streak, a visual Wall, weekly reflection, daily reminders,
and light/dark appearance. Everything stays on the device.

## Run

```bash
flutter pub get
flutter run
```

Requires Dart 3.12+ (Flutter stable). Checks:

```bash
flutter analyze   # strict lint set in analysis_options.yaml
flutter test
```

## Architecture

**Feature-first MVVM with Provider.** App-wide state lives in one
`AppViewModel`; screens render it and forward input. Short-lived form state
lives in screen-scoped view models or `StatefulWidget`s.

```
lib/
├── main.dart                 # bootstrap: notifications + image storage
├── app.dart                  # providers, theme, onboarding/shell gate
├── core/
│   ├── constants/            # storage keys, ids
│   ├── extensions/           # context.colors / context.text / showSnack
│   ├── services/             # NotificationService, ImageStore, ReminderCopy
│   ├── state/                # AppViewModel (business rules), ViewModel base
│   ├── theme/                # color schemes (light + dark), ThemeData, ThemeManager
│   ├── utils/                # dates, formatting, streak calculation
│   └── widgets/              # cards, buttons, sheets, page scaffolds, images
├── data/
│   ├── models/               # immutable models with JSON (+ v1 migration)
│   └── repositories/         # AppStateRepository (SharedPreferences)
└── features/
    ├── onboarding/           # 3 steps: name & dream → anchor → reminder time
    ├── shell/                # bottom navigation
    ├── home/                 # focus goal, today's practices, Wall reminder
    ├── goals/                # hub, detail, achievement, goal & milestone sheets
    ├── wall/                 # inspiration Wall and editor
    ├── review/               # weekly check-in + history
    └── settings/             # profile, appearance, reminders, reset
```

| Layer | Responsibility |
|-------|----------------|
| `AppViewModel` | Profile, goals, milestones, practices, Wall, reviews, streak/activity, day rollover, reminder sync |
| `AppStateRepository` | One JSON document in SharedPreferences; serialized writes; corrupt data is backed up, never crashes |
| `OnboardingViewModel` | Step navigation, validation, anchor image, reminder time |
| `WeeklyReviewViewModel` | This week's rating and reflection form |
| `MainShellViewModel` | Selected tab (`context.goToTab(...)`) |

### Rules worth knowing

- **Achievement** — a goal completes when all its milestones are completed
  or a money goal reaches its target. It can also be marked complete by hand,
  or reopened.
- **Focus goal** — Home shows the first active goal. Use *Make focus goal* on
  any goal to move it there.
- **Streak** — counts consecutive days with at least one action (practice
  checked, milestone completed, earnings logged). Today counts once you act,
  and yesterday's streak holds until then.
- **Daily practices** — checkmarks reset when the day changes, including when
  the app comes back to the foreground.
- **Weekly review** — one entry per Monday–Sunday week. Past weeks are kept.
- **Images** — picked photos are copied to the app documents folder and
  stored as `local:<file>` references (portable across iOS container moves).
  Replaced and removed images are deleted. Older base64 entries still render.
- **Reminders** — scheduled in the device's timezone. The notification text
  is the same `ReminderCopy` shown in the onboarding preview.

## Design system

Emerald Clarity (light) / Emerald Nocturne (dark), built from full Material 3
`ColorScheme`s in `core/theme/app_colors.dart`. Widgets read colors through
`context.colors`, never constants, so every screen follows the selected
theme. Typeface: **Geist**, bundled in `assets/fonts` (no runtime download).

## Data compatibility

State saved by the earlier build (schema v1) loads unchanged. The migration
covers the string focus time, flag-only achievement, the single weekly review,
and the `imageUrl`/`avatarUrl` keys. See `test/data/app_state_migration_test.dart`.
