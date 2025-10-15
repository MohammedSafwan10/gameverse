import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/quiz_category.dart';
import '../models/quiz_question.dart';
import '../data/science_questions.dart';
import '../data/history_questions.dart';
import '../data/geography_questions.dart';
import '../data/mathematics_questions.dart';
import '../data/technology_questions.dart';

class QuizService extends GetxService {
  final _storage = GetStorage('quiz_stats');

  // Observable states
  final selectedCategory = Rx<QuizCategory?>(null);
  final questions = <QuizQuestion>[].obs;
  final isLoading = false.obs;

  // Observable states for stats with persistence
  late final RxInt totalQuestionsAnswered;
  late final RxMap<String, int> highScores;
  late final RxDouble winRate;

  @override
  void onInit() {
    super.onInit();
    // Initialize stats from storage or default values
    totalQuestionsAnswered =
        RxInt(_storage.read('totalQuestionsAnswered') ?? 0);
    highScores = RxMap<String, int>(_storage.read('highScores') ?? {});
    winRate = RxDouble(_storage.read('winRate') ?? 0.0);
  }

  // Categories with real questions for offline use
  final categories = <QuizCategory>[
    QuizCategory(
      id: 'science',
      name: 'Science',
      description: 'Test your knowledge in physics, chemistry, and biology',
      icon: Icons.science_rounded,
      color: Colors.blue,
      difficulties: ['Easy', 'Medium', 'Hard'],
      questionCount: scienceQuestions.length,
    ),
    QuizCategory(
      id: 'history',
      name: 'History',
      description: 'Explore world history and historical events',
      icon: Icons.history_edu_rounded,
      color: Colors.red,
      difficulties: ['Easy', 'Medium', 'Hard'],
      questionCount: historyQuestions.length,
    ),
    QuizCategory(
      id: 'geography',
      name: 'Geography',
      description: 'Learn about countries, capitals, and landmarks',
      icon: Icons.public_rounded,
      color: Colors.green,
      difficulties: ['Easy', 'Medium', 'Hard'],
      questionCount: geographyQuestions.length,
    ),
    QuizCategory(
      id: 'mathematics',
      name: 'Mathematics',
      description: 'Challenge yourself with math problems',
      icon: Icons.calculate_rounded,
      color: Colors.indigo,
      difficulties: ['Easy', 'Medium', 'Hard'],
      questionCount: mathematicsQuestions.length,
    ),
    QuizCategory(
      id: 'technology',
      name: 'Technology',
      description: 'Stay updated with tech knowledge',
      icon: Icons.computer_rounded,
      color: Colors.purple,
      difficulties: ['Easy', 'Medium', 'Hard'],
      questionCount: technologyQuestions.length,
    ),
  ];

  // Question bank mapping
  final Map<String, List<QuizQuestion>> _questionsBank = {
    'science': scienceQuestions,
    'history': historyQuestions,
    'geography': geographyQuestions,
    'mathematics': mathematicsQuestions,
    'technology': technologyQuestions,
  };

  // Get questions for a category and difficulty
  Future<List<QuizQuestion>> getQuestions({
    required String categoryId,
    required String difficulty,
    required int count,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading

      final questions = _questionsBank[categoryId] ?? [];
      final filteredQuestions =
          questions.where((q) => q.difficulty == difficulty).toList();
      filteredQuestions.shuffle(); // Randomize questions

      return filteredQuestions.take(count).toList();
    } finally {
      isLoading.value = false;
    }
  }

  // Get daily challenge questions
  Future<List<QuizQuestion>> getDailyChallengeQuestions() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      // Mix questions from different categories for daily challenge
      final allQuestions = _questionsBank.values.expand((q) => q).toList();
      allQuestions.shuffle();

      return allQuestions.take(10).toList();
    } finally {
      isLoading.value = false;
    }
  }

  // Update high score for a category and difficulty
  void updateHighScore({
    required QuizCategory category,
    required String difficulty,
    required int score,
  }) {
    final key = '${category.id}_${difficulty.toLowerCase()}';
    final currentHighScore = highScores[key] ?? 0;

    if (score > currentHighScore) {
      highScores[key] = score;
      _storage.write('highScores', highScores);
    }

    // Update total questions and win rate
    totalQuestionsAnswered.value++;
    _storage.write('totalQuestionsAnswered', totalQuestionsAnswered.value);

    // Calculate and update win rate
    final totalHighScores =
        highScores.values.fold(0, (sum, score) => sum + score);
    if (totalQuestionsAnswered.value > 0) {
      winRate.value = totalHighScores /
          (totalQuestionsAnswered.value * 30); // 30 is max points per question
      _storage.write('winRate', winRate.value);
    }

    // Force refresh of observables
    highScores.refresh();
    totalQuestionsAnswered.refresh();
    winRate.refresh();
  }

  // Get high score for a category and difficulty
  int getHighScore(String categoryId, String difficulty) {
    final key = '${categoryId}_${difficulty.toLowerCase()}';
    return highScores[key] ?? 0;
  }

  // Get total questions for all categories
  int getTotalQuestions() {
    return categories.fold(0, (sum, category) => sum + category.questionCount);
  }
}
