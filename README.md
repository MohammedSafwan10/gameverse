# GameVerse

GameVerse is an offline-first Flutter collection of seven playable games with a
shared expressive mobile interface.

## Playable games

- Chess
- Tic-Tac-Toe
- Connect Four
- Memory Match
- Block Merge
- Flappy Bird
- Quiz Master

## Current product features

- Local play and AI opponents where supported by the game.
- Per-game settings, saved progress, statistics, and high scores.
- Live local achievements and profile totals from saved game records; no fake
  ranks, XP, leaderboard players or pre-awarded badges. Memory cleared-board
  tracking starts with this update.
- Responsive layouts verified at 320×568, 360×800, 390×844, and 430×932.
- Prepared low-latency sound effects for Memory Match, Chess, board games, and Block Merge.
- Discovery Gallery Quiz Master: five offline topics, quiz-length setup, timed
  questions, inline explanations, results and answer review.
- Resin-themed Block Merge: Classic, three-minute Time Challenge, and untimed Zen;
  swipe animations, one-move undo, a resumable local run, and a 2048 milestone.
- Bundled offline typography; no runtime font downloads.
- Android is the release target. Other Flutter platform folders are retained,
  but are not release-certified.

The app combines shared navigation with game-specific visual themes. It does not require an
account, network connection, Firebase, or cloud services.

Gameplay and bundled fonts work without network requests. A fresh release
installation still needs physical-device smoke testing. The visual redesign is
not a production-readiness certificate.
See [release status](docs/PLAYER_PROGRESS_AND_RELEASE_STATUS.md) for remaining
store, device, typography and test gates.

## Development

Requirements:

- Flutter 3.47.5 / Dart 3.13.4 or compatible newer stable SDK
- Android SDK, Java 17+, AGP 9.4.0, Gradle 9.6.0 and Kotlin 2.4.20

```bash
flutter pub get
flutter run
```

Before handing off a change:

```bash
dart format lib test
flutter analyze
flutter test --concurrency=1 --reporter compact
flutter build apk --debug
```

Detailed design and polish guidance is maintained in:

- `docs/FRONTEND_REDESIGN_PLAN.md`
- `docs/GAME_POLISH_PLAYBOOK.md`
- `docs/AUDIO_ASSETS.md`
- `docs/FONT_ASSETS.md`
- `docs/ANDROID_RELEASE.md` — signing, AAB validation and store gates
- `docs/PRIVACY_POLICY.md` — NexDark Labs' offline-data policy
- `docs/WEBSITE_PLAN.md` — approved website, verification and Coolify deployment

## Marketing website

The responsive static site lives in [`website/`](website/README.md), with the
shared public privacy policy generated from `docs/PRIVACY_POLICY.md`.

```bash
cd website
npm run dev
```

Open http://localhost:4173. Node.js 24 is required; no npm dependencies are
needed. Production uses the root Dockerfile on the owner's existing Coolify
ARM64 server, with a coming-soon Google Play CTA until a listing is published.

## Project structure

```text
lib/
├── main.dart
├── games/
│   ├── brain_training/
│   ├── classic_board/
│   ├── educational/
│   ├── puzzle/
│   └── quick_casual/
├── screens/
├── theme/
└── widgets/
```

## License

See [LICENSE](LICENSE).
