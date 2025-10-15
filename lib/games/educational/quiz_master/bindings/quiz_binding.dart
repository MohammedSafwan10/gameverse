import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/mode_selection_controller.dart';
import '../services/quiz_service.dart';
import 'dart:developer' as dev;

class QuizMasterBinding extends Bindings {
  @override
  void dependencies() {
    dev.log('Initializing Quiz Master dependencies', name: 'QuizMaster');

    // Services
    Get.lazyPut<QuizService>(() => QuizService(), fenix: true);

    // Controllers
    Get.lazyPut<QuizMasterController>(() => QuizMasterController(),
        fenix: true);
    Get.lazyPut<ModeSelectionController>(() => ModeSelectionController(),
        fenix: true);

    dev.log('Quiz Master dependencies initialized', name: 'QuizMaster');
  }
}
