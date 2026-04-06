import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/educational/quiz_master/controllers/mode_selection_controller.dart';
import 'package:gameverse/games/educational/quiz_master/controllers/quiz_controller.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_category.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_question.dart';
import 'package:gameverse/games/educational/quiz_master/services/quiz_question_loader.dart';
import 'package:flutter/material.dart';

class _FakeQuizService implements QuizQuestionLoader {
  _FakeQuizService(this.responses);

  final Map<String, List<QuizQuestion>> responses;

  @override
  Future<List<QuizQuestion>> getQuestions({
    required String categoryId,
    required String difficulty,
    required int count,
  }) async {
    return responses['$categoryId|$difficulty'] ?? <QuizQuestion>[];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const science = QuizCategory(
    id: 'science',
    name: 'Science',
    description: 'desc',
    icon: Icons.science,
    color: Colors.blue,
    difficulties: ['Easy'],
    questionCount: 1,
  );

  QuizQuestion question({
    required String id,
    required int correctOptionIndex,
    int points = 10,
  }) {
    return QuizQuestion(
      id: id,
      question: 'Question $id',
      options: const ['A', 'B', 'C', 'D'],
      correctOptionIndex: correctOptionIndex,
      explanation: 'Explanation',
      category: 'science',
      difficulty: 'Easy',
      points: points,
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('startQuiz handles empty question lists without throwing', () async {
    final controller = QuizMasterController(quizLoader: _FakeQuizService({}));

    await controller.startQuiz(
      category: science,
      difficulty: 'Easy',
      mode: QuizMode.practice,
    );

    expect(controller.currentQuestion.value, isNull);
    expect(controller.questions, isEmpty);
  });

  test('answerQuestion awards points once and preserves awarded score', () async {
    final controller = QuizMasterController(
      quizLoader: _FakeQuizService({
        'science|Easy': [question(id: '1', correctOptionIndex: 1, points: 10)],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
    );

    await controller.startQuiz(
      category: science,
      difficulty: 'Easy',
      mode: QuizMode.practice,
    );

    controller.timeRemaining.value = 15;
    controller.answerQuestion(1);

    expect(controller.score.value, 15);
  });

  test('completeQuiz stores session result with accuracy data', () async {
    final controller = QuizMasterController(
      quizLoader: _FakeQuizService({
        'science|Easy': [
          question(id: '1', correctOptionIndex: 1, points: 10),
          question(id: '2', correctOptionIndex: 0, points: 10),
        ],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
    );

    await controller.startQuiz(
      category: science,
      difficulty: 'Easy',
      mode: QuizMode.practice,
    );

    controller.timeRemaining.value = 30;
    controller.answerQuestion(1);
    controller.nextQuestion();
    controller.answerQuestion(2);
    controller.completeQuiz();

    expect(controller.sessionResult.value, isNotNull);
    expect(controller.sessionResult.value!.finalScore, 20);
    expect(controller.sessionResult.value!.correctAnswers, 1);
    expect(controller.sessionResult.value!.totalQuestions, 2);
    expect(controller.sessionResult.value!.accuracy, 0.5);
  });

  test('startQuiz resets completed state for play again flow', () async {
    final controller = QuizMasterController(
      quizLoader: _FakeQuizService({
        'science|Easy': [question(id: '1', correctOptionIndex: 1, points: 10)],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
    );

    await controller.startQuiz(
      category: science,
      difficulty: 'Easy',
      mode: QuizMode.practice,
    );

    controller.answerQuestion(1);
    controller.completeQuiz();
    expect(controller.isCompleted.value, isTrue);

    await controller.startQuiz(
      category: science,
      difficulty: 'Easy',
      mode: QuizMode.practice,
    );

    expect(controller.isCompleted.value, isFalse);
    expect(controller.sessionResult.value, isNull);
    expect(controller.currentQuestionIndex.value, 0);
  });
}
