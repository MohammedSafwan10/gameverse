// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSettings _$GameSettingsFromJson(Map<String, dynamic> json) => GameSettings(
      gameMode: $enumDecodeNullable(_$GameModeEnumMap, json['gameMode']) ??
          GameMode.singlePlayer,
      difficulty:
          $enumDecodeNullable(_$GameDifficultyEnumMap, json['difficulty']) ??
              GameDifficulty.medium,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      showHints: json['showHints'] as bool? ?? false,
      moveDelay: json['moveDelay'] == null
          ? const Duration(milliseconds: 300)
          : Duration(microseconds: (json['moveDelay'] as num).toInt()),
      autoRestart: json['autoRestart'] as bool? ?? false,
      aiDelay: json['aiDelay'] == null
          ? const Duration(milliseconds: 500)
          : Duration(microseconds: (json['aiDelay'] as num).toInt()),
    );

Map<String, dynamic> _$GameSettingsToJson(GameSettings instance) =>
    <String, dynamic>{
      'gameMode': _$GameModeEnumMap[instance.gameMode]!,
      'difficulty': _$GameDifficultyEnumMap[instance.difficulty]!,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'showHints': instance.showHints,
      'moveDelay': instance.moveDelay.inMicroseconds,
      'autoRestart': instance.autoRestart,
      'aiDelay': instance.aiDelay.inMicroseconds,
    };

const _$GameModeEnumMap = {
  GameMode.singlePlayer: 'singlePlayer',
  GameMode.multiPlayer: 'multiPlayer',
  GameMode.online: 'online',
};

const _$GameDifficultyEnumMap = {
  GameDifficulty.easy: 'easy',
  GameDifficulty.medium: 'medium',
  GameDifficulty.hard: 'hard',
  GameDifficulty.impossible: 'impossible',
};
