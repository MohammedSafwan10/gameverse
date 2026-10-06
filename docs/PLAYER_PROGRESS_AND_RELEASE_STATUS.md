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

## Release preparation update — 6 October 2026

- Outfit/Inter are bundled with SIL OFL notices; runtime GoogleFonts was removed.
- Settings reads the installed version, uses nexdarksolutions@gmail.com and
  opens the bundled policy naming NexDark Labs.
- Removed confirmed unreferenced top-level TTT/Connect art, old shared MP3s,
  unreachable PremiumBackground and the duplicate example Android activity.
  Live saved-data compatibility and dynamically addressed artwork are retained.
- Flappy uses preloaded licensed PCM pools; result saving is not delayed by audio.
  Resetting stats clears the high-score cache; sound/haptic preferences persist.
- AGP 9.4.0 / Gradle 9.6.0 / Kotlin 2.4.20 debug build passed. The explicit
  compiler override is declared in plugin resolution and root dependencies.
- Analyzer is clean. Full serial suite: **405 passed**. The parallel suite hit
  three Windows test-storage lock collisions; serial execution passed those tests.
- Nine Memory/Flappy/utility goldens were inspected and intentionally reapproved
  with bundled typography and Material icons. No unrelated golden updates.
- A signed 144MB AAB was built earlier with Kotlin 2.4.10; signature and all
  native 64-bit ELF LOAD alignments were verified. Rebuild/validate the final
  release after the final compiler/configuration changes before store upload.
- Version remains **1.0.0+1**, explicitly chosen by the owner. It cannot replace
  the earlier GitHub version-code-2 install without an intentional fresh install.

## Production release gate — not yet certified

Visual redesign completion does not certify production readiness. Outstanding:

1. Owner reviews policy and store disclosures. Publish the selected marketing
   website and `/privacy/` via Coolify; see `WEBSITE_PLAN.md`. Three concepts
   are awaiting selection. No DNS/deployment changes have been made.
2. Verify fonts on a fresh offline release installation, despite bundled assets.
3. Continue screenshot comparison on real devices; passing goldens are not
   release-mode device QA or Play Store approval.
4. Perform release-mode phone smoke tests, persistence after process death,
   fresh install, upgrades, sound/mute and long sessions across all seven games.
   This change's final device check was unavailable: ADB reported no device.
5. Rebuild/validate the final signed AAB, bundletool validation, APK alignment
   and store configuration. No new GitHub release or Play Store upload yet.
6. Complete account-specific Play Console testing/verification and content
   rating, Data safety and target-audience declarations.

See `ANDROID_RELEASE.md` for commands, signing safeguards and compiler details.
