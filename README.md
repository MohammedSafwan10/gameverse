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
- Responsive layouts verified at 320×568, 360×800, 390×844, and 430×932.
- Prepared low-latency sound effects for Memory Match and Chess.
- Android, iOS, web, Windows, macOS, and Linux Flutter targets.

The app currently uses a single light visual system. It does not require an
account, network connection, Firebase, or cloud services.

## Development

Requirements:

- Flutter SDK compatible with Dart `^3.5.4`
- Android SDK and Java 17 for Android builds

```bash
flutter pub get
flutter run
```

Before handing off a change:

```bash
dart format lib test
flutter analyze
flutter test --reporter compact
flutter build apk --debug
```

Detailed design and polish guidance is maintained in:

- `docs/FRONTEND_REDESIGN_PLAN.md`
- `docs/GAME_POLISH_PLAYBOOK.md`
- `docs/AUDIO_ASSETS.md`

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
