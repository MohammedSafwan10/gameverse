class QuizSessionResult {
  const QuizSessionResult({
    required this.finalScore,
    required this.highestStreak,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  final int finalScore;
  final int highestStreak;
  final int totalQuestions;
  final int correctAnswers;

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}
