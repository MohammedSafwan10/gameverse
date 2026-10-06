# Real player progress and release status

## Shared screens (October 2026)

- Profile and Achievements share `PlayerProgressStore`, initialized before app
  launch. It listens to the default GetStorage container and `quiz_stats` and
  recomputes progress when records change. It does not start game controllers.
- Existing Chess, Tic-Tac-Toe, Connect Four, Block Merge, Flappy Bird and Quiz
  records are reused without rewriting them. JSON Tic-Tac-Toe records and map
  records are supported; malformed/negative counters become zero.
- Memory Match previously persisted no statistics. Cleared boards now increment
  `memory_match_stats.completed` when the final match resolves, including a match
  resolving while paused. Resuming/reopening results does not award it twice.
  Old Memory sessions cannot be recovered or credited retroactively.
- Profile WINS means recorded winning rounds/cleared boards on this device,
  including either human winner in local two-player matches. RECORDED totals
  existing per-game play counters plus Memory cleared boards; it is not a new
  uniform completed-session event ledger. Quiz and endless Flappy have no wins.
- Badges: first recorded win; play records in three games; first finished quiz;
  ten cleared Memory boards; Flappy best of 25 pipes; Merge highest tile 128;
  records in seven games; fifty winning rounds/cleared boards; other eight badges.
- Badge progress is derived from current local records. Resetting a game's
  statistics can relock dependent badges. No synthetic XP, rank or member date.
- Game History and Support Center were removed from Profile (not Settings).
  The unreferenced fake leaderboard screen and route were deleted. Settings
  retains email contact and a truthful local-data explanation, not pretend legal
  policies, pretend rating actions or fabricated storage usage.
- Games is intentionally a Home catalogue shortcut: clears mood filters and
  scrolls to all seven games. Home scrolls back to the top. A separate catalogue
  is optional future product work, not a missing required gameplay screen.
- Approved mockups and design documentation remain as implementation references;
  they are not runtime mock data and should not be deleted as dead assets.

## Production release gate — not yet certified

Visual redesign completion does not certify production readiness. Outstanding:

1. Publish and review a real privacy policy / store disclosures before Play Store
   submission. The local-data dialog is product information, not a legal policy.
2. Verify fonts on a fresh offline release installation. Shared AppTheme and
   Memory theme still use runtime GoogleFonts without bundled Outfit/Inter fonts;
   production manifest has no Internet permission. Do not assume debug font cache
   behavior proves offline font availability.
3. Resolve or visually reapprove the pre-existing Memory/Flappy golden failures;
   do not mass-update their baselines to hide unrelated regressions.
4. Perform release-mode phone smoke tests, persistence after process death,
   fresh install, upgrades, sound/mute and long sessions across all seven games.
   This change's final device check was unavailable: ADB reported no device.
5. Verify signed release APK/AAB and store configuration separately. This pass
   builds debug only, not a new GitHub release or Play Store upload.
6. Android currently builds but Flutter warns about future minimum Gradle/AGP
   versions. Plan a separate compatible toolchain upgrade, not a silent migration.

Validation: 30 focused tests passed, `flutter analyze --no-pub` passed, and one
Android debug build passed. Full serial suite: 394 passed, six pre-existing
Memory/Flappy screenshot goldens failed. Updated only the three shared utility
goldens intentionally changed here, inspecting their geometry; those goldens use
Flutter test fonts, not real device typography.
