# ReadTrack — Functional Build (Local Storage + Gamified Page Updates)

This drop replaces the earlier genre-theme experiment. Genre theming is
parked; everything here is focused on working functionality:

- **Local storage** — books, reading history, and XP/streak stats are
  saved on-device with Hive. No account, no network, nothing to break.
- **Multi-screen app** — Home (dashboard), Bookshelf (all books),
  Add Book, Book Detail (page updates), Profile (stats) — tied together
  with a bottom nav + centered Add button.
- **Add Book screen** has two modes: **Add Manually** (fully working,
  saves locally immediately) and **Search Online** (placeholder UI —
  wires to Open Library once you're ready to add network calls).
- **Friendlier page updates**: big +/‑ stepper with long-press for ±5,
  quick +10/+25/+50 chips, a draggable slider, and a live XP preview on
  the Save button — several ways to update progress depending on how
  precise the user wants to be.
- **Game-like feedback**: every update every page-update is logged
  automatically (`ReadingLog`), earns XP, updates a daily streak, and
  can trigger a confetti burst (at 25/50/75/100% milestones or on
  finishing a book) and a level-up dialog when you cross a threshold.

## 1. Add dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^4.4.0
```

```
flutter pub get
```

No `build_runner` / code generation needed — the Hive adapters in
`data/hive_adapters.dart` are hand-written.

## 2. File map

```
lib/
 ├── main.dart                  → Hive init + app launch
 ├── app_theme.dart              → single consistent app theme
 ├── models/
 │    ├── book.dart
 │    └── reading_log.dart       → ReadingLog + GamificationData + ProgressResult
 ├── data/
 │    ├── hive_adapters.dart     → manual TypeAdapters (no codegen)
 │    ├── book_repository.dart   → local CRUD for books + logs
 │    └── gamification_repository.dart → XP/streak calculation + storage
 ├── providers/
 │    ├── book_provider.dart     → Riverpod state synced with Hive
 │    └── gamification_provider.dart
 ├── screens/
 │    ├── main_shell.dart        → bottom nav + FAB shell
 │    ├── home_screen.dart       → dashboard, Continue Reading cards
 │    ├── bookshelf_screen.dart  → full book list
 │    ├── add_book_screen.dart   → manual entry form (+ online placeholder)
 │    ├── book_detail_screen.dart→ the page-update flow
 │    └── profile_screen.dart    → XP, level, streaks, books finished
 └── widgets/
      ├── animated_progress_bar.dart
      ├── xp_level_bar.dart      → animated XP/level bar, pulses on gain
      ├── streak_badge.dart      → breathing flame icon
      ├── confetti_burst.dart    → custom lightweight confetti (no package)
      └── level_up_dialog.dart   → elastic pop-in celebration
```

## 3. How XP/streak/leveling works (tune freely)

- **XP**: 2 XP per page read, +150 bonus for finishing a book.
- **Level**: level *N* requires *N × 250* cumulative XP (escalating).
- **Streak**: +1 if you log progress on a new calendar day that follows
  the previous active day; resets to 1 if a day is skipped entirely;
  unchanged if you log multiple updates on the same day.
- All of this lives in `gamification_repository.dart` — the formulas
  are isolated there, so balancing them later doesn't touch the UI.

## 4. Known placeholders (intentional, per "functionality first")

- **Online book search** in Add Book — UI exists, API call doesn't yet.
- **Daily reminder notifications** — not included in this pass; can be
  layered on with `flutter_local_notifications` once storage/UI are solid.
- **Book cover images** — using color-block covers derived from the
  title for now instead of real cover art, to avoid pulling in an image
  picker/network dependency before the core loop is validated.
