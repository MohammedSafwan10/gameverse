import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/services/audio_service.dart';

class FakePlayer implements FlappyCuePlayer {
  int starts = 0, stops = 0, disposals = 0;
  Completer<StopFunction>? delayed;
  @override
  Future<StopFunction> start(double volume) async {
    starts++;
    return delayed == null
        ? () async {
            stops++;
          }
        : await delayed!.future;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

void main() {
  test('unready effects are skipped, never replayed after preload', () async {
    final player = FakePlayer();
    final audio =
        FlappyAudio(enabled: () => true, createPlayer: (_) async => player);
    audio.play('flap');
    await audio.preload();
    expect(player.starts, 0);
    await audio.dispose();
  });
  test('mute and pause gate effects; rapid cues return prior players',
      () async {
    var enabled = true;
    final player = FakePlayer();
    final audio =
        FlappyAudio(enabled: () => enabled, createPlayer: (_) async => player);
    await audio.preload();
    for (var i = 0; i < 100; i++) {
      audio.play('flap');
      await Future<void>.delayed(Duration.zero);
    }
    expect(player.starts, 100);
    expect(player.stops, 99);
    enabled = false;
    audio.play('point');
    expect(player.starts, 100);
    audio.pause(true);
    enabled = true;
    audio.play('hit');
    expect(player.starts, 100);
    await audio.dispose();
    expect(player.stops, 100);
  });
  test('a start finishing after disposal is stopped before pool disposal',
      () async {
    final player = FakePlayer()..delayed = Completer<StopFunction>();
    final audio =
        FlappyAudio(enabled: () => true, createPlayer: (_) async => player);
    await audio.preload();
    audio.play('flap');
    final disposed = audio.dispose();
    player.delayed!.complete(() async {
      player.stops++;
    });
    await disposed;
    expect(player.stops, 1);
    expect(player.disposals, 3);
  });
}
