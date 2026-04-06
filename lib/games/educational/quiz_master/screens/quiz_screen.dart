import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/mode_selection_controller.dart';
import '../models/quiz_category.dart';
import '../models/quiz_question.dart';
import '../models/quiz_session_result.dart';
import '../../../../widgets/guarded_exit.dart';

class QuizScreen extends StatelessWidget {
  final QuizCategory category;
  final String difficulty;
  final QuizMode mode;

  const QuizScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuizMasterController());

    // Start quiz when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startQuiz(
        category: category,
        difficulty: difficulty,
        mode: mode,
      );
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await popAfterConfirmation(
            context,
            confirmExit: () => _showExitConfirmationDialog(context, controller),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withValues(
                  alpha: 0.05,
                ),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final result = controller.sessionResult.value;
              if (controller.isCompleted.value && result != null) {
                return _buildResultsView(controller, result);
              }

              final currentQuestion = controller.currentQuestion.value;
              if (currentQuestion == null) {
                return const Center(child: Text('No questions available'));
              }

              return Column(
                children: [
                  _buildHeader(context, controller),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildQuestionCard(currentQuestion, controller),
                          const SizedBox(height: 20),
                          _buildOptions(currentQuestion, controller),
                        ],
                      ),
                    ),
                  ),
                  if (controller.hasAnswered.value)
                    _buildNextButton(controller)
                        .animate()
                        .fadeIn()
                        .slideY(begin: 1, end: 0),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuizMasterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  await popAfterConfirmation(
                    context,
                    confirmExit: () =>
                        _showExitConfirmationDialog(context, controller),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.05,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 24),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                              '${controller.score.value}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                              '${controller.streak.value}x',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: category.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    difficulty,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: _getDifficultyColor(difficulty),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: category.color.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: Get.width *
                    ((controller.currentQuestionIndex.value + 1) /
                        controller.questions.length),
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (controller.timeRemaining.value > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Obx(() => Text(
                            '${controller.timeRemaining.value}s',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    QuizQuestion question,
    QuizMasterController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.9,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: Get.textTheme.titleLarge?.copyWith(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          if (question.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          ],
          if (controller.hasAnswered.value) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (controller.selectedAnswer.value ==
                            question.correctOptionIndex
                        ? Colors.green
                        : Colors.red)
                    .withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        controller.selectedAnswer.value ==
                                question.correctOptionIndex
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: controller.selectedAnswer.value ==
                                question.correctOptionIndex
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.selectedAnswer.value ==
                                question.correctOptionIndex
                            ? 'Correct!'
                            : 'Incorrect',
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: controller.selectedAnswer.value ==
                                  question.correctOptionIndex
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explanation:',
                    style: Get.textTheme.titleSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptions(
    QuizQuestion question,
    QuizMasterController controller,
  ) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = controller.selectedAnswer.value == index;
        final hasAnswered = controller.hasAnswered.value;
        final isCorrect = index == question.correctOptionIndex;

        Color getOptionColor() {
          if (!hasAnswered) return category.color;
          if (isCorrect) return Colors.green;
          if (isSelected && !isCorrect) return Colors.red;
          return Colors.grey;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  hasAnswered ? null : () => controller.answerQuestion(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getOptionColor().withValues(
                    alpha: isSelected ? 0.15 : 0.05,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: getOptionColor().withValues(
                          alpha: isSelected ? 0.2 : 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            color: getOptionColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (hasAnswered)
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : (isSelected ? Icons.cancel_rounded : null),
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn().slideX(delay: Duration(milliseconds: index * 100));
      }).toList(),
    );
  }

  Widget _buildNextButton(QuizMasterController controller) {
    final isLastQuestion = controller.currentQuestionIndex.value ==
        controller.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: isLastQuestion
            ? () {
                controller.completeQuiz();
                controller.saveSessionStats();
              }
            : controller.nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: category.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastQuestion ? 'Finish Quiz' : 'Next Question',
              style: Get.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLastQuestion ? Icons.flag_rounded : Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Get.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(
    QuizMasterController controller,
    QuizSessionResult result,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: category.color,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Complete!',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job on completing the quiz!',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildResultStat(
            'Final Score',
            '${result.finalScore}',
            Icons.star_rounded,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildResultStat(
            'Highest Streak',
            '${result.highestStreak}x',
            Icons.local_fire_department_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildResultStat(
            'Correct Answers',
            '${result.correctAnswers}/${result.totalQuestions}',
            Icons.check_circle_outline_rounded,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildResultStat(
            'Accuracy',
            '${(result.accuracy * 100).round()}%',
            Icons.track_changes_rounded,
            category.color,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: category.color.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'Exit Quiz',
                    style: TextStyle(
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.startQuiz(
                    category: category,
                    difficulty: difficulty,
                    mode: mode,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(
    BuildContext context,
    QuizMasterController controller,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Exit Quiz?',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to exit? Your progress will be lost.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: Colors.grey.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
