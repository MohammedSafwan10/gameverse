import 'package:equatable/equatable.dart';
import 'game_mode.dart';
import 'game_difficulty.dart';

class GameSettings extends Equatable {
  final GameMode gameMode;
  final GameDifficulty difficulty;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoRestart;
  final Duration aiDelay;

  const GameSettings({
    this.gameMode = GameMode.singlePlayer,
    this.difficulty = GameDifficulty.medium,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoRestart = false,
    this.aiDelay = const Duration(milliseconds: 500),
  });

  factory GameSettings.initial() {
    return const GameSettings();
  }

  GameSettings copyWith({
    GameMode? gameMode,
    GameDifficulty? difficulty,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoRestart,
    Duration? aiDelay,
  }) {
    return GameSettings(
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoRestart: autoRestart ?? this.autoRestart,
      aiDelay: aiDelay ?? this.aiDelay,
    );
  }

  @override
  List<Object?> get props => [
        gameMode,
        difficulty,
        soundEnabled,
        vibrationEnabled,
        autoRestart,
        aiDelay,
      ];
}
