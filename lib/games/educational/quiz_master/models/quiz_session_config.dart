import 'quiz_category.dart';
import '../controllers/mode_selection_controller.dart';

class QuizSessionConfig {
  const QuizSessionConfig({
    required this.category,
    required this.difficulty,
    required this.mode,
  });

  final QuizCategory category;
  final String difficulty;
  final QuizMode mode;
}
