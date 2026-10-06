import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gameverse/games/educational/quiz_master/controllers/quiz_controller.dart';
import 'package:gameverse/games/educational/quiz_master/controllers/mode_selection_controller.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_category.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_question.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_answer.dart';
import 'package:gameverse/games/educational/quiz_master/services/quiz_service.dart';
import 'package:gameverse/games/educational/quiz_master/services/quiz_question_loader.dart';
import 'package:gameverse/games/educational/quiz_master/screens/mode_selection_screen.dart';
import 'package:gameverse/games/educational/quiz_master/screens/quiz_screen.dart';
import 'package:gameverse/games/educational/quiz_master/screens/support_screens.dart';

const topic = QuizCategory(
    id: 'science',
    name: 'Science',
    description: '',
    icon: Icons.science,
    color: Colors.blue,
    questionCount: 75);
const sample = QuizQuestion(
    id: 'one',
    question: 'Which planet is known as the Red Planet?',
    options: ['Earth', 'Mars', 'Jupiter', 'Venus'],
    correctOptionIndex: 1,
    explanation: 'Mars looks red because of iron oxide on its surface.',
    category: 'science',
    difficulty: 'Easy',
    points: 10);

class Loader implements QuizQuestionLoader {
  @override
  Future<List<QuizQuestion>> getQuestions(
          {required String categoryId, required int count}) async =>
      [sample];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('quiz-gallery-tests-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => dir.path);
    await GetStorage.init('quiz_stats');
    for (final name in [
      'room',
      'hero',
      'science',
      'history',
      'geography',
      'mathematics',
      'technology',
      'trophy',
      'help',
      'leave'
    ]) {
      expect(
          (await rootBundle.load('assets/images/games/quiz_master/$name.png'))
              .lengthInBytes,
          greaterThan(0));
    }
    for (final entry in {
      'QuizDisplay': 'assets/fonts/DMSerifDisplay-Regular.ttf',
      'BlockResin': 'assets/fonts/Barlow-SemiBold.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf'
    }.entries) {
      final font = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
      await font.load();
    }
  });
  setUp(() {
    Get.testMode = true;
  });
  tearDown(() async {
    Get.reset();
  });
  for (final size in [
    const Size(320, 568),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932)
  ]) {
    for (final state in [
      'menu',
      'setup',
      'play',
      'correct',
      'wrong',
      'timeout',
      'result',
      'review',
      'help',
      'leave'
    ]) {
      testWidgets('$state fits ${size.width}x${size.height}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Get.put(QuizService());
        final c = QuizMasterController(
            quizLoader: Loader(),
            statsSaver: ({required category, required score}) {});
        await c.startQuiz(
            category: topic, questionCount: 1, mode: QuizMode.practice);
        if (state == 'correct' || state == 'result') c.answerQuestion(1);
        if (state == 'wrong') c.answerQuestion(0);
        if (state == 'timeout') {
          c.timeRemaining.value = 0;
          c.answerQuestion(1);
        }
        if (state == 'result') c.nextQuestion();
        c.setPaused(true);
        Widget widget = switch (state) {
          'menu' => const QuizMasterModeSelectionScreen(),
          'setup' => const QuizSetupDialog(category: topic),
          'help' => const QuizHelpScreen(),
          'leave' => const QuizLeaveDialog(),
          'review' => const QuizReviewScreen(answers: [
              QuizAnswer(
                  question: sample,
                  selectedIndex: 0,
                  points: 0,
                  secondsRemaining: 15)
            ], categoryName: 'Science'),
          _ => QuizScreen(
              category: topic,
              questionCount: 1,
              mode: QuizMode.practice,
              controller: c),
        };
        final key = GlobalKey();
        await tester.pumpWidget(
            GetMaterialApp(home: RepaintBoundary(key: key, child: widget)));
        await tester.pump();
        await tester.runAsync(() async =>
            Future<void>.delayed(const Duration(milliseconds: 120)));
        await tester.pump();
        expect(tester.takeException(), isNull);
        if (state == 'menu') {
          for (final label in [
            'Science',
            'History',
            'Geography',
            'Mathematics',
            'Technology',
            'HOW TO PLAY'
          ]) {
            expect(find.text(label), findsOneWidget);
            expect(tester.getRect(find.text(label)).bottom,
                lessThanOrEqualTo(size.height));
          }
        }
        if (size.width == 390 || size.width == 320) {
          await tester.runAsync(() async {
            final boundary = key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            await File('.dart_tool/quiz_${state}_${size.width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox.shrink());
        c.onClose();
      });
    }
  }
  testWidgets('larger text and long question labels remain readable',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.put(QuizService());
    await tester.pumpWidget(GetMaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(
                size: Size(320, 568), textScaler: TextScaler.linear(1.5)),
            child: const QuizMasterModeSelectionScreen())));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
