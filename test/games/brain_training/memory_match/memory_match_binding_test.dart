import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/brain_training/memory_match/bindings/game_binding.dart';
import 'package:gameverse/games/brain_training/memory_match/services/sound_service.dart';

class _ConnectFourSoundServiceStub extends GetxService {}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test('memory match binding registers its own sound service type', () {
    Get.put<_ConnectFourSoundServiceStub>(_ConnectFourSoundServiceStub());

    MemoryMatchBinding.initDependencies();

    expect(Get.isRegistered<MemoryMatchSoundService>(), isTrue);
    expect(Get.isRegistered<_ConnectFourSoundServiceStub>(), isTrue);
    expect(
      Get.find<MemoryMatchSoundService>(),
      isA<MemoryMatchSoundService>(),
    );
  });

  test('low-latency Memory Match sounds are present and declared', () {
    const soundPaths = [
      'assets/sounds/memory_flip.wav',
      'assets/sounds/memory_match.wav',
      'assets/sounds/memory_miss.wav',
      'assets/sounds/memory_win.wav',
    ];
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final path in soundPaths) {
      final bytes = File(path).readAsBytesSync();
      expect(bytes.length, greaterThan(44), reason: '$path must contain audio');
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
      expect(pubspec, contains('- $path'));
    }
  });
}
