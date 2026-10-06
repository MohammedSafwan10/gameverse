import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/educational/quiz_master/services/quiz_sound_service.dart';

class FakePlayer implements QuizSoundPlayer {
  int starts = 0, stops = 0, disposals = 0;
  double? volume;
  Completer<StopFunction>? delayed;
  @override
  Future<StopFunction> start(double value) async {
    starts++;
    volume = value;
    return delayed != null
        ? delayed!.future
        : () async {
            stops++;
          };
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('unready cues are skipped, then five independent quiet pools preload',
      () async {
    final players = <String, FakePlayer>{};
    final sound = QuizSoundService(
        createPlayer: (path) async => players[path] = FakePlayer());
    sound.play('tap');
    expect(players, isEmpty);
    await sound.preload();
    await sound.preload();
    expect(players.length, 5);
    sound.play('correct');
    await Future<void>.delayed(Duration.zero);
    final correct = players['sounds/quiz_master/correct.wav']!;
    expect(correct.starts, 1);
    expect(correct.volume, lessThan(.5));
    expect(players['sounds/quiz_master/tap.wav']!.starts, 0);
    sound.muted.value = true;
    sound.play('wrong');
    expect(players['sounds/quiz_master/wrong.wav']!.starts, 0);
    sound.onClose();
    await Future<void>.delayed(Duration.zero);
    expect(players.values.every((p) => p.disposals == 1), true);
  });
  test('suspend stops active audio and blocks future cues', () async {
    final player = FakePlayer();
    final sound = QuizSoundService(createPlayer: (_) async => player);
    await sound.preload();
    sound.play('tap');
    await Future<void>.delayed(Duration.zero);
    sound.suspend(true);
    await Future<void>.delayed(Duration.zero);
    expect(player.stops, 1);
    sound.play('complete');
    expect(player.starts, 1);
    sound.onClose();
  });
  test('late start after disposal is stopped rather than audible', () async {
    final player = FakePlayer()..delayed = Completer<StopFunction>();
    final sound = QuizSoundService(createPlayer: (_) async => player);
    await sound.preload();
    sound.play('complete');
    sound.onClose();
    player.delayed!.complete(() async {
      player.stops++;
    });
    await Future<void>.delayed(Duration.zero);
    expect(player.stops, 1);
    sound.play('correct');
    expect(player.starts, 1);
  });
  test('late preload after disposal releases its newly created player',
      () async {
    final pending = Completer<QuizSoundPlayer>();
    final sound = QuizSoundService(createPlayer: (_) => pending.future);
    final load = sound.preload();
    sound.onClose();
    final player = FakePlayer();
    pending.complete(player);
    await load;
    expect(player.disposals, 1);
    sound.play('tap');
    expect(player.starts, 0);
  });
}
