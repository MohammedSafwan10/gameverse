import 'quiz_category.dart';
import '../controllers/mode_selection_controller.dart';

class QuizSessionConfig {
  const QuizSessionConfig({
    required this.category,
    required this.questionCount,
    required this.mode,
  });

  final QuizCategory category;
  final int questionCount;
  final QuizMode mode;
}
