import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/brain_training/memory_match/bindings/game_binding.dart';
import 'package:gameverse/games/brain_training/memory_match/services/sound_service.dart';

class _ConnectFourSoundServiceStub extends GetxService {}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
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
}
