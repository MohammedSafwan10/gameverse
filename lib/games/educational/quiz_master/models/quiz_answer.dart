import 'quiz_question.dart';

/// An immutable answer snapshot for this round's read-only review.
class QuizAnswer {
  const QuizAnswer(
      {required this.question,
      required this.selectedIndex,
      required this.points,
      required this.secondsRemaining});
  final QuizQuestion question;
  final int selectedIndex;
  final int points;
  final int secondsRemaining;
  bool get timedOut => selectedIndex == -1;
  bool get isCorrect => question.isCorrect(selectedIndex);
}
