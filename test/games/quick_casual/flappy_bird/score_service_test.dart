import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/models/game_stats.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/services/score_service.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });

    await GetStorage.init();
  });

  setUp(() async {
    await GetStorage().erase();
  });

  test('saveGameStats persists stats and keeps high score in sync', () async {
    final storage = GetStorage();
    final service = ScoreService(storage: storage);

    final stats = GameStats(
      score: 12,
      highScore: 25,
      gamesPlayed: 3,
      totalPlayTime: const Duration(seconds: 40),
      totalPipesPassed: 9,
    );

    await service.saveGameStats(stats);

    final loadedStats = await service.getGameStats();
    final highScore = await service.getHighScore();

    expect(loadedStats.score, 12);
    expect(loadedStats.highScore, 25);
    expect(loadedStats.gamesPlayed, 3);
    expect(loadedStats.totalPlayTime, const Duration(seconds: 40));
    expect(loadedStats.totalPipesPassed, 9);
    expect(highScore, 25);
  });

  test('clearCache removes only Flappy Bird keys', () async {
    final storage = GetStorage();
    final service = ScoreService(storage: storage);

    await storage.write('unrelated_key', 'keep me');
    await service.saveHighScore(18);
    await service.saveGameStats(GameStats(
      score: 10,
      highScore: 18,
      gamesPlayed: 2,
      totalPlayTime: const Duration(seconds: 15),
      totalPipesPassed: 4,
    ));

    await service.clearCache();

    expect(storage.read('unrelated_key'), 'keep me');
    expect(storage.read(GameConstants.highScoreKey), isNull);
    expect(storage.read('flappy_bird_stats'), isNull);
  });

  test('getGameStats returns defaults when stored map is partial', () async {
    final storage = GetStorage();
    final service = ScoreService(storage: storage);

    await storage.write('flappy_bird_stats', <String, dynamic>{
      'gamesPlayed': 5,
    });

    final stats = await service.getGameStats();

    expect(stats.score, 0);
    expect(stats.highScore, 0);
    expect(stats.gamesPlayed, 5);
    expect(stats.totalPlayTime, Duration.zero);
    expect(stats.totalPipesPassed, 0);
  });
}
