import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/mode_selection_controller.dart';
import '../models/quiz_category.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

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
          final shouldPop =
              await _showExitConfirmationDialog(context, controller);
          if (shouldPop) {
            Get.back();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Stack(
          children: [
             // Decorative Background
            Positioned(
              right: -100,
              top: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentQuestion = controller.currentQuestion.value;
                if (currentQuestion == null) {
                  return const Center(child: Text('No questions available'));
                }

                return Column(
                  children: [
                    _buildHeader(controller),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildQuestionCard(currentQuestion, controller)
                                .animate(key: ValueKey(currentQuestion.id))
                                .fadeIn()
                                .slideX(begin: 0.2),
                            const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(QuizMasterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  final shouldPop = await _showExitConfirmationDialog(
                      Get.context!, controller);
                  if (shouldPop) {
                    Get.back();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                  _buildStatusChip(
                    icon: Icons.star_rounded,
                    value: '${controller.score.value}',
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(
                    icon: Icons.local_fire_department_rounded,
                    value: '${controller.streak.value}x',
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: Colors.grey[200]),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 500),
                    widthFactor: (controller.currentQuestionIndex.value + 1) /
                        controller.questions.length,
                    child: Container(color: category.color),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (controller.timeRemaining.value > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_rounded, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Obx(() => Text(
                        '${controller.timeRemaining.value}s',
                        style: TextStyle(
                          color: Colors.red,
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
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String value,
    required Color color
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          if (controller.hasAnswered.value) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (controller.selectedAnswer.value ==
                            question.correctOptionIndex
                        ? Colors.green
                        : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (controller.selectedAnswer.value ==
                              question.correctOptionIndex
                          ? Colors.green
                          : Colors.red).withOpacity(0.3),
                ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: controller.selectedAnswer.value ==
                                  question.correctOptionIndex
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (question.explanation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(),
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

        Color getBorderColor() {
          if (!hasAnswered) return isSelected ? category.color : Colors.transparent;
          if (isCorrect) return Colors.green;
          if (isSelected && !isCorrect) return Colors.red;
          return Colors.transparent;
        }

        Color getBackgroundColor() {
          if (!hasAnswered) return Colors.white;
          if (isCorrect) return Colors.green.withOpacity(0.1);
          if (isSelected && !isCorrect) return Colors.red.withOpacity(0.1);
          return Colors.white;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: getBackgroundColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasAnswered ? getBorderColor() : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                if (!hasAnswered)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasAnswered ? null : () => controller.answerQuestion(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasAnswered
                              ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey[200]))
                              : category.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: hasAnswered
                                  ? (isCorrect || isSelected ? Colors.white : Colors.grey[600])
                                  : category.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (hasAnswered && (isCorrect || isSelected))
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate(key: ValueKey(question.id)).fadeIn(delay: Duration(milliseconds: 100 * index)).slideX();
      }).toList(),
    );
  }

  Widget _buildNextButton(QuizMasterController controller) {
    final isLastQuestion = controller.currentQuestionIndex.value ==
        controller.questions.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: isLastQuestion
            ? () => _showResults(controller)
            : controller.nextQuestion,
        style: FilledButton.styleFrom(
          backgroundColor: category.color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isLastQuestion ? 'Finish Quiz' : 'Next Question',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showResults(QuizMasterController controller) {
    // Update stats logic here if needed
    Get.find<QuizService>().updateHighScore(
      category: category,
      difficulty: difficulty,
      score: controller.score.value,
    );

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quiz Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You scored ${controller.score.value} points!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Exit screen
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Exit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Get.back();
                        controller.startQuiz(
                          category: category,
                          difficulty: difficulty,
                          mode: mode,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: category.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Play Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> _showExitConfirmationDialog(
    BuildContext context,
    QuizMasterController controller,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }
}
