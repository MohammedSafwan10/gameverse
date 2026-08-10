# GameVerse Frontend Redesign Plan

## Purpose

This document is the source of truth for the GameVerse frontend redesign. Future
agents should read it before changing any screen so the application develops as
one coherent product instead of a collection of unrelated game interfaces.

The redesign is frontend-only unless a screen cannot function without a small,
clearly scoped controller or navigation correction. Existing game logic, saved
data, sounds, scoring, and AI behavior should be preserved.

## Current status

- Visual direction selected: **Material Expressive gaming**, based on Concept 2.
- Home screen: **redesigned and verified**.
- Android toolchain: upgraded and building successfully.
- Next flow: **Memory Match**, beginning with mode selection.
- Total real screens in the repository: **32**.
- Completed: **1**.
- Remaining: **31**.

Primary reference:

- `docs/mockups/gameverse-concept-2-expressive.png`

Home implementation:

- `lib/screens/home/home_screen.dart`

## Product direction

GameVerse should feel playful, premium, energetic, and immediately understandable
to casual mobile gamers. It should look attractive in Play Store screenshots
without sacrificing usability on small Android phones.

Use these principles consistently:

1. Strong hierarchy with one primary action per screen.
2. Warm cream surfaces, vivid orange, cobalt blue, mint, and pink accents.
3. Heavy, friendly display typography with readable supporting text.
4. Tactile rounded cards and restrained soft shadows.
5. Custom game artwork rather than generic gradients or random icons.
6. Compact mobile density: avoid oversized controls and unnecessary empty space.
7. Clear grouping: related controls stay on one line when the reference does.
8. Consistent spacing based primarily on 4, 8, 12, 16, 20, 24, and 32.
9. No clipped text, cropped controls, accidental wrapping, or horizontal overflow.
10. Preserve accessibility semantics and touch targets wherever practical.

## Responsive requirements

Every redesigned screen must be checked at these logical sizes:

- 320 x 568
- 360 x 800
- 390 x 844
- 430 x 932

Home-specific rules that must not regress:

- Three mood chips remain on one row on compact phones.
- Game cards remain a two-column grid below 620 logical pixels.
- The Memory Match hero shows all four tiles without zooming or edge clipping.
- Compact screens use reduced spacing, typography, card height, and navigation
  height rather than switching to oversized one-column cards.
- Bottom navigation respects safe areas.

## Artwork rules

- Store project artwork under `assets/images/` and register its directory in
  `pubspec.yaml`.
- Generate text-free artwork whenever Flutter can render the copy more reliably.
- Reserve deliberate negative space for Flutter text and buttons.
- Keep important subjects away from crop boundaries.
- Do not stretch landscape art into portrait containers.
- Inspect the final rendered screen, not only the source asset.
- Use versioned filenames for artwork revisions instead of silently replacing the
  original source.

Current Home artwork:

- `assets/images/games/memory_match_home_hero_v2.png`
- `assets/images/home/games/`

## Screen inventory and redesign order

### Phase 1: flagship Play Store journey

Complete one polished journey from Home to result before broadening the redesign.

- [x] 1. Home
- [ ] 2. Memory Match mode selection
- [ ] 3. Memory Match gameplay
- [ ] 4. Memory Match completion/result

### Phase 2: shared application surfaces

- [ ] 5. Games/category catalogue
- [ ] 6. Profile
- [ ] 7. Achievements
- [ ] 8. Leaderboard
- [ ] 9. Application settings

The Games catalogue should become a proper browse/discovery destination. The Home
Games navigation item currently scrolls to the Home game grid; revisit this only
when the catalogue redesign is implemented.

### Phase 3: classic board games

Tic-Tac-Toe:

- [ ] 10. Mode selection
- [ ] 11. Gameplay
- [ ] 12. Statistics
- [ ] 13. Settings

Chess:

- [ ] 14. Mode selection
- [ ] 15. Gameplay
- [ ] 16. Settings

Connect Four:

- [ ] 17. Mode selection
- [ ] 18. Gameplay
- [ ] 19. Statistics
- [ ] 20. Settings

### Phase 4: word and puzzle games

Hangman:

- [ ] 21. Mode selection
- [ ] 22. Category selection
- [ ] 23. Word input
- [ ] 24. Gameplay

Block Merge:

- [ ] 25. Mode selection
- [ ] 26. Gameplay
- [ ] 27. Settings

### Phase 5: casual and educational games

Flappy Bird:

- [ ] 28. Mode selection
- [ ] 29. Gameplay
- [ ] 30. Settings

Quiz Master:

- [ ] 31. Mode/category selection
- [ ] 32. Quiz gameplay

## Workflow for each screen

1. Inspect the current screen, its controller, navigation, dialogs, and all states.
2. Identify what must be preserved: logic, data, actions, settings, and edge cases.
3. Create or approve a mockup before a large implementation when the visual
   direction is not already obvious from the established system.
4. Identify required artwork and generate only the assets needed for that screen.
5. Implement the screen using reusable tokens/components where repetition is real.
6. Verify normal, empty, loading, selected, paused, completed, and error states that
   apply to the screen.
7. Add responsive widget tests and a golden for the most representative size.
8. Run formatting, analysis, relevant tests, and an Android debug build when the
   change affects assets, plugins, or platform configuration.
9. Update this checklist immediately after a screen is genuinely completed.

## Definition of done for a screen

A screen is complete only when:

- It follows the selected expressive visual language.
- Its primary and secondary actions work.
- Navigation forward and backward works.
- Existing business/game logic remains intact.
- It has no Flutter layout exceptions at all four required sizes.
- Important content is not hidden behind system or app navigation bars.
- Text scaling and long labels fail gracefully.
- New artwork is project-local and declared in `pubspec.yaml`.
- `flutter analyze` passes.
- Relevant widget/golden tests pass without updating baselines during the final run.

## Verification commands

```powershell
dart format lib test
flutter analyze
flutter test --reporter compact
flutter build apk --debug
```

Focused Home verification:

```powershell
flutter test test\screens\home\home_screen_responsive_test.dart --reporter compact
```

Only use `--update-goldens` after visually inspecting and intentionally accepting a
design change. Run the same tests once more without that flag afterward.

## Android baseline

- Flutter: 3.44.5 at the time of this redesign
- Java/Kotlin JVM target: 17
- Gradle: 8.14.3
- Android Gradle Plugin: 8.13.2
- Kotlin Gradle plugin: 2.4.10

`android.builtInKotlin=false` and `android.newDsl=false` are retained because the
installed Flutter version predates the supported built-in Kotlin migration.

Windows builds use these stability settings in `android/gradle.properties`:

```properties
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
```

They avoid incremental-cache collisions across Flutter plugin modules. They may
make clean builds slightly slower and should not be removed without retesting a
clean Android build on Windows.

## Next exact task

Redesign `MemoryMatchModeSelectionScreen` at:

`lib/games/brain_training/memory_match/screens/mode_selection_screen.dart`

Before implementation, inspect `GameMode`, `GameController`, `GameBinding`, and all
navigation paths from mode selection to gameplay. The result should visually bridge
the Home hero into the Memory Match game using the same rocket/flower tile language,
palette, typography, and compact mobile spacing.

After mode selection, continue directly through gameplay and completion so the
project has one fully polished end-to-end game journey suitable for Play Store
screenshots.
