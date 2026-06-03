import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_session_config.dart';
import '../models/quiz_session_result.dart';
import '../models/quiz_question.dart';
import '../models/quiz_category.dart';
import '../services/quiz_service.dart';
import '../services/quiz_question_loader.dart';
import 'mode_selection_controller.dart';

typedef QuizFeedbackPresenter = void Function({
  required bool isCorrect,
  required String message,
});

typedef QuizStatsSaver = void Function({
  required QuizCategory category,
  required int score,
});

class QuizMasterController extends GetxController {
  QuizMasterController({
    QuizQuestionLoader? quizLoader,
    QuizFeedbackPresenter? feedbackPresenter,
    QuizStatsSaver? statsSaver,
  })  : _quizService = quizLoader ?? Get.find<QuizService>(),
        _feedbackPresenter = feedbackPresenter ?? _defaultFeedbackPresenter,
        _statsSaver = statsSaver ?? _defaultStatsSaver;

  final QuizQuestionLoader _quizService;
  final QuizFeedbackPresenter _feedbackPresenter;
  final QuizStatsSaver _statsSaver;

  // Observable states
  final currentQuestion = Rx<QuizQuestion?>(null);
  final selectedAnswer = RxnInt();
  final score = 0.obs;
  final isLoading = false.obs;
  final questions = <QuizQuestion>[].obs;
  final currentQuestionIndex = 0.obs;
  final hasAnswered = false.obs;
  final streak = 0.obs;
  final bestStreak = 0.obs;
  final timeRemaining = 30.obs;
  final sessionConfig = Rxn<QuizSessionConfig>();
  final sessionResult = Rxn<QuizSessionResult>();
  final isCompleted = false.obs;
  final correctAnswers = 0.obs;
  final errorMessage = RxnString();

  Timer? _timer;
  bool _hasSavedStats = false;
  int _quizGeneration = 0;

  @override
  void onClose() {
    _quizGeneration++;
    _timer?.cancel();
    super.onClose();
  }

  Future<void> startQuiz({
    required QuizCategory category,
    required int questionCount,
    required QuizMode mode,
  }) async {
    final generation = ++_quizGeneration;
    _timer?.cancel();

    try {
      isLoading.value = true;
      errorMessage.value = null;
      sessionResult.value = null;
      isCompleted.value = false;
      _hasSavedStats = false;
      sessionConfig.value = QuizSessionConfig(
        category: category,
        questionCount: questionCount,
        mode: mode,
      );

      final loadedQuestions = await _quizService.getQuestions(
        categoryId: category.id,
        count: questionCount,
      );

      if (generation != _quizGeneration) return;
      questions.value = loadedQuestions;

      // Initialize game state
      currentQuestionIndex.value = 0;
      score.value = 0;
      streak.value = 0;
      bestStreak.value = 0;
      correctAnswers.value = 0;
      currentQuestion.value = questions.isEmpty ? null : questions[0];
      hasAnswered.value = false;
      selectedAnswer.value = null;

      if (questions.isNotEmpty) {
        _startTimer();
      } else {
        _timer?.cancel();
        errorMessage.value = 'No questions available for this selection yet.';
      }
    } finally {
      if (generation == _quizGeneration) {
        isLoading.value = false;
      }
    }
  }

  void _startTimer() {
    timeRemaining.value = 30; // Reset timer to 30 seconds
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        timer.cancel();
        if (!hasAnswered.value) {
          // Auto-select wrong answer if time runs out
          answerQuestion(-1);
        }
      }
    });
  }

  void answerQuestion(int selectedIndex) {
    if (hasAnswered.value || currentQuestion.value == null) return;

    _timer?.cancel(); // Stop timer when answer is selected
    hasAnswered.value = true;
    selectedAnswer.value = selectedIndex;

    final isCorrect = currentQuestion.value?.isCorrect(selectedIndex) ?? false;
    final awardedPoints = isCorrect ? _calculatePoints() : 0;

    if (isCorrect) {
      streak.value++;
      if (streak.value > bestStreak.value) {
        bestStreak.value = streak.value;
      }
      correctAnswers.value++;
      score.value += awardedPoints;
    } else {
      streak.value = 0;
    }

    _showAnswerFeedback(isCorrect, awardedPoints);
  }

  int _calculatePoints() {
    final basePoints = currentQuestion.value?.points ?? 10;
    final streakBonus = streak.value > 1 ? (streak.value - 1) * 5 : 0;
    final timeBonus = (timeRemaining.value / 30 * 10)
        .round(); // Up to 10 bonus points for speed
    return basePoints + streakBonus + timeBonus;
  }

  void _showAnswerFeedback(bool isCorrect, int points) {
    final streakBonus = streak.value > 1 ? (streak.value - 1) * 5 : 0;
    final timeBonus = (timeRemaining.value / 30 * 10).round();

    final question = currentQuestion.value;
    final correctIndex = question?.correctOptionIndex ?? -1;
    final correctAnswer = question != null &&
            correctIndex >= 0 &&
            correctIndex < question.options.length
        ? question.options[correctIndex]
        : 'Unknown';

    String message = isCorrect
        ? 'Great job! +$points points\n'
        : 'The correct answer was: $correctAnswer\n';

    if (isCorrect) {
      if (streakBonus > 0) {
        message += '🔥 Streak bonus: +$streakBonus\n';
      }
      if (timeBonus > 0) {
        message += '⚡ Speed bonus: +$timeBonus';
      }
    }

    _feedbackPresenter(
      isCorrect: isCorrect,
      message: message,
    );
  }

  void nextQuestion() {
    if (currentQuestion.value == null) return;

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      currentQuestion.value = questions[currentQuestionIndex.value];
      hasAnswered.value = false;
      selectedAnswer.value = null;
      _startTimer(); // Start timer for next question
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    if (isCompleted.value && sessionResult.value != null) return;

    _timer?.cancel();
    isCompleted.value = true;
    sessionResult.value = QuizSessionResult(
      finalScore: score.value,
      highestStreak: bestStreak.value,
      totalQuestions: questions.length,
      correctAnswers: correctAnswers.value,
    );
    saveSessionStats();
  }

  void saveSessionStats() {
    if (_hasSavedStats) return;

    final config = sessionConfig.value;
    final result = sessionResult.value;
    if (config == null || result == null) return;

    _statsSaver(
      category: config.category,
      score: result.finalScore,
    );
    _hasSavedStats = true;
  }

  static void _defaultStatsSaver({
    required QuizCategory category,
    required int score,
  }) {
    final quizService = Get.find<QuizService>();
    quizService.updateHighScore(
      category: category,
      score: score,
    );
  }

  static void _defaultFeedbackPresenter({
    required bool isCorrect,
    required String message,
  }) {
    Get.snackbar(
      isCorrect ? 'Correct!' : 'Wrong!',
      message,
      backgroundColor: isCorrect ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      borderRadius: 16,
      snackPosition: SnackPosition.TOP,
    );
  }
}
