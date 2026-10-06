import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/educational/quiz_master/controllers/quiz_controller.dart';
import 'package:gameverse/games/educational/quiz_master/controllers/mode_selection_controller.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_category.dart';
import 'package:gameverse/games/educational/quiz_master/models/quiz_question.dart';
import 'package:gameverse/games/educational/quiz_master/services/quiz_question_loader.dart';
import 'package:gameverse/games/educational/quiz_master/data/science_questions.dart';
import 'package:gameverse/games/educational/quiz_master/data/history_questions.dart';
import 'package:gameverse/games/educational/quiz_master/data/geography_questions.dart';
import 'package:gameverse/games/educational/quiz_master/data/mathematics_questions.dart';
import 'package:gameverse/games/educational/quiz_master/data/technology_questions.dart';

const topic = QuizCategory(
    id: 'science',
    name: 'Science',
    description: '',
    icon: Icons.science,
    color: Colors.blue,
    questionCount: 10);
const q = QuizQuestion(
    id: 'one',
    question: 'Red planet?',
    options: ['Earth', 'Mars', 'Venus', 'Jupiter'],
    correctOptionIndex: 1,
    explanation: 'Iron oxide.',
    category: 'science',
    difficulty: 'Easy',
    points: 10);

class Loader implements QuizQuestionLoader {
  Loader(this.rows, {this.fail = false});
  final List<QuizQuestion> rows;
  final bool fail;
  @override
  Future<List<QuizQuestion>> getQuestions(
      {required String categoryId, required int count}) async {
    if (fail) throw StateError('offline failure');
    return rows.take(count).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  QuizMasterController make(
      {List<QuizQuestion> rows = const [q],
      bool fail = false,
      DateTime Function()? now}) {
    final c = QuizMasterController(
        quizLoader: Loader(rows, fail: fail),
        now: now,
        statsSaver: ({required category, required score}) {});
    addTearDown(c.onClose);
    return c;
  }

  Future<void> start(QuizMasterController c) =>
      c.startQuiz(category: topic, questionCount: 10, mode: QuizMode.practice);
  test('invalid answer, early next and early completion leave quiz unchanged',
      () async {
    final c = make();
    await start(c);
    c.nextQuestion();
    c.completeQuiz();
    c.answerQuestion(-1);
    c.answerQuestion(9);
    expect(c.answers, isEmpty);
    expect(c.currentQuestionIndex.value, 0);
    expect(c.isCompleted.value, false);
    expect(c.hasAnswered.value, false);
    c.answerQuestion(1);
    c.answerQuestion(0);
    expect(c.answers.length, 1);
    expect(c.score.value, 20);
  });
  test('load failure is surfaced with retryable state', () async {
    final c = make(fail: true);
    await start(c);
    expect(c.isLoading.value, false);
    expect(c.currentQuestion.value, null);
    expect(c.errorMessage.value, contains('try again'));
  });
  test('duplicate payload ids are rejected', () async {
    final c = make(rows: [q, q]);
    await start(c);
    expect(c.questions.length, 1);
  });
  test('review snapshots and streak reset stay correct across mixed answers',
      () async {
    final second = QuizQuestion(
        id: 'two',
        question: 'Another?',
        options: q.options,
        correctOptionIndex: 1,
        explanation: 'Why',
        category: 'science',
        difficulty: 'Hard',
        points: 20);
    final c = make(rows: [q, second]);
    await start(c);
    c.answerQuestion(1);
    c.nextQuestion();
    c.answerQuestion(0);
    c.nextQuestion();
    expect(c.answers.map((a) => a.selectedIndex), [1, 0]);
    expect(c.answers.map((a) => a.points), [20, 0]);
    expect(c.streak.value, 0);
    expect(c.bestStreak.value, 1);
    expect(c.sessionResult.value!.accuracy, .5);
    c.nextQuestion();
    c.answerQuestion(1);
    expect(c.answers.length, 2);
  });
  test(
      'timeout occurs at exactly 30 active seconds, pause preserves fractional time',
      () {
    fakeAsync((async) {
      var now = DateTime.utc(2026);
      final c = make(now: () => now);
      start(c);
      async.flushMicrotasks();
      now = now.add(const Duration(milliseconds: 750));
      c.setPaused(true);
      now = now.add(const Duration(minutes: 3));
      async.elapse(const Duration(seconds: 2));
      expect(c.timeRemaining.value, 30);
      expect(c.answers, isEmpty);
      c.setPaused(false);
      now = now.add(const Duration(milliseconds: 29250));
      async.elapse(const Duration(milliseconds: 100));
      expect(c.timeRemaining.value, 0);
      expect(c.answers.single.timedOut, true);
      expect(c.score.value, 0);
      expect(c.isCompleted.value, false);
      c.nextQuestion();
      expect(c.isCompleted.value, true);
      c.onClose();
    });
  });
  test('delayed callback cannot accept a late correct answer', () async {
    var now = DateTime.utc(2026);
    final c = make(now: () => now);
    await start(c);
    now = now.add(const Duration(seconds: 40));
    c.answerQuestion(1);
    expect(c.answers.single.timedOut, true);
    expect(c.score.value, 0);
  });
  test('paused and closed controllers reject inputs and late loads', () async {
    final c = make();
    await start(c);
    c.setPaused(true);
    c.answerQuestion(1);
    expect(c.answers, isEmpty);
    c.setPaused(false);
    c.onClose();
    c.answerQuestion(1);
    expect(c.answers, isEmpty);
  });
  for (final bank in [
    scienceQuestions,
    historyQuestions,
    geographyQuestions,
    mathematicsQuestions,
    technologyQuestions
  ]) {
    test(
        'question bank ${bank.first.category} valid across all stored difficulties',
        () {
      expect(bank.map((q) => q.id).toSet().length, bank.length);
      for (final item in bank) {
        expect(item.question.trim(), isNotEmpty);
        expect(item.options.length, greaterThanOrEqualTo(2));
        expect(item.correctOptionIndex,
            inInclusiveRange(0, item.options.length - 1));
        expect(item.points, greaterThanOrEqualTo(0));
        expect(item.explanation.trim(), isNotEmpty);
      }
    });
  }
}
