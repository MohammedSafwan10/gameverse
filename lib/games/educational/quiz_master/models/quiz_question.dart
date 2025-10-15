class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String category;
  final String difficulty;
  final int points;
  final String? imageUrl;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.points,
    this.imageUrl,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctOptionIndex;
}
