import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_question.dart';
import '../models/quiz_category.dart';
import '../services/quiz_service.dart';
import 'mode_selection_controller.dart';

class QuizMasterController extends GetxController {
  final _quizService = Get.find<QuizService>();

  // Observable states
  final currentQuestion = Rx<QuizQuestion?>(null);
  final selectedAnswer = RxnInt();
  final score = 0.obs;
  final isLoading = false.obs;
  final questions = <QuizQuestion>[].obs;
  final currentQuestionIndex = 0.obs;
  final hasAnswered = false.obs;
  final streak = 0.obs;
  final timeRemaining = 30.obs;

  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> startQuiz({
    required QuizCategory category,
    required String difficulty,
    required QuizMode mode,
  }) async {
    try {
      isLoading.value = true;

      // Get questions for practice mode
      questions.value = await _quizService.getQuestions(
        categoryId: category.id,
        difficulty: difficulty,
        count: 10,
      );

      // Initialize game state
      currentQuestionIndex.value = 0;
      score.value = 0;
      streak.value = 0;
      currentQuestion.value = questions[0];
      hasAnswered.value = false;
      selectedAnswer.value = null;

      // Start timer for first question
      _startTimer();
    } finally {
      isLoading.value = false;
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
    if (hasAnswered.value) return;

    _timer?.cancel(); // Stop timer when answer is selected
    hasAnswered.value = true;
    selectedAnswer.value = selectedIndex;

    final isCorrect = currentQuestion.value?.isCorrect(selectedIndex) ?? false;

    if (isCorrect) {
      streak.value++;
      score.value += _calculatePoints();
    } else {
      streak.value = 0;
    }

    _showAnswerFeedback(isCorrect);
  }

  int _calculatePoints() {
    final basePoints = currentQuestion.value?.points ?? 10;
    final streakBonus = streak.value > 1 ? (streak.value - 1) * 5 : 0;
    final timeBonus = (timeRemaining.value / 30 * 10)
        .round(); // Up to 10 bonus points for speed
    return basePoints + streakBonus + timeBonus;
  }

  void _showAnswerFeedback(bool isCorrect) {
    final points = _calculatePoints();
    final streakBonus = streak.value > 1 ? (streak.value - 1) * 5 : 0;
    final timeBonus = (timeRemaining.value / 30 * 10).round();

    String message = isCorrect
        ? 'Great job! +$points points\n'
        : 'The correct answer was: ${currentQuestion.value?.options[currentQuestion.value?.correctOptionIndex ?? 0]}\n';

    if (isCorrect) {
      if (streakBonus > 0) {
        message += '🔥 Streak bonus: +$streakBonus\n';
      }
      if (timeBonus > 0) {
        message += '⚡ Speed bonus: +$timeBonus';
      }
    }

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

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      currentQuestion.value = questions[currentQuestionIndex.value];
      hasAnswered.value = false;
      selectedAnswer.value = null;
      _startTimer(); // Start timer for next question
    } else {
      _showResults();
    }
  }

  void _showResults() {
    Get.dialog(
      AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: ${score.value}'),
            const SizedBox(height: 8),
            Text('Highest Streak: ${streak.value}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
