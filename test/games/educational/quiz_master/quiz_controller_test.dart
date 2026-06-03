import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'dart:async';
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
    required int count,
  }) async {
    return (responses[categoryId] ?? <QuizQuestion>[]).take(count).toList();
  }
}

class _CompleterQuizService implements QuizQuestionLoader {
  final Map<String, Completer<List<QuizQuestion>>> completers = {};

  @override
  Future<List<QuizQuestion>> getQuestions({
    required String categoryId,
    required int count,
  }) {
    return completers.putIfAbsent(categoryId, Completer.new).future;
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
      questionCount: 5,
      mode: QuizMode.practice,
    );

    expect(controller.currentQuestion.value, isNull);
    expect(controller.questions, isEmpty);
  });

  test('answerQuestion awards points once and preserves awarded score', () async {
    final controller = QuizMasterController(
      quizLoader: _FakeQuizService({
        'science': [question(id: '1', correctOptionIndex: 1, points: 10)],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
      statsSaver: ({required QuizCategory category, required int score}) {},
    );

    await controller.startQuiz(
      category: science,
      questionCount: 1,
      mode: QuizMode.practice,
    );

    controller.timeRemaining.value = 15;
    controller.answerQuestion(1);

    expect(controller.score.value, 15);
  });

  test('completeQuiz stores session result with accuracy data', () async {
    final controller = QuizMasterController(
      quizLoader: _FakeQuizService({
        'science': [
          question(id: '1', correctOptionIndex: 1, points: 10),
          question(id: '2', correctOptionIndex: 0, points: 10),
        ],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
      statsSaver: ({required QuizCategory category, required int score}) {},
    );

    await controller.startQuiz(
      category: science,
      questionCount: 2,
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
        'science': [question(id: '1', correctOptionIndex: 1, points: 10)],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
      statsSaver: ({required QuizCategory category, required int score}) {},
    );

    await controller.startQuiz(
      category: science,
      questionCount: 1,
      mode: QuizMode.practice,
    );

    controller.answerQuestion(1);
    controller.completeQuiz();
    expect(controller.isCompleted.value, isTrue);

    await controller.startQuiz(
      category: science,
      questionCount: 1,
      mode: QuizMode.practice,
    );

    expect(controller.isCompleted.value, isFalse);
    expect(controller.sessionResult.value, isNull);
    expect(controller.currentQuestionIndex.value, 0);
  });

  test('stale startQuiz result does not overwrite newer quiz', () async {
    const math = QuizCategory(
      id: 'math',
      name: 'Math',
      description: 'desc',
      icon: Icons.calculate,
      color: Colors.green,
      questionCount: 1,
    );
    final service = _CompleterQuizService();
    final controller = QuizMasterController(
      quizLoader: service,
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
      statsSaver: ({required QuizCategory category, required int score}) {},
    );

    final firstStart = controller.startQuiz(
      category: science,
      questionCount: 1,
      mode: QuizMode.practice,
    );
    final secondStart = controller.startQuiz(
      category: math,
      questionCount: 1,
      mode: QuizMode.practice,
    );

    service.completers['math']!.complete([
      question(id: 'math-1', correctOptionIndex: 0),
    ]);
    await secondStart;

    service.completers['science']!.complete([
      question(id: 'science-1', correctOptionIndex: 1),
    ]);
    await firstStart;

    expect(controller.sessionConfig.value!.category, math);
    expect(controller.currentQuestion.value!.id, 'math-1');
    expect(controller.questions.single.id, 'math-1');
  });

  test('completeQuiz saves stats once even if called repeatedly', () async {
    int updateCalls = 0;
    QuizCategory? savedCategory;
    int? savedScore;

    final controller = QuizMasterController(
      quizLoader: _FakeQuizService({
        'science': [question(id: '1', correctOptionIndex: 1, points: 10)],
      }),
      feedbackPresenter: ({required bool isCorrect, required String message}) {},
      statsSaver: ({required QuizCategory category, required int score}) {
        updateCalls++;
        savedCategory = category;
        savedScore = score;
      },
    );

    await controller.startQuiz(
      category: science,
      questionCount: 1,
      mode: QuizMode.practice,
    );

    controller.timeRemaining.value = 30;
    controller.answerQuestion(1);
    controller.completeQuiz();
    controller.completeQuiz();
    controller.saveSessionStats();

    expect(updateCalls, 1);
    expect(savedCategory, science);
    expect(savedScore, controller.sessionResult.value!.finalScore);
  });
}
