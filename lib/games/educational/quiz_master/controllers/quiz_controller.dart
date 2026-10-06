import 'dart:async';
import 'package:get/get.dart';
import '../models/quiz_session_config.dart';
import '../models/quiz_session_result.dart';
import '../models/quiz_question.dart';
import '../models/quiz_category.dart';
import '../models/quiz_answer.dart';
import '../services/quiz_service.dart';
import '../services/quiz_question_loader.dart';
import 'mode_selection_controller.dart';

typedef QuizFeedbackPresenter = void Function(
    {required bool isCorrect, required String message});
typedef QuizStatsSaver = void Function(
    {required QuizCategory category, required int score});

class QuizMasterController extends GetxController {
  QuizMasterController(
      {QuizQuestionLoader? quizLoader,
      QuizFeedbackPresenter? feedbackPresenter,
      QuizStatsSaver? statsSaver,
      DateTime Function()? now})
      : _quizService = quizLoader ?? Get.find<QuizService>(),
        _feedbackPresenter = feedbackPresenter ?? _silentFeedback,
        _statsSaver = statsSaver ?? _defaultStatsSaver,
        _now = now ?? _monotonicNow();
  static DateTime Function() _monotonicNow() {
    final watch = Stopwatch()..start();
    return () => DateTime.utc(1970).add(watch.elapsed);
  }

  final QuizQuestionLoader _quizService;
  final QuizFeedbackPresenter _feedbackPresenter;
  final QuizStatsSaver _statsSaver;
  final DateTime Function() _now;
  final currentQuestion = Rx<QuizQuestion?>(null);
  final selectedAnswer = RxnInt();
  final score = 0.obs;
  final isLoading = false.obs;
  final questions = <QuizQuestion>[].obs;
  final answers = <QuizAnswer>[].obs;
  final currentQuestionIndex = 0.obs;
  final hasAnswered = false.obs;
  final streak = 0.obs;
  final bestStreak = 0.obs;
  final timeRemaining = 30.obs;
  final isPaused = false.obs;
  final sessionConfig = Rxn<QuizSessionConfig>();
  final sessionResult = Rxn<QuizSessionResult>();
  final isCompleted = false.obs;
  final correctAnswers = 0.obs;
  final errorMessage = RxnString();
  Timer? _timer;
  DateTime? _lastTick;
  int _remainingMicros = 30000000;
  bool _hasSavedStats = false, _closed = false;
  int _quizGeneration = 0;
  @override
  void onClose() {
    _closed = true;
    _quizGeneration++;
    _timer?.cancel();
    super.onClose();
  }

  Future<void> startQuiz(
      {required QuizCategory category,
      required int questionCount,
      required QuizMode mode}) async {
    if (_closed || isClosed) return;
    final generation = ++_quizGeneration;
    _timer?.cancel();
    isLoading.value = true;
    errorMessage.value = null;
    sessionResult.value = null;
    isCompleted.value = false;
    _hasSavedStats = false;
    questions.clear();
    answers.clear();
    currentQuestion.value = null;
    currentQuestionIndex.value = 0;
    selectedAnswer.value = null;
    hasAnswered.value = false;
    score.value = 0;
    streak.value = 0;
    bestStreak.value = 0;
    correctAnswers.value = 0;
    timeRemaining.value = 30;
    sessionConfig.value = QuizSessionConfig(
        category: category,
        questionCount: questionCount < 1 ? 1 : questionCount,
        mode: mode);
    try {
      final loaded = await _quizService.getQuestions(
          categoryId: category.id,
          count: questionCount < 1 ? 1 : questionCount);
      if (_closed || generation != _quizGeneration) return;
      final ids = <String>{};
      questions.assignAll(loaded.where((q) =>
          q.question.trim().isNotEmpty &&
          q.options.length >= 2 &&
          q.options.every((o) => o.trim().isNotEmpty) &&
          q.correctOptionIndex >= 0 &&
          q.correctOptionIndex < q.options.length &&
          q.points >= 0 &&
          ids.add(q.id)));
      if (questions.isEmpty) {
        errorMessage.value = 'No questions available for this topic.';
      } else {
        currentQuestion.value = questions.first;
        _startTimer();
      }
    } catch (_) {
      if (!_closed && generation == _quizGeneration) {
        errorMessage.value = 'Could not load this quiz. Please try again.';
      }
    } finally {
      if (!_closed && generation == _quizGeneration) {
        isLoading.value = false;
      }
    }
  }

  void _startTimer() {
    timeRemaining.value = 30;
    _remainingMicros = 30000000;
    _lastTick = _now();
    _timer?.cancel();
    _timer = Timer.periodic(
        const Duration(milliseconds: 100), (_) => _settleClock());
  }

  void _settleClock() {
    if (_closed ||
        isPaused.value ||
        hasAnswered.value ||
        isCompleted.value ||
        currentQuestion.value == null) {
      return;
    }
    final now = _now();
    final delta = now.difference(_lastTick ?? now).inMicroseconds;
    _lastTick = now;
    _remainingMicros = _remainingMicros.clamp(0, timeRemaining.value * 1000000);
    _remainingMicros =
        (_remainingMicros - delta.clamp(0, 30000000)).clamp(0, 30000000);
    timeRemaining.value = (_remainingMicros / 1000000).ceil();
    if (_remainingMicros == 0) {
      _recordAnswer(-1);
    }
  }

  void setPaused(bool value) {
    if (_closed || isPaused.value == value) return;
    if (value) {
      _settleClock();
    }
    isPaused.value = value;
    _lastTick = _now();
  }

  void answerQuestion(int selectedIndex) {
    final q = currentQuestion.value;
    if (_closed ||
        isLoading.value ||
        isCompleted.value ||
        isPaused.value ||
        hasAnswered.value ||
        q == null ||
        selectedIndex < 0 ||
        selectedIndex >= q.options.length) {
      return;
    }
    _settleClock();
    if (!hasAnswered.value) {
      _recordAnswer(selectedIndex);
    }
  }

  void _recordAnswer(int index) {
    final q = currentQuestion.value;
    if (q == null || hasAnswered.value || _closed) return;
    _timer?.cancel();
    hasAnswered.value = true;
    selectedAnswer.value = index;
    final correct = q.isCorrect(index);
    int points = 0;
    if (correct) {
      streak.value++;
      bestStreak.value =
          bestStreak.value < streak.value ? streak.value : bestStreak.value;
      correctAnswers.value++;
      points = q.points +
          (streak.value - 1) * 5 +
          (timeRemaining.value / 30 * 10).round();
      score.value += points;
    } else {
      streak.value = 0;
    }
    answers.add(QuizAnswer(
        question: q,
        selectedIndex: index,
        points: points,
        secondsRemaining: timeRemaining.value));
    _feedbackPresenter(
        isCorrect: correct,
        message: correct
            ? '+$points points'
            : 'Correct answer: ${q.options[q.correctOptionIndex]}');
  }

  void nextQuestion() {
    if (_closed ||
        isPaused.value ||
        isLoading.value ||
        isCompleted.value ||
        !hasAnswered.value ||
        currentQuestion.value == null) {
      return;
    }
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      currentQuestion.value = questions[currentQuestionIndex.value];
      selectedAnswer.value = null;
      hasAnswered.value = false;
      _startTimer();
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    if (_closed ||
        isLoading.value ||
        isCompleted.value ||
        questions.isEmpty ||
        answers.length != questions.length ||
        !hasAnswered.value) {
      return;
    }
    _timer?.cancel();
    isCompleted.value = true;
    sessionResult.value = QuizSessionResult(
        finalScore: score.value,
        highestStreak: bestStreak.value,
        totalQuestions: questions.length,
        correctAnswers: correctAnswers.value);
    saveSessionStats();
  }

  void saveSessionStats() {
    if (_hasSavedStats) return;
    final config = sessionConfig.value, result = sessionResult.value;
    if (config == null || result == null) return;
    _hasSavedStats = true;
    try {
      _statsSaver(category: config.category, score: result.finalScore);
    } catch (_) {
      _hasSavedStats = false;
      errorMessage.value = 'This result could not be saved. You can retry.';
    }
  }

  static void _defaultStatsSaver(
      {required QuizCategory category, required int score}) {
    Get.find<QuizService>().updateHighScore(category: category, score: score);
  }

  static void _silentFeedback(
      {required bool isCorrect, required String message}) {}
}
