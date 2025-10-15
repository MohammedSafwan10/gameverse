import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'game_mode.dart';
import 'game_difficulty.dart';

part 'game_settings.g.dart';

@JsonSerializable()
class GameSettings extends Equatable {
  final GameMode gameMode;
  final GameDifficulty difficulty;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showHints;
  final Duration moveDelay;
  final bool autoRestart;
  final Duration aiDelay;

  const GameSettings({
    this.gameMode = GameMode.singlePlayer,
    this.difficulty = GameDifficulty.medium,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showHints = false,
    this.moveDelay = const Duration(milliseconds: 300),
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
    bool? showHints,
    Duration? moveDelay,
    bool? autoRestart,
    Duration? aiDelay,
  }) {
    return GameSettings(
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showHints: showHints ?? this.showHints,
      moveDelay: moveDelay ?? this.moveDelay,
      autoRestart: autoRestart ?? this.autoRestart,
      aiDelay: aiDelay ?? this.aiDelay,
    );
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) => _$GameSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$GameSettingsToJson(this);

  @override
  List<Object?> get props => [
        gameMode,
        difficulty,
        soundEnabled,
        vibrationEnabled,
        showHints,
        moveDelay,
        autoRestart,
        aiDelay,
      ];
}
