import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/mode_selection_controller.dart';
import '../services/quiz_service.dart';
import 'quiz_screen.dart';
import '../models/quiz_category.dart';
import '../bindings/quiz_binding.dart';

class QuizMasterModeSelectionScreen extends GetView<ModeSelectionController> {
  const QuizMasterModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies if not already initialized
    if (!Get.isRegistered<QuizService>()) {
      QuizMasterBinding().dependencies();
    }

    final quizService = Get.find<QuizService>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                red: 0,
                                green: 0,
                                blue: 0,
                                alpha: 0.05 * 255,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 24),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () => _showHowToPlay(context),
                    ),
                  ],
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Master',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ).animate().fadeIn().slideX(),
                    const SizedBox(height: 8),
                    Text(
                      'Test your knowledge in various topics',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ).animate().fadeIn().slideX(delay: 200.ms),
                  ],
                ),
              ),

              // Stats Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      red: 255,
                      green: 255,
                      blue: 255,
                      alpha: 0.8 * 255,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            'Best Score',
                            quizService.highScores.isEmpty
                                ? '0'
                                : '${quizService.highScores.values.reduce((a, b) => a > b ? a : b)}',
                            Icons.emoji_events_rounded,
                            Colors.amber,
                          ),
                          _buildDivider(),
                          _buildStatItem(
                            'Total Played',
                            '${quizService.totalQuestionsAnswered}',
                            Icons.quiz_rounded,
                            Colors.blue,
                          ),
                        ],
                      )),
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              // Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Categories',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: quizService.categories.length,
                  itemBuilder: (context, index) {
                    final category = quizService.categories[index];
                    return _buildCategoryCard(category, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(
                red: color.r.toDouble(),
                green: color.g.toDouble(),
                blue: color.b.toDouble(),
                alpha: 0.1 * 255,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0.6 * 255,
              ),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.05 * 255,
      ),
    );
  }

  Widget _buildCategoryCard(QuizCategory category, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withValues(
            red: category.color.r.toDouble(),
            green: category.color.g.toDouble(),
            blue: category.color.b.toDouble(),
            alpha: 0.05 * 255,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDifficultyDialog(category),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: category.color.withValues(
                        red: category.color.r.toDouble(),
                        green: category.color.g.toDouble(),
                        blue: category.color.b.toDouble(),
                        alpha: 0.15 * 255,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon,
                      size: 24,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              icon: Icons.quiz_rounded,
                              label: '${category.questionCount} Questions',
                              color: category.color,
                            ),
                            _buildInfoChip(
                              icon: Icons.timer_rounded,
                              label: '5 min',
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black26,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn().slideX(delay: Duration(milliseconds: index * 100)),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          red: color.r.toDouble(),
          green: color.g.toDouble(),
          blue: color.b.toDouble(),
          alpha: 0.1 * 255,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog(QuizCategory category) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withValues(
                        red: category.color.r.toDouble(),
                        green: category.color.g.toDouble(),
                        blue: category.color.b.toDouble(),
                        alpha: 0.1 * 255,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Difficulty',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          category.name,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 24),
              ...category.difficulties.asMap().entries.map((entry) {
                final index = entry.key;
                final difficulty = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        Get.to(() => QuizScreen(
                              category: category,
                              difficulty: difficulty,
                              mode: QuizMode.practice,
                            ));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withValues(
                                red: category.color.r.toDouble(),
                                green: category.color.g.toDouble(),
                                blue: category.color.b.toDouble(),
                                alpha: 0.05 * 255,
                              ),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getDifficultyIcon(difficulty),
                              color: _getDifficultyColor(difficulty),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              difficulty,
                              style: Get.textTheme.titleMedium?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black26,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX();
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied_rounded;
      case 'medium':
        return Icons.sentiment_neutral_rounded;
      case 'hard':
        return Icons.sentiment_very_dissatisfied_rounded;
      default:
        return Icons.help_outline_rounded;
    }
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

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(
                        red: Colors.blue.r.toDouble(),
                        green: Colors.blue.g.toDouble(),
                        blue: Colors.blue.b.toDouble(),
                        alpha: 0.1 * 255,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Play',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Quick guide to get started',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildHowToPlaySection(
                'Choose Category',
                'Select from various topics like Science, History, Geography, and more!',
                Icons.category_rounded,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildHowToPlaySection(
                'Select Difficulty',
                'Pick your challenge level: Easy, Medium, or Hard',
                Icons.trending_up_rounded,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildHowToPlaySection(
                'Answer Questions',
                'Read carefully and select the best answer. The faster you answer, the more points you get!',
                Icons.quiz_rounded,
                Colors.blue,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowToPlaySection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(
              red: color.r.toDouble(),
              green: color.g.toDouble(),
              blue: color.b.toDouble(),
              alpha: 0.1 * 255,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(
                    red: 0,
                    green: 0,
                    blue: 0,
                    alpha: 0.6 * 255,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
