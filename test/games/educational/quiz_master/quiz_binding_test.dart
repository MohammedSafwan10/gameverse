import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/educational/quiz_master/bindings/quiz_binding.dart';
import 'package:gameverse/games/educational/quiz_master/services/quiz_service.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('QuizMasterBinding registers QuizService', () {
    expect(Get.isRegistered<QuizService>(), isFalse);

    QuizMasterBinding().dependencies();

    expect(Get.isRegistered<QuizService>(), isTrue);
  });
}
