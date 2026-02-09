import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameOptionsDialog extends StatelessWidget {
  final ChessGameMode mode;

  const GameOptionsDialog({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerEnabled = false.obs;
    final selectedTime = 10.obs;
    final selectedDifficulty = 2.obs;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.settings_suggest,
                        color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Game Options',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timer Section
                    _buildSectionHeader(context, 'Timer', Icons.timer_outlined),
                    const SizedBox(height: 12),
                    Obx(() => _buildOptionCard(
                          context,
                          child: Column(
                            children: [
                              SwitchListTile(
                                value: timerEnabled.value,
                                onChanged: (value) =>
                                    timerEnabled.value = value,
                                title: const Text('Timed Match'),
                                subtitle: Text(timerEnabled.value
                                    ? 'Timer active'
                                    : 'Play at your own pace'),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              if (timerEnabled.value) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      const Text('Minutes per player'),
                                      const Spacer(),
                                      DropdownButton<int>(
                                        value: selectedTime.value,
                                        underline: const SizedBox(),
                                        items: [5, 10, 15, 20, 30]
                                            .map((minutes) => DropdownMenuItem(
                                                  value: minutes,
                                                  child: Text('$minutes min'),
                                                ))
                                            .toList(),
                                        onChanged: (value) =>
                                            selectedTime.value = value!,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),

                    if (mode == ChessGameMode.ai) ...[
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                          context, 'AI Difficulty', Icons.psychology_outlined),
                      const SizedBox(height: 12),
                      Obx(() => _buildDifficultySelector(
                          context, selectedDifficulty)),
                    ],

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Get.back(),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Get.back(result: {
                              'timerEnabled': timerEnabled.value,
                              'timePerPlayer': selectedTime.value,
                              'difficulty': selectedDifficulty.value,
                            }),
                            child: const Text('START GAME'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }

  Widget _buildDifficultySelector(BuildContext context, RxInt selected) {
    final difficulties = [
      (1, 'Easy', Icons.sentiment_satisfied_alt, Colors.green),
      (2, 'Medium', Icons.sentiment_neutral, Colors.orange),
      (3, 'Hard', Icons.sentiment_very_dissatisfied, Colors.red),
    ];

    return Row(
      children: difficulties.map((diff) {
        final isSelected = selected.value == diff.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => selected.value = diff.$1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? diff.$4 : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? diff.$4
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    diff.$3,
                    color: isSelected ? Colors.white : diff.$4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diff.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
