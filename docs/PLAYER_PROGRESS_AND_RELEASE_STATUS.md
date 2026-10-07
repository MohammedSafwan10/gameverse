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
- Analyzer is clean. Final serial suite: **406 passed**. The parallel suite hit
  three Windows test-storage lock collisions; serial execution passed those tests.
- Nine Memory/Flappy/utility goldens were inspected and intentionally reapproved
  with bundled typography and Material icons. No unrelated golden updates.
- The final signed 144MB AAB uses Kotlin 2.4.20 and the owner-approved Play
  package `com.nexdarklabs.gameverse`. Bundletool validation, signature and
  native 64-bit ELF LOAD alignment checks passed. See `PLAY_STORE_LISTING.md`
  for the artifact hash. This is local validation, not Play acceptance.
- Version remains **1.0.0+1**, explicitly chosen by the owner. It cannot replace
  the earlier GitHub version-code-2 install without an intentional fresh install.

## Production release gate — not yet certified

Visual redesign completion does not certify production readiness. Outstanding:

1. Marketing website and `/privacy/` are live at https://gameverse.nexdark.com
   through Coolify. Store listing and declarations are complete, ready for
   review; no publication or release rollout has been submitted.
2. Verify fonts on a fresh offline release installation, despite bundled assets.
3. Continue screenshot comparison on real devices; passing goldens are not
   release-mode device QA or Play Store approval.
4. Perform release-mode phone smoke tests, persistence after process death,
   fresh install, upgrades, sound/mute and long sessions across all seven games.
   This change's final device check was unavailable: ADB reported no device.
5. Upload the locally validated final signed AAB and check Play acceptance.
6. Production access is locked pending a closed test with 12 opted-in testers
   for 14 days. Content rating, Data safety and 13+ audience are saved. Owner
   approval to start the testing workflow and real testers are still required.

See `ANDROID_RELEASE.md` for commands, signing safeguards and compiler details.
